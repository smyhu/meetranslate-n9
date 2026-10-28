#!/usr/bin/python
# -*- coding: utf-8 -*-
# MeeTranslate - translator for the Nokia N9 (Python 2.6 + PySide + QML).
# Online: Google Translate, MyMemory. Offline: WikDict dictionaries (SQLite).
# Reading aloud: Google text-to-speech.
# Written by Claude (Anthropic) together with smyhu.

import os
import sys
import pwd
import json
import subprocess

from PySide.QtCore import QObject, QUrl, QProcess, QSettings, Signal, Slot
from PySide.QtGui import QApplication
from PySide.QtDeclarative import QDeclarativeView

APP_DIR = os.path.dirname(os.path.abspath(__file__))
FETCH = os.path.join(APP_DIR, 'meetranslate-fetch')
VERSION = '0.1.1'
UI_LANGUAGES = ('pl', 'en', 'de', 'es', 'it', 'fr')

HOME = pwd.getpwuid(os.getuid()).pw_dir
if not os.path.isdir(HOME):
    HOME = '/home/user'
DATA_DIR = os.path.join(HOME, '.local/share/meetranslate')
DICT_DIR = os.path.join(DATA_DIR, 'dicts')
TTS_DIR = os.path.join(DATA_DIR, 'tts')
WIKDICT_URL = 'https://download.wikdict.com/dictionaries/sqlite/2/%s.sqlite3'


def session_env():
    """Outside the user session D-Bus and gconf need the session bus address;
    Harmattan keeps it in /tmp/session_bus_address.user."""
    if os.environ.get('DBUS_SESSION_BUS_ADDRESS'):
        return
    try:
        for line in open('/tmp/session_bus_address.user'):
            if 'DBUS_SESSION_BUS_ADDRESS=' in line:
                value = line.split('DBUS_SESSION_BUS_ADDRESS=', 1)[1].strip().strip("';")
                os.environ['DBUS_SESSION_BUS_ADDRESS'] = value
    except IOError:
        pass


def phone_language():
    """Phone language (gconf /meegotouch/i18n/language); English otherwise.
    MEETRANSLATE_LANG=de etc. overrides it for testing."""
    code = os.environ.get('MEETRANSLATE_LANG', '')
    if not code:
        session_env()
        try:
            p = subprocess.Popen(['gconftool-2', '-g', '/meegotouch/i18n/language'],
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            code = p.communicate()[0].strip()
        except OSError:
            pass
    if not code:
        code = os.environ.get('LANG', '')
    code = code[:2].lower()
    if code in UI_LANGUAGES:
        return code
    return 'en'


def ensure_dir(path):
    if not os.path.isdir(path):
        os.makedirs(path)


class Net(QObject):
    """Runs meetranslate-fetch in helper processes. A crash in the phone's SSL
    libraries can only end a helper: QtNetwork inside Python crashes on the N9,
    because Python holds the old OpenSSL 0.9.8 while the TLS patch makes Qt load
    OpenSSL 1.0.x. Each request has a tag; the answer comes back in finished()."""

    # QML cannot read the arguments of PySide signals, so the answers wait in
    # a queue and QML takes them after finished() (the Waluty pattern)
    finished = Signal()

    def __init__(self):
        QObject.__init__(self)
        self.procs = {}
        self.results = []
        self.progress_handlers = []

    def start(self, tag, url, data=u'', outfile=u'', idle=30, on_done=None):
        self.cancel(tag)
        args = ['-t', str(idle)]
        if data:
            args += ['-d', data]
        if outfile:
            args += ['-o', outfile]
        args.append(url)
        proc = QProcess(self)
        self.procs[tag] = proc
        state = {'err': ''}

        def stderr_ready():
            text = str(proc.readAllStandardError())
            for line in text.splitlines():
                if line.startswith('progress '):
                    parts = line.split()
                    try:
                        for h in self.progress_handlers:
                            h(tag, float(parts[1]), float(parts[2]))
                    except (IndexError, ValueError):
                        pass
                elif line.strip():
                    state['err'] = line.strip()

        def finished(*args):
            if self.procs.get(tag) is not proc:
                return
            del self.procs[tag]
            stderr_ready()
            ok = proc.exitStatus() == QProcess.NormalExit and proc.exitCode() == 0
            body = u''
            if ok and not outfile:
                body = str(proc.readAllStandardOutput()).decode('utf-8', 'replace')
            elif not ok:
                body = unicode(state['err'] or 'helper crashed', 'utf-8', 'replace')
                print 'meetranslate: %s failed: %s' % (url[:80], body)
            proc.deleteLater()
            if on_done:
                on_done(ok, body)
            else:
                self.results.append({'tag': tag, 'ok': ok, 'body': body})
                self.finished.emit()

        proc.readyReadStandardError.connect(lambda: stderr_ready())
        proc.finished.connect(lambda *a: finished(*a))
        proc.start(FETCH, args)

    @Slot(unicode, unicode, unicode)
    def request(self, tag, url, data):
        self.start(tag, url, data)

    @Slot(result=unicode)
    def take(self):
        if not self.results:
            return u''
        return unicode(json.dumps(self.results.pop(0)))

    @Slot(result=bool)
    def online(self):
        """True when a network interface has a default route. Checked before
        each request: starting a request without a connection makes the phone
        show its "choose a network" dialog again and again."""
        try:
            f = open(os.environ.get('MEETRANSLATE_ROUTES', '/proc/net/route'))
            try:
                lines = f.readlines()[1:]
            finally:
                f.close()
        except IOError:
            return True
        for line in lines:
            fields = line.split()
            if len(fields) > 3 and fields[0] != 'lo' and fields[1] == '00000000' \
                    and int(fields[3], 16) & 1:
                return True
        return False

    @Slot(unicode)
    def cancel(self, tag):
        proc = self.procs.pop(tag, None)
        if proc:
            proc.kill()


class Dictionaries(QObject):
    """Offline WikDict dictionaries: download, prepare (index), look up."""

    changed = Signal()

    def __init__(self, net):
        QObject.__init__(self)
        self.net = net
        self.busy = {}      # pair -> {stage, got, total}
        self.events = []    # finished installs: {pair, ok, error}
        net.progress_handlers.append(self._progress)

    def _progress(self, tag, got, total):
        if tag.startswith('dict-') and tag[5:] in self.busy:
            self.busy[tag[5:]] = {'stage': 'download', 'got': got, 'total': total}
            self.changed.emit()

    @Slot(result=unicode)
    def status(self):
        return unicode(json.dumps(self.busy))

    @Slot(result=unicode)
    def takeEvent(self):
        if not self.events:
            return u''
        return unicode(json.dumps(self.events.pop(0)))

    def path(self, pair):
        return os.path.join(DICT_DIR, pair + '.sqlite3')

    @Slot(result=unicode)
    def installed(self):
        try:
            names = sorted(f[:-8] for f in os.listdir(DICT_DIR) if f.endswith('.sqlite3'))
        except OSError:
            names = []
        out = []
        for n in names:
            out.append({'pair': n, 'size': os.path.getsize(self.path(n))})
        return unicode(json.dumps(out))

    @Slot(unicode, unicode, result=unicode)
    def lookup(self, pair, word):
        import sqlite3
        word = word.strip()
        if not word or not os.path.exists(self.path(pair)):
            return u'[]'
        try:
            db = sqlite3.connect(self.path(pair))
            rows = db.execute('SELECT written_rep, trans_list FROM simple_translation '
                              'WHERE written_rep = ? COLLATE NOCASE ORDER BY max_score DESC LIMIT 5',
                              (word,)).fetchall()
            seen = set(r[0] for r in rows)
            more = []
            if len(word) >= 2:
                more = db.execute('SELECT written_rep, trans_list FROM simple_translation '
                                  'WHERE written_rep LIKE ? ORDER BY length(written_rep), rel_importance DESC LIMIT 40',
                                  (word.replace('%', '').replace('_', '') + '%',)).fetchall()
            db.close()
        except Exception, e:
            print 'meetranslate: lookup failed:', e
            return u'[]'
        out = [{'word': r[0], 'trans': r[1], 'exact': True} for r in rows]
        for r in more:
            if r[0] not in seen and len(out) < 40:
                seen.add(r[0])
                out.append({'word': r[0], 'trans': r[1], 'exact': False})
        return unicode(json.dumps(out))

    @Slot(unicode)
    def remove(self, pair):
        try:
            os.remove(self.path(pair))
        except OSError:
            pass

    @Slot(unicode)
    def install(self, pair):
        if pair in self.busy:
            return
        ensure_dir(DICT_DIR)
        raw = os.path.join(DICT_DIR, pair + '.download')
        self.busy[pair] = {'stage': 'download', 'got': 0, 'total': -1}
        self.changed.emit()

        def downloaded(ok, err):
            if pair not in self.busy:
                return
            if not ok:
                self._fail(pair, raw, err)
                return
            self.busy[pair] = {'stage': 'prepare', 'got': 0, 'total': 0}
            self.changed.emit()
            proc = QProcess(self)
            proc.finished.connect(lambda *a: prepared(proc))
            proc.start(sys.executable, [os.path.join(APP_DIR, 'dictprep.py'), raw, self.path(pair)])

        def prepared(proc):
            ok = proc.exitStatus() == QProcess.NormalExit and proc.exitCode() == 0
            err = str(proc.readAllStandardError()).strip()
            proc.deleteLater()
            if not ok:
                self._fail(pair, raw, unicode(err or 'prepare failed', 'utf-8', 'replace'))
                return
            self.busy.pop(pair, None)
            self.events.append({'pair': pair, 'ok': True, 'error': ''})
            self.changed.emit()

        self.net.start('dict-' + pair, WIKDICT_URL % pair, outfile=raw, idle=60, on_done=downloaded)

    def _fail(self, pair, raw, err):
        try:
            os.remove(raw)
        except OSError:
            pass
        if self.busy.pop(pair, None) is None:
            return
        self.events.append({'pair': pair, 'ok': False, 'error': err})
        self.changed.emit()

    @Slot(unicode)
    def cancel(self, pair):
        self.net.cancel('dict-' + pair)
        self._fail(pair, os.path.join(DICT_DIR, pair + '.download'), u'cancelled')


class Speech(QObject):
    """Google text-to-speech: downloads MP3 pieces (max ~180 characters each),
    QML plays them one after another."""

    ready = Signal()
    failed = Signal()

    def __init__(self, net):
        QObject.__init__(self)
        self.net = net
        self.job = 0
        self.files = []

    @Slot(result=unicode)
    def takeFiles(self):
        return unicode(json.dumps(self.files))

    @staticmethod
    def pieces(text, limit=180):
        text = u' '.join(text.split())
        out = []
        while len(text) > limit:
            cut = -1
            for mark in (u'. ', u'! ', u'? ', u'; ', u': ', u', ', u' '):
                cut = text.rfind(mark, 0, limit)
                if cut > limit / 3:
                    cut += len(mark) - 1
                    break
            if cut <= 0:
                cut = limit
            out.append(text[:cut].strip())
            text = text[cut:].strip()
        if text:
            out.append(text)
        return out

    @Slot(unicode, unicode)
    def speak(self, text, lang):
        import urllib
        self.stop()
        self.job += 1
        job = self.job
        ensure_dir(TTS_DIR)
        for f in os.listdir(TTS_DIR):
            try:
                os.remove(os.path.join(TTS_DIR, f))
            except OSError:
                pass
        parts = self.pieces(text)[:20]
        files = []

        def next_piece(i):
            if job != self.job:
                return
            if i >= len(parts):
                self.files = files
                self.ready.emit()
                return
            q = urllib.quote(parts[i].encode('utf-8'))
            url = ('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=%s&total=%d&idx=%d&textlen=%d&q=%s'
                   % (urllib.quote(lang.encode('utf-8')), len(parts), i, len(parts[i]), q))
            out = os.path.join(TTS_DIR, 'part%02d.mp3' % i)

            def done(ok, err):
                if job != self.job:
                    return
                if not ok:
                    self.failed.emit()
                    return
                files.append(out)
                next_piece(i + 1)

            self.net.start('tts', url, outfile=out, idle=20, on_done=done)

        next_piece(0)

    @Slot()
    def stop(self):
        self.job += 1
        self.net.cancel('tts')


class Settings(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.s = QSettings('meetranslate', 'meetranslate')

    @Slot(unicode, unicode, result=unicode)
    def get(self, key, default):
        v = self.s.value(key, default)
        if v is None:
            return default
        return unicode(v)

    @Slot(unicode, unicode)
    def set(self, key, value):
        self.s.setValue(key, value)
        self.s.sync()


class Clipboard(QObject):
    @Slot(result=unicode)
    def text(self):
        return QApplication.clipboard().text()

    @Slot(unicode)
    def setText(self, text):
        QApplication.clipboard().setText(text)


def main():
    app = QApplication(sys.argv)
    app.setApplicationName('meetranslate')
    app.setOrganizationName('meetranslate')

    view = QDeclarativeView()
    net = Net()
    dicts = Dictionaries(net)
    speech = Speech(net)
    settings = Settings()
    clipboard = Clipboard()
    ctx = view.rootContext()
    ctx.setContextProperty('uiLang', phone_language())
    ctx.setContextProperty('appVersion', VERSION)
    ctx.setContextProperty('net', net)
    ctx.setContextProperty('dicts', dicts)
    ctx.setContextProperty('speech', speech)
    ctx.setContextProperty('settings', settings)
    ctx.setContextProperty('clipboard', clipboard)
    view.setResizeMode(QDeclarativeView.SizeRootObjectToView)
    view.setSource(QUrl.fromLocalFile(os.path.join(APP_DIR, 'qml', 'main.qml')))
    view.showFullScreen()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()

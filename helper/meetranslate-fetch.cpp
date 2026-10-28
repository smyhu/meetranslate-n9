// MeeTranslate download helper for the Nokia N9.
// Usage: meetranslate-fetch [-d DATA] [-o FILE] [-t SECONDS] [-a AGENT] URL
//   -d DATA     send a POST request with this form-urlencoded body
//   -o FILE     write the body to FILE (written as it arrives, for big files),
//               otherwise the body goes to stdout
//   -t SECONDS  give up after this many seconds without any data (default 30)
//   -a AGENT    User-Agent header (default "Mozilla/5.0")
// Exit code 0 on success. With -o, progress lines "progress RECEIVED TOTAL"
// go to stderr.
// Native Qt program: Python on the N9 carries the old OpenSSL 0.9.8, which
// crashes the TLS-patched QtNetwork (OpenSSL 1.0.x) in the same process.
// Built without moc: the reply is polled instead of connecting slots.

#include <QtCore/qcoreapplication.h>
#include <QtCore/qeventloop.h>
#include <QtCore/qelapsedtimer.h>
#include <QtCore/qfile.h>
#include <QtCore/qurl.h>
#include <QtNetwork/qnetworkaccessmanager.h>
#include <QtNetwork/qnetworkrequest.h>
#include <QtNetwork/qnetworkreply.h>
#include <stdio.h>
#include <string.h>


static int usage()
{
    fprintf(stderr, "usage: meetranslate-fetch [-d DATA] [-o FILE] [-t SECONDS] [-a AGENT] URL\n");
    return 1;
}

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QByteArray data, agent("Mozilla/5.0");
    const char *outName = 0;
    const char *url = 0;
    bool post = false;
    int idle = 30;
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "-d") && i + 1 < argc) {
            data = argv[++i];
            post = true;
        } else if (!strcmp(argv[i], "-o") && i + 1 < argc) {
            outName = argv[++i];
        } else if (!strcmp(argv[i], "-t") && i + 1 < argc) {
            idle = QByteArray(argv[++i]).toInt();
        } else if (!strcmp(argv[i], "-a") && i + 1 < argc) {
            agent = argv[++i];
        } else if (argv[i][0] != '-' && !url) {
            url = argv[i];
        } else {
            return usage();
        }
    }
    if (!url || idle <= 0)
        return usage();

    QFile out;
    if (outName) {
        out.setFileName(QString::fromLocal8Bit(outName));
        if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            fprintf(stderr, "cannot write %s\n", outName);
            return 5;
        }
    } else {
        out.open(stdout, QIODevice::WriteOnly);
    }

    QNetworkAccessManager nam;
    QUrl target = QUrl::fromEncoded(url);
    for (int hop = 0; hop < 6; ++hop) {
        QNetworkRequest request(target);
        request.setRawHeader("User-Agent", agent);
        QNetworkReply *reply;
        if (post) {
            request.setHeader(QNetworkRequest::ContentTypeHeader,
                              "application/x-www-form-urlencoded;charset=UTF-8");
            reply = nam.post(request, data);
        } else {
            reply = nam.get(request);
        }

        QEventLoop loop;
        QElapsedTimer quiet;
        quiet.start();
        qint64 received = 0, lastShown = -1;
        bool body = false;
        while (true) {
            loop.processEvents(QEventLoop::WaitForMoreEvents, 200);
            if (!body && reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).isValid()) {
                int s = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
                body = s == 200;
            }
            if (body && reply->bytesAvailable() > 0) {
                QByteArray chunk = reply->readAll();
                out.write(chunk);
                received += chunk.size();
                quiet.restart();
            }
            if (outName && received != lastShown && (received - lastShown > 262144 || reply->isFinished())) {
                QVariant len = reply->header(QNetworkRequest::ContentLengthHeader);
                fprintf(stderr, "progress %lld %lld\n", (long long)received,
                        len.isValid() ? (long long)len.toLongLong() : -1LL);
                lastShown = received;
            }
            if (reply->isFinished())
                break;
            if (quiet.elapsed() > idle * 1000) {
                fprintf(stderr, "timeout\n");
                return 3;
            }
        }

        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QUrl next = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
        if ((status == 301 || status == 302 || status == 303 || status == 307) && next.isValid()) {
            target = target.resolved(next);
            if (status == 303)
                post = false;
            reply->deleteLater();
            continue;
        }
        if (reply->error() != QNetworkReply::NoError || status != 200) {
            fprintf(stderr, "error %d, HTTP %d: %s\n", int(reply->error()), status,
                    reply->errorString().toLocal8Bit().constData());
            if (outName) {
                out.close();
                out.remove();
            }
            return 2;
        }
        QByteArray rest = reply->readAll();
        out.write(rest);
        out.close();
        return 0;
    }
    fprintf(stderr, "too many redirects\n");
    return 4;
}

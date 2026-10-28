import QtQuick 1.1
import com.nokia.meego 1.0
import "strings.js" as S
import "translator.js" as T

Page {
    id: page

    property string service: settings.get("service", "google")
    property string fromCode: settings.get("from", "auto")
    property string toCode: settings.get("to", uiLang == "en" ? "pl" : uiLang)
    property bool busy: false
    property bool enterTranslates: settings.get("enterKey", "false") == "true"
    property bool pasteTranslates: settings.get("pasteGo", "true") == "true"
    property bool useFallback: settings.get("useFallback", "true") == "true"
    property bool useOffline: settings.get("useOffline", "true") == "true"

    property string translation: ""
    property string translationLang: ""
    property string sourceTranslit: ""
    property string targetTranslit: ""
    property string detected: ""
    property string note: ""
    property int requestId: 0
    property variant job: ({})

    property Item source: enterTranslates ? sourceSingle : sourceMulti

    function tr(key) { return S.t(uiLang, key); }
    function serviceName(id) { return tr(id); }
    function langName(code) { return T.languageName(uiLang, code); }

    function setService(id) {
        service = id;
        settings.set("service", id);
        if (id == "offline" && fromCode == "auto")
            appWindow.showBanner(tr("needSource"));
    }
    function setFrom(code) { fromCode = code; settings.set("from", code); }
    function setTo(code) { toCode = code; settings.set("to", code); }
    function swap() {
        if (fromCode == "auto") {
            if (detected == "")
                return;
            setFrom(detected);      // swap with the language Google detected
        }
        var f = fromCode;
        setFrom(toCode);
        setTo(f);
        if (translation != "") {
            source.text = translation;
            translate();
        }
    }

    function clearResult() {
        translation = "";
        sourceTranslit = "";
        targetTranslit = "";
        detected = "";
        note = "";
        dictModel.clear();
        appWindow.stopSpeaking();
    }

    function showDictionary(sections) {
        dictModel.clear();
        for (var i = 0; i < sections.length; ++i) {
            if (sections[i].pos != "")
                dictModel.append({ "kind": "header", "word": sections[i].pos, "reverse": "" });
            var e = sections[i].entries;
            for (var j = 0; j < e.length; ++j)
                dictModel.append({ "kind": "entry", "word": e[j].word, "reverse": e[j].reverse });
        }
    }

    // ---- translating ----

    function translate() {
        var text = source.text.replace(/^\s+|\s+$/g, "");
        if (text == "")
            return;
        clearResult();
        requestId += 1;
        job = { "id": requestId, "text": text, "from": fromCode, "to": toCode };
        if (service == "offline") {
            busy = true;
            offline(text, false);
            busy = false;
        } else if (!net.online()) {
            noInternet();
        } else if (service == "mymemory") {
            startMyMemory(text, false);
        } else {
            busy = true;
            net.request("google:" + requestId + ":s", T.googleUrl(true, fromCode, toCode, uiLang), T.googleBody(text));
        }
    }

    function finishedGoogle(secure, ok, body) {
        var r = ok ? T.parseGoogle(body) : null;
        if (r) {
            busy = false;
            translation = r.text;
            translationLang = job.to;
            sourceTranslit = r.sourceTranslit;
            targetTranslit = r.targetTranslit;
            if (job.from == "auto" && r.detected != "")
                detected = r.detected;
            showDictionary(r.dictionary);
            return;
        }
        if (secure && net.online()) {
            // the HTTPS helper may fail on phones without the TLS patch: try plain HTTP
            net.request("google:" + job.id + ":p", T.googleUrl(false, job.from, job.to, uiLang), T.googleBody(job.text));
            return;
        }
        failed(ok ? "Google" : body, true);
    }

    function startMyMemory(text, asFallback) {
        busy = true;
        var j = job;
        j.pieces = T.myMemoryPieces(text);
        j.piece = 0;
        j.result = "";
        j.fallback = asFallback;
        job = j;
        net.request("mm:" + job.id, T.myMemoryUrl(job.pieces[0], job.from, job.to), "");
    }

    function finishedMyMemory(ok, body) {
        var r = ok ? T.parseMyMemory(body) : { "error": body };
        if (r.error !== undefined) {
            failed(r.error, false);
            return;
        }
        var j = job;
        j.result += (j.piece > 0 ? " " : "") + r.text;
        if (j.piece == 0 && j.from == "auto" && r.detected)
            detected = r.detected.split("-")[0];
        j.piece += 1;
        job = j;
        if (j.piece < j.pieces.length) {
            net.request("mm:" + job.id, T.myMemoryUrl(j.pieces[j.piece], j.from, j.to), "");
            return;
        }
        busy = false;
        translation = j.result;
        translationLang = j.to;
        if (j.fallback)
            note = tr("usedFallback");
    }

    // explicit: chosen by the user (false) or used because the internet failed (true)
    function offline(text, automatic) {
        var pair = T.dictPair(job.from, job.to);
        if (job.from == "auto") {
            if (!automatic)
                appWindow.showBanner(tr("needSource"));
            return false;
        }
        var installed = JSON.parse(dicts.installed());
        var have = false;
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].pair == pair)
                have = true;
        if (!have) {
            if (!automatic)
                appWindow.showBanner(tr("noDict").replace("%1", langName(job.from) + " → " + langName(job.to)));
            return false;
        }
        var r = T.offlineResult(JSON.parse(dicts.lookup(pair, text)), tr("similar"));
        translation = r.text;
        translationLang = job.to;
        showDictionary(r.dictionary);
        if (automatic)
            note = tr("usedOffline");
        else if (!r.found)
            note = tr("notFound");
        return true;
    }

    function failed(error, fromGoogle) {
        if (!net.online()) {
            noInternet();
            return;
        }
        if (fromGoogle && useFallback) {
            startMyMemory(job.text, true);
            return;
        }
        busy = false;
        if (useOffline && offline(job.text, true)) {
            note = tr("serviceOffline");   // connected, but the services did not answer
            return;
        }
        appWindow.showBanner(tr("netError").replace("%1", error));
    }

    // no connection: no requests at all, the offline dictionary if there is one
    function noInternet() {
        busy = false;
        if (useOffline && offline(job.text, true))
            return;
        appWindow.showBanner(tr("noInternet"));
    }

    Connections {
        target: net
        onFinished: {
            var r;
            while ((r = net.take()) != "") {
                r = JSON.parse(r);
                var parts = r.tag.split(":");
                if (parseInt(parts[1]) != page.job.id)
                    continue;           // answer to an older request
                if (parts[0] == "google")
                    page.finishedGoogle(parts[2] == "s", r.ok, r.body);
                else if (parts[0] == "mm")
                    page.finishedMyMemory(r.ok, r.body);
            }
        }
    }

    ListModel { id: dictModel }

    // ---- look ----

    SelectionDialog {
        id: serviceDialog
        titleText: tr("service")
        model: ListModel {
            id: serviceModel
        }
        onAccepted: setService(["google", "mymemory", "offline"][selectedIndex])
        Component.onCompleted: {
            var ids = ["google", "mymemory", "offline"];
            for (var i = 0; i < ids.length; ++i)
                serviceModel.append({ "name": serviceName(ids[i]) });
        }
    }

    Rectangle {
        id: titleBar
        height: appWindow.inPortrait ? 72 : 64
        anchors { left: parent.left; right: parent.right; top: parent.top }
        gradient: Gradient {
            GradientStop { position: 0.0; color: appWindow.headerTop }
            GradientStop { position: 1.0; color: appWindow.headerBottom }
        }
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.2
            visible: titleMouse.pressed
        }
        Label {
            text: serviceName(service)
            color: "white"
            font.pixelSize: 32
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
        }
        Image {
            source: "image://theme/meegotouch-combobox-indicator-inverted"
            anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
        }
        MouseArea {
            id: titleMouse
            anchors.fill: parent
            onClicked: {
                serviceDialog.selectedIndex = ["google", "mymemory", "offline"].indexOf(service);
                serviceDialog.open();
            }
        }
    }

    Flickable {
        id: flickable
        clip: true
        contentWidth: width
        contentHeight: content.height + 32
        anchors { top: titleBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom
                  leftMargin: 8; rightMargin: 8 }

        Column {
            id: content
            width: parent.width
            y: 16
            spacing: 16

            Row {
                width: parent.width
                height: 72
                spacing: 8

                LanguageButton {
                    width: (parent.width - swapButton.width - 16) / 2
                    title: tr("from")
                    value: langName(fromCode)
                    onClicked: pickLanguage(true)
                }
                Button {
                    id: swapButton
                    width: 72
                    height: 72
                    enabled: fromCode != "auto" || detected != ""
                    iconSource: theme.inverted ? "image://theme/icon-m-toolbar-refresh-white" : "image://theme/icon-m-toolbar-refresh"
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: swap()
                }
                LanguageButton {
                    width: (parent.width - swapButton.width - 16) / 2
                    title: tr("to")
                    value: langName(toCode)
                    onClicked: pickLanguage(false)
                }
            }

            Item {
                width: parent.width
                height: enterTranslates ? sourceSingle.height : sourceMulti.height
                TextField {
                    id: sourceSingle
                    width: parent.width
                    visible: enterTranslates
                    placeholderText: tr("placeholder")
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    Keys.onReturnPressed: { parent.focus = true; translate(); }
                    Keys.onEnterPressed: { parent.focus = true; translate(); }
                }
                TextArea {
                    id: sourceMulti
                    width: parent.width
                    visible: !enterTranslates
                    placeholderText: tr("placeholder")
                    textFormat: TextEdit.PlainText
                    wrapMode: TextEdit.Wrap
                    inputMethodHints: Qt.ImhNoAutoUppercase
                }
            }

            Label {
                width: parent.width
                visible: sourceTranslit != ""
                text: sourceTranslit
                font.pixelSize: 22
                font.italic: true
                wrapMode: Text.Wrap
            }

            Item {
                width: parent.width
                height: translateButton.height
                Button {
                    id: translateButton
                    text: busy ? "" : tr("translate")
                    enabled: !busy && source.text != ""
                    anchors { left: parent.left; right: clearButton.left; rightMargin: 16 }
                    platformStyle: ButtonStyle { inverted: !theme.inverted }
                    onClicked: { translateButton.focus = true; translate(); }
                    BusyIndicator {
                        anchors.centerIn: parent
                        visible: busy
                        running: busy
                    }
                }
                Button {
                    id: clearButton
                    width: height
                    anchors.right: parent.right
                    enabled: source.text != ""
                    iconSource: platformStyle.inverted ? "image://theme/icon-m-toolbar-close-white-selected" : "image://theme/icon-m-toolbar-close"
                    platformStyle: ButtonStyle { inverted: !theme.inverted }
                    onClicked: {
                        source.text = "";
                        clearResult();
                        source.forceActiveFocus();
                    }
                }
            }

            // translation, in a box like a disabled text field (as in TAO Translator)
            BorderImage {
                id: resultBox
                width: parent.width
                visible: translation != ""
                height: Math.max(56, resultText.paintedHeight + 32)
                source: resultStyle.backgroundDisabled
                border { left: 10; top: 10; right: 10; bottom: 10 }
                TextAreaStyle { id: resultStyle }
                Label {
                    id: resultText
                    text: translation
                    wrapMode: Text.Wrap
                    font.pixelSize: 26
                    color: resultStyle.textColor
                    anchors { left: parent.left; right: speakButton.left; top: parent.top
                              leftMargin: 16; rightMargin: 8; topMargin: 16 }
                }
                MouseArea {
                    anchors { fill: parent; rightMargin: speakButton.width + 8 }
                    onClicked: pageStack.push(Qt.resolvedUrl("TranslationPage.qml"), { "text": translation })
                }
                ToolIcon {
                    id: speakButton
                    visible: appWindow.canSpeak
                    width: visible ? 64 : 0
                    anchors { right: parent.right; top: parent.top }
                    // the box is light in both themes, so always the dark icons
                    iconSource: appWindow.speaking ? "image://theme/icon-m-toolbar-mediacontrol-stop"
                                                   : "image://theme/icon-m-toolbar-volume"
                    onClicked: {
                        if (appWindow.speaking)
                            appWindow.stopSpeaking();
                        else
                            appWindow.speak(translation, translationLang);
                    }
                }
            }

            Label {
                width: parent.width
                visible: targetTranslit != ""
                text: targetTranslit
                font.pixelSize: 22
                font.italic: true
                wrapMode: Text.Wrap
            }

            Label {
                width: parent.width
                visible: detected != ""
                text: tr("detected").replace("%1", langName(detected))
                font.pixelSize: 22
                color: "#808080"
            }

            Label {
                width: parent.width
                visible: note != ""
                text: note
                font.pixelSize: 22
                color: appWindow.accent
                wrapMode: Text.Wrap
            }

            Column {
                width: parent.width
                Repeater {
                    model: dictModel
                    delegate: DictionaryRow {
                        width: content.width
                        onClicked: {
                            if (service == "offline" && kind == "entry") {
                                source.text = word;
                                translate();
                            }
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: flickable }

    Menu {
        id: menu
        MenuLayout {
            MenuItem {
                text: tr("dictionaries")
                onClicked: pageStack.push(Qt.resolvedUrl("DictionariesPage.qml"),
                                          { "newFrom": T.wikdictCode(fromCode) || "en", "newTo": T.wikdictCode(toCode) || "pl" })
            }
            MenuItem {
                text: tr("settings")
                onClicked: {
                    var p = pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
                    p.changed.connect(reloadSettings);
                }
            }
            MenuItem {
                text: tr("about")
                onClicked: aboutDialog.open()
            }
        }
    }

    QueryDialog {
        id: aboutDialog
        icon: "file:///usr/share/icons/hicolor/80x80/apps/meetranslate80.png"
        titleText: "MeeTranslate " + appVersion
        message: tr("aboutText")
        acceptButtonText: tr("close")
    }

    tools: ToolBarLayout {
        ToolButtonRow {
            ToolButton {
                text: tr("paste")
                onClicked: {
                    var t = clipboard.text();
                    if (t == "")
                        return;
                    if (pasteTranslates) {
                        source.text = t;
                        translate();
                    } else {
                        source.text = source.text + t;
                    }
                }
            }
            ToolButton {
                text: tr("copy")
                enabled: translation != ""
                onClicked: {
                    clipboard.setText(translation);
                    appWindow.showBanner(tr("copied"));
                }
            }
        }
        ToolIcon {
            iconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    function pickLanguage(isSource) {
        var p = pageStack.push(Qt.resolvedUrl("LanguagePage.qml"),
                               { "service": service, "isSource": isSource, "current": isSource ? fromCode : toCode });
        p.picked.connect(function(code) {
            if (isSource)
                setFrom(code);
            else
                setTo(code);
            if (translation != "")
                translate();        // show the result in the new language right away
        });
    }

    // settings changed on SettingsPage
    function reloadSettings() {
        var text = source.text;
        enterTranslates = settings.get("enterKey", "false") == "true";
        source.text = text;
        pasteTranslates = settings.get("pasteGo", "true") == "true";
        useFallback = settings.get("useFallback", "true") == "true";
        useOffline = settings.get("useOffline", "true") == "true";
    }
}

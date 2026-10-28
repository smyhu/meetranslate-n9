import QtQuick 1.1
import com.nokia.meego 1.0
import "strings.js" as S
import "translator.js" as T

// offline dictionaries: installed ones, downloads in progress, new download
Page {
    id: page
    property string newFrom: "en"
    property string newTo: "pl"

    function tr(key) { return S.t(uiLang, key); }
    function pairName(pair) {
        var p = pair.split("-");
        return T.languageName(uiLang, T.googleCode(p[0])) + " → " + T.languageName(uiLang, T.googleCode(p[1]));
    }
    function megabytes(bytes) { return (bytes / 1048576).toFixed(1) + " MB"; }

    // rows are updated in place: clearing the model on every progress step
    // left it empty for a moment and the whole section jumped
    function refresh() {
        var rows = [];
        var busy = JSON.parse(dicts.status());
        for (var pair in busy) {
            var b = busy[pair];
            var info = b.stage == "prepare" ? tr("preparing")
                     : tr("downloading").replace("%1", b.total > 0 ? Math.round(100 * b.got / b.total) + "%" : megabytes(b.got));
            rows.push({ "pair": pair, "info": info, "busy": true });
        }
        var installed = JSON.parse(dicts.installed());
        for (var i = 0; i < installed.length; ++i)
            rows.push({ "pair": installed[i].pair, "info": megabytes(installed[i].size), "busy": false });

        var same = rows.length == dictList.count;
        for (var j = 0; same && j < rows.length; ++j)
            same = dictList.get(j).pair == rows[j].pair && dictList.get(j).busy == rows[j].busy;
        if (same) {
            for (var k = 0; k < rows.length; ++k)
                if (dictList.get(k).info != rows[k].info)
                    dictList.setProperty(k, "info", rows[k].info);
            return;
        }
        while (dictList.count > rows.length)
            dictList.remove(dictList.count - 1);
        for (var m = 0; m < rows.length; ++m) {
            if (m < dictList.count)
                dictList.set(m, rows[m]);
            else
                dictList.append(rows[m]);
        }
    }

    function listed(pair) {
        for (var i = 0; i < dictList.count; ++i)
            if (dictList.get(i).pair == pair)
                return true;
        return false;
    }

    Component.onCompleted: refresh()

    Connections {
        target: dicts
        onChanged: {
            var e;
            while ((e = dicts.takeEvent()) != "") {
                e = JSON.parse(e);
                if (e.ok)
                    appWindow.showBanner(page.tr("installedOk").replace("%1", page.pairName(e.pair)));
                else if (e.error != "cancelled")
                    appWindow.showBanner(page.tr("installFail").replace("%1", e.error));
            }
            page.refresh();
        }
    }

    ListModel { id: dictList }

    Rectangle {
        id: titleBar
        height: appWindow.inPortrait ? 72 : 64
        anchors { left: parent.left; right: parent.right; top: parent.top }
        gradient: Gradient {
            GradientStop { position: 0.0; color: appWindow.headerTop }
            GradientStop { position: 1.0; color: appWindow.headerBottom }
        }
        Label {
            text: tr("dictionaries")
            color: "white"
            font.pixelSize: 32
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
        }
    }

    Flickable {
        id: flick
        clip: true
        anchors { top: titleBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom
                  leftMargin: 16; rightMargin: 16 }
        contentHeight: column.height + 32

        Column {
            id: column
            width: parent.width
            y: 16
            spacing: 16

            Label {
                width: parent.width
                text: tr("dictHint")
                wrapMode: Text.Wrap
                font.pixelSize: 22
                color: "#8c8c8c"
            }

            SectionLabel { text: tr("newDict") }

            Row {
                width: parent.width
                spacing: 8
                LanguageButton {
                    width: (parent.width - 8) / 2
                    title: tr("from")
                    value: T.languageName(uiLang, T.googleCode(newFrom))
                    onClicked: page.pick(true)
                }
                LanguageButton {
                    width: (parent.width - 8) / 2
                    title: tr("to")
                    value: T.languageName(uiLang, T.googleCode(newTo))
                    onClicked: page.pick(false)
                }
            }

            Button {
                width: parent.width
                text: tr("download")
                enabled: newFrom != newTo && !page.listed(newFrom + "-" + newTo)
                platformStyle: ButtonStyle { inverted: !theme.inverted }
                onClicked: {
                    if (!net.online()) {
                        appWindow.showBanner(tr("noInternet"));
                        return;
                    }
                    dicts.install(newFrom + "-" + newTo);
                    page.refresh();
                }
            }

            SectionLabel { text: tr("installed") }

            Label {
                visible: dictList.count == 0
                text: tr("none")
                font.pixelSize: 24
                color: "#8c8c8c"
            }

            Repeater {
                model: dictList
                delegate: Item {
                    width: column.width
                    height: 80
                    Column {
                        anchors { left: parent.left; right: action.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        Label {
                            width: parent.width
                            text: page.pairName(pair)
                            font.pixelSize: 26
                            elide: Text.ElideRight
                        }
                        Label {
                            text: info
                            font.pixelSize: 20
                            color: busy ? appWindow.accent : "#8c8c8c"
                        }
                    }
                    Button {
                        id: action
                        width: 170
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: busy ? page.tr("cancel") : page.tr("remove")
                        onClicked: {
                            if (busy)
                                dicts.cancel(pair);
                            else
                                dicts.remove(pair);
                            page.refresh();
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: flick }

    function pick(isSource) {
        var p = pageStack.push(Qt.resolvedUrl("LanguagePage.qml"),
                               { "service": "offline", "isSource": isSource,
                                 "current": T.googleCode(isSource ? newFrom : newTo) });
        p.picked.connect(function(code) {
            if (isSource)
                newFrom = T.wikdictCode(code);
            else
                newTo = T.wikdictCode(code);
        });
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}

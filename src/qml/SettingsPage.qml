import QtQuick 1.1
import com.nokia.meego 1.0
import "strings.js" as S

Page {
    id: page
    signal changed

    function option(key, def) { return settings.get(key, def) == "true"; }

    Rectangle {
        id: titleBar
        height: appWindow.inPortrait ? 72 : 64
        anchors { left: parent.left; right: parent.right; top: parent.top }
        gradient: Gradient {
            GradientStop { position: 0.0; color: appWindow.headerTop }
            GradientStop { position: 1.0; color: appWindow.headerBottom }
        }
        Label {
            text: S.t(uiLang, "settings")
            color: "white"
            font.pixelSize: 32
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
        }
    }

    Flickable {
        id: flick
        clip: true
        anchors { top: titleBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16 }
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: 24

            Repeater {
                model: ListModel {
                    ListElement { key: "darkTheme"; def: "false" }
                    ListElement { key: "useFallback"; def: "true" }
                    ListElement { key: "useOffline"; def: "true" }
                    ListElement { key: "enterKey"; def: "false" }
                    ListElement { key: "pasteGo"; def: "true" }
                }
                delegate: Item {
                    width: column.width
                    height: Math.max(sw.height, label.paintedHeight)
                    Label {
                        id: label
                        text: S.t(uiLang, key)
                        wrapMode: Text.Wrap
                        font.pixelSize: 26
                        anchors { left: parent.left; right: sw.left; rightMargin: 16; verticalCenter: parent.verticalCenter }
                    }
                    Switch {
                        id: sw
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        checked: page.option(key, def)
                        onCheckedChanged: {
                            settings.set(key, checked ? "true" : "false");
                            if (key == "darkTheme")
                                theme.inverted = checked;
                            page.changed();
                        }
                    }
                }
            }
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}

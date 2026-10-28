import QtQuick 1.1
import com.nokia.meego 1.0
import "strings.js" as S
import "translator.js" as T

// list of languages with a search field
Page {
    id: page
    property string service: "google"
    property bool isSource: true
    property string current: ""
    signal picked(string code)

    function fill() {
        langModel.clear();
        var q = search.text.toLowerCase();
        var list = T.languages(uiLang, service, isSource);
        for (var i = 0; i < list.length; ++i) {
            if (q == "" || list[i].name.toLowerCase().indexOf(q) >= 0 || list[i].code.toLowerCase() == q)
                langModel.append(list[i]);
        }
    }

    Component.onCompleted: {
        fill();
        for (var i = 0; i < langModel.count; ++i)
            if (langModel.get(i).code == current) {
                view.positionViewAtIndex(i, ListView.Center);
                break;
            }
    }

    ListModel { id: langModel }

    Rectangle {
        id: titleBar
        height: appWindow.inPortrait ? 72 : 64
        anchors { left: parent.left; right: parent.right; top: parent.top }
        gradient: Gradient {
            GradientStop { position: 0.0; color: appWindow.headerTop }
            GradientStop { position: 1.0; color: appWindow.headerBottom }
        }
        Label {
            text: S.t(uiLang, isSource ? "from" : "to")
            color: "white"
            font.pixelSize: 32
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
        }
    }

    TextField {
        id: search
        placeholderText: S.t(uiLang, "searchLang")
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        anchors { top: titleBar.bottom; left: parent.left; right: parent.right; margins: 16 }
        onTextChanged: page.fill()
    }

    ListView {
        id: view
        clip: true
        model: langModel
        anchors { top: search.bottom; topMargin: 8; left: parent.left; right: parent.right; bottom: parent.bottom }
        delegate: Item {
            width: view.width
            height: 72
            Rectangle {
                anchors.fill: parent
                color: theme.inverted ? "#ffffff" : "#000000"
                opacity: 0.1
                visible: mouse.pressed
            }
            Label {
                text: name
                font.pixelSize: 26
                font.bold: code == page.current
                color: code == page.current ? appWindow.accent : (theme.inverted ? "#ffffff" : "#000000")
                elide: Text.ElideRight
                anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: {
                    page.picked(code);
                    pageStack.pop();
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}

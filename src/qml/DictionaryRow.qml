import QtQuick 1.1
import com.nokia.meego 1.0

// one row of the dictionary: a part-of-speech header or a word with its
// reverse translations (model roles: kind, word, reverse)
Item {
    id: row
    signal clicked

    height: kind == "header" ? 48 : Math.max(56, column.height + 16)

    Label {
        visible: kind == "header"
        text: word
        font.pixelSize: 20
        font.bold: true
        color: appWindow.accent
        anchors { left: parent.left; leftMargin: 8; bottom: parent.bottom; bottomMargin: 6 }
    }
    Rectangle {
        visible: kind == "header"
        height: 1
        color: appWindow.accent
        opacity: 0.6
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
    }
    Rectangle {
        anchors.fill: parent
        color: theme.inverted ? "#ffffff" : "#000000"
        opacity: 0.1
        visible: mouse.pressed && kind == "entry"
    }
    Column {
        id: column
        visible: kind == "entry"
        anchors { left: parent.left; right: parent.right; leftMargin: 8; rightMargin: 8; verticalCenter: parent.verticalCenter }
        Label {
            width: parent.width
            text: word
            font.pixelSize: 24
            wrapMode: Text.Wrap
        }
        Label {
            width: parent.width
            visible: reverse != ""
            text: reverse
            font.pixelSize: 20
            color: "#8c8c8c"
            wrapMode: Text.Wrap
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: kind == "entry"
        onClicked: row.clicked()
    }
}

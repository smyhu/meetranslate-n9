import QtQuick 1.1
import com.nokia.meego 1.0

// "From" / "To" field: small title, language name and a combobox arrow
Item {
    id: root
    property string title
    property string value
    signal clicked

    height: 72

    BorderImage {
        anchors.fill: parent
        source: mouse.pressed ? style.pressedBackground : style.background
        border { left: 10; top: 10; right: 10; bottom: 10 }
        ButtonStyle { id: style }
    }
    Column {
        anchors { left: parent.left; leftMargin: 14; right: arrow.left; rightMargin: 4; verticalCenter: parent.verticalCenter }
        Label {
            width: parent.width
            text: root.title
            font.pixelSize: 18
            color: "#8c8c8c"
        }
        Label {
            width: parent.width
            text: root.value
            font.pixelSize: 22
            font.bold: true
            elide: Text.ElideRight
        }
    }
    Image {
        id: arrow
        source: theme.inverted ? "image://theme/meegotouch-combobox-indicator-inverted"
                               : "image://theme/meegotouch-combobox-indicator"
        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: root.clicked()
    }
}

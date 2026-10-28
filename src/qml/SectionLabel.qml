import QtQuick 1.1
import com.nokia.meego 1.0

// section title with a line, as in the N9 settings
Item {
    property alias text: label.text
    width: parent.width
    height: 40
    Label {
        id: label
        font.pixelSize: 20
        font.bold: true
        color: appWindow.accent
        anchors { left: parent.left; bottom: parent.bottom; bottomMargin: 6 }
    }
    Rectangle {
        height: 1
        color: appWindow.accent
        opacity: 0.6
        anchors { left: label.right; leftMargin: 12; right: parent.right; verticalCenter: label.verticalCenter }
    }
}

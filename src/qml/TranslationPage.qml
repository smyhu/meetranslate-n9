import QtQuick 1.1
import com.nokia.meego 1.0

// whole translation in a read-only text area, so parts of it can be selected and copied
Page {
    id: page
    property string text

    Flickable {
        id: flick
        anchors { fill: parent; margins: 16 }
        contentHeight: area.height
        clip: true
        TextArea {
            id: area
            width: parent.width
            text: page.text
            readOnly: true
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}

import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

ComboBox {
    id: control
    implicitWidth: 120
    implicitHeight: Theme.componentHeight
    font.pixelSize: Theme.fontSizeComponent

    contentItem: Text {
        leftPadding: 16
        rightPadding: 8

        text: control.displayText
        font: control.font
        color: Theme.colorComponentContent
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
        radius: Theme.componentRadius
        //border.color: control.pressed ? "#17a81a" : "#21be2b"
        //border.width: control.visualFocus ? 2 : 1
    }

    popup: Popup {
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 0

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: "white"
            //border.color: Theme.colorComponent
        }
    }
}

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
        textFormat: Text.PlainText
        font: control.font
        color: Theme.colorComponentContent
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
        //border.color: Theme.colorComponentBorder
        //border.width: control.visualFocus ? 0 : Theme.componentBorderWidth
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
            radius: Theme.componentRadius
            color: "white"
        }
    }
}

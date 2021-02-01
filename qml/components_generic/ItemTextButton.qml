import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemTextButton
    implicitWidth: 40
    implicitHeight: 40

    // states
    signal clicked()
    signal longClicked()
    property bool highlighted: false
    property bool selected: false

    // settings
    property int btnSize: height
    property int txtSize: (height * 0.4)

    property bool background: false
    property string backgroundColor: Theme.colorComponent

    property bool border: false
    property string borderColor: Theme.colorComponentBorder

    property string highlightMode: "circle" // circle / color / both / off
    property string highlightColor: Theme.colorPrimary

    property string text: "btn"
    property string textColor: Theme.colorText

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: bgRect
        onClicked: itemTextButton.clicked()
        onPressAndHold: itemTextButton.longClicked()

        hoverEnabled: true
        onEntered: {
            itemTextButton.highlighted = true
            bgRect.opacity = (highlightMode === "circle" || highlightMode === "both" || itemTextButton.background) ? 1 : 0.75
        }
        onExited: {
            itemTextButton.highlighted = false
            bgRect.opacity = itemTextButton.background ? 0.75 : 0
        }
    }

    Rectangle {
        id: bgRect
        width: btnSize
        height: btnSize
        radius: btnSize
        anchors.verticalCenter: itemTextButton.verticalCenter

        visible: (highlightMode === "circle" || highlightMode === "both" || itemTextButton.background)
        color: itemTextButton.backgroundColor

        border.width: itemTextButton.border ? 1 : 0
        border.color: itemTextButton.borderColor

        opacity: itemTextButton.background ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    Text {
        id: contentImage
        anchors.centerIn: bgRect

        text: itemTextButton.text
        font.bold: true
        font.pixelSize: itemTextButton.txtSize
        font.capitalization: Font.AllUppercase

        opacity: itemTextButton.enabled ? 1.0 : 0.75
        color: {
            if (selected === true) {
                itemTextButton.highlightColor
            } else if (highlightMode === "color" || highlightMode === "both") {
                itemTextButton.highlighted ? itemTextButton.highlightColor : itemTextButton.textColor
            } else {
                itemTextButton.textColor
            }
        }
    }
}

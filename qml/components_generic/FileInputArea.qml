import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.3

import ThemeEngine 1.0
import "qrc:/js/UtilsPath.js" as UtilsPath

TextField {
    id: folderArea
    implicitWidth: 128
    implicitHeight: Theme.componentHeight

    property string colorText: Theme.colorComponentText
    property string colorPlaceholderText: Theme.colorSubText
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorComponentBackground

    property alias buttonWidth: button_change.width

    ////////////////////////////////////////////////////////////////////////////

    property alias folder: folderArea.text
    property alias file: fileArea.text
    property alias extension: extensionArea.text

    signal pathChanged(var path)

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText

    color: colorText
    font.pixelSize: Theme.fontSizeComponent

    onEditingFinished: {
        pathChanged(folderArea.text + fileArea.text + "." + extensionArea.text)
        focus = false
    }

    FileDialog {
        id: fileDialogChange
        title: qsTr("Please choose a destination!")
        sidebarVisible: true
        selectExisting: true
        selectMultiple: false
        selectFolder: true

        onAccepted: {
            var f = UtilsPath.cleanUrl(fileDialogChange.fileUrl)
            if (f.slice(0, -1) !== "/") f += "/"

            folderArea.text = f
            pathChanged(folderArea.text + fileArea.text + "." + extensionArea.text)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: colorBackground
        radius: Theme.componentRadius

        Button {
            id: button_change
            anchors.right: parent.right
            width: contentText.contentWidth + (contentText.contentWidth / 2)
            height: Theme.componentHeight

            font.pixelSize: Theme.fontSizeComponent
            focusPolicy: Qt.NoFocus

            onClicked: {
                fileDialogChange.folder =  "file:///" + folderArea.text
                fileDialogChange.open()
            }

            background: Rectangle {
                radius: Theme.componentRadius
                opacity: enabled ? 1 : 0.33
                color: button_change.down ? Theme.colorComponentDown : Theme.colorComponent
            }

            contentItem: Text {
                id: contentText
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("change")
                textFormat: Text.PlainText
                font: button_change.font
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                opacity: enabled ? 1.0 : 0.33
                color: button_change.down ? Theme.colorComponentContent : Theme.colorComponentContent
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: Theme.componentRadius
            border.width: 2
            border.color: (folderArea.activeFocus || fileArea.activeFocus) ? Theme.colorPrimary : colorBorder
        }

        layer.enabled: false
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: background.x
                y: background.y
                width: background.width
                height: background.height
                radius: background.radius
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    TextInput {
        id: fileArea
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: folderArea.contentWidth + 12
        width: folderArea.width - x

        color: Theme.colorSubText
        verticalAlignment: Text.AlignVCenter

        onEditingFinished: {
            pathChanged(folderArea.text + fileArea.text + "." + extensionArea.text)
            focus = false
        }
    }

    Text {
        id: dot
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: folderArea.contentWidth + 12 + fileArea.contentWidth + 1

        text: "."
        color: Theme.colorSubText
        verticalAlignment: Text.AlignVCenter
    }
    Text {
        id: extensionArea
        anchors.top: parent.top
        anchors.left: dot.right
        anchors.leftMargin: 1
        anchors.bottom: parent.bottom
        color: Theme.colorSubText
        verticalAlignment: Text.AlignVCenter
    }
}

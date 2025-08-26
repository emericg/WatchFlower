import QtQuick
import QtQuick.Controls

import ComponentLibrary
import SmartCare

Item {
    id: devicePlantSensorCare

    function loadData() {
        plantInfos.visible = false
        plantLimits.visible = true
        plantJournal.visible = false

        updateSize()
    }

    function updateHeader() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("devicePlantSensorCare // updateHeader() >> " + currentDevice)
    }

    function updateLimits() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("devicePlantSensorCare // updateLimits() >> " + currentDevice)

        plantLimits.updateLimits()
    }

    function backAction() {
        if (plantJournal.visible) {
            plantJournal.backAction()
            return
        }

        screenDeviceList.loadScreen()
    }

    onWidthChanged: updateSize()
    //onHeightChanged: updateSize()

    function updateSize() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.isPlantSensor) return

        // grid geometry
        if (isMobile) {
            if (isPhone) {
                if (screenOrientation === Qt.PortraitOrientation) {
                    subHeader.visible = true
                    subHeader.height = 48
                } else {
                    subHeader.visible = false
                    subHeader.height = 0
                }
            }
            else if (isTablet) {
                if (devicePlantSensorCare.width < 575) {
                    buttonPanel.anchors.rightMargin = 0
                    buttonPanel.anchors.right = undefined
                    buttonPanel.anchors.horizontalCenter = subHeader.horizontalCenter
                    subHeader.height = 52
                } else {
                    buttonPanel.anchors.rightMargin = 12
                    buttonPanel.anchors.horizontalCenter = undefined
                    buttonPanel.anchors.right = subHeader.right
                    subHeader.height = 52
                }
            }
        } else { // isDesktop
            if (devicePlantSensorCare.width < 575) {
                buttonPanel.anchors.rightMargin = 0
                buttonPanel.anchors.right = undefined
                buttonPanel.anchors.horizontalCenter = subHeader.horizontalCenter
                subHeader.height = 52
            } else {
                buttonPanel.anchors.rightMargin = 12
                buttonPanel.anchors.horizontalCenter = undefined
                buttonPanel.anchors.right = subHeader.right
                subHeader.height = 52
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: subHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: isPhone ? 48 : 52
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

        Text {
            id: textDeviceName
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            visible: (!isPhone && devicePlantSensorCare.width >= 575)

            text: {
                if (currentDevice.devicePlantName.length)
                    return currentDevice.deviceName + " - " + currentDevice.devicePlantName
                return currentDevice.deviceName
            }
            color: Theme.colorText
            font.pixelSize: 24
            //font.capitalization: Font.Capitalize
            horizontalAlignment: wideMode ? Text.AlignLeft : Text.AlignHCenter
        }

        Row {
            id: buttonPanel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMargin

            ButtonClear {
                width: 100
                height: isPhone ? 32 : 36

                color: Theme.colorPrimary
                colorBackground: plantInfos.visible ? color : Qt.rgba(color.r, color.g, color.b, 0.2)
                colorText: plantInfos.visible ? "white" : color

                text: qsTr("Plant")
                onClicked: {
                    plantInfos.visible = true
                    plantInfos.load()
                    plantLimits.visible = false
                    plantJournal.visible = false
                }
            }

            ButtonClear {
                width: 100
                height: isPhone ? 32 : 36

                color: Theme.colorPrimary
                colorBackground: plantLimits.visible ? color : Qt.rgba(color.r, color.g, color.b, 0.2)
                colorText: plantLimits.visible ? "white" : color

                text: qsTr("Limits")
                onClicked: {
                    plantInfos.visible = false
                    plantLimits.visible = true
                    plantJournal.visible = false
                }
            }

            ButtonClear {
                width: 100
                height: isPhone ? 32 : 36

                color: Theme.colorPrimary
                colorBackground: plantJournal.visible ? color : Qt.rgba(color.r, color.g, color.b, 0.2)
                colorText: plantJournal.visible ? "white" : color

                text: qsTr("Journal")
                onClicked: {
                    plantInfos.visible = false
                    plantLimits.visible = false
                    plantJournal.visible = true
                    plantJournal.load()
                }
            }
        }

        Rectangle { // bottom separator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (isDesktop && !headerUnicolor)
            height: 2
            opacity: 0.5
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////
/*
    Grid {
        anchors.top: subHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
*/
    ////////////////////////////////////////////////////////////////////////////

    PlantCareInfos {
        id: plantInfos
        anchors.top: subHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    ////////////////////////////////////////////////////////////////////////////

    PlantCareLimits {
        id: plantLimits
        anchors.top: subHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    ////////////////////////////////////////////////////////////////////////////

    PlantCareJournal {
        id: plantJournal
        anchors.top: subHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}

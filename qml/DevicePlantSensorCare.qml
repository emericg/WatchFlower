import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

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

    property bool outsideMode: (currentDevice && currentDevice.deviceIsOutside)

    onWidthChanged: updateSize()
    //onHeightChanged: updateSize()

    function updateSize() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        if (!currentDevice.hasSoilMoistureSensor) return
        //console.log("width: " + graphGrid.width)
        //console.log("height: " + graphGrid.height)

        // grid geometry
        if (isMobile) {
            if (isPhone) {
                if (screenOrientation === Qt.PortraitOrientation) {
                    //graphGrid.columns = 1
                    rectangleHeader.visible = true
                    rectangleHeader.height = 48
                } else {
                    //graphGrid.columns = 2
                    rectangleHeader.visible = false
                    rectangleHeader.height = 0
                }
            }
            //if (isTablet) {
            //    if (screenOrientation === Qt.PortraitOrientation || width < 480) {
            //        graphGrid.columns = 1
            //    } else {
            //        graphGrid.columns = 2
            //    }
            //}
        } else {
            //if (graphGrid.width < 1080) {
            //    graphGrid.columns = 1
            //} else {
            //    graphGrid.columns = 2
            //}
            if (devicePlantSensorCare.width < 575) {
                buttonPanel.anchors.topMargin = 52
                buttonPanel.anchors.rightMargin = 0
                buttonPanel.anchors.right = undefined
                buttonPanel.anchors.horizontalCenter = rectangleHeader.horizontalCenter
                rectangleHeader.height = 96
            } else {
                buttonPanel.anchors.topMargin = 8
                buttonPanel.anchors.rightMargin = 8
                buttonPanel.anchors.horizontalCenter = undefined
                buttonPanel.anchors.right = rectangleHeader.right
                rectangleHeader.height = 48
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: rectangleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: isPhone ? 96 : 48
        color: headerUnicolor ? Theme.colorBackground : Theme.colorForeground

        Text {
            id: textDeviceName
            height: 32
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12

            visible: isDesktop

            text: currentDevice.deviceName + " - " + currentDevice.devicePlantName
            color: Theme.colorText
            font.pixelSize: 22
            font.capitalization: Font.Capitalize
            horizontalAlignment: wideMode ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Row {
            id: buttonPanel
            anchors.top: parent.top
            anchors.topMargin: isMobile ? 8 : 52
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (plantInfos.visible)
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Plant")
                onClicked: {
                    plantInfos.visible = true
                    plantLimits.visible = false
                    plantJournal.visible = false
                }
            }

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (plantLimits.visible)
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Limits")
                onClicked: {
                    plantInfos.visible = false
                    plantLimits.visible = true
                    plantJournal.visible = false
                }
            }

            ButtonWireframe {
                width: 100
                height: 32

                fullColor: (plantJournal.visible)
                primaryColor: Theme.colorPrimary
                secondaryColor: Theme.colorBackground

                text: qsTr("Journal")
                onClicked: {
                    plantInfos.visible = false
                    plantLimits.visible = false
                    plantJournal.visible = true
                    plantJournal.load()
                }
            }
        }

        Rectangle {
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
        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
*/
    ////////////////////////////////////////////////////////////////////////////

    PlantCareInfos {
        id: plantInfos
        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    ////////////////////////////////////////////////////////////////////////////

    PlantCareLimits {
        id: plantLimits
        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    ////////////////////////////////////////////////////////////////////////////

    PlantCareJournal {
        id: plantJournal
        anchors.top: rectangleHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}

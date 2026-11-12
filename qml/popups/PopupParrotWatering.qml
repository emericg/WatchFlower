import QtQuick
import QtQuick.Effects
import QtQuick.Controls.Basic

import ComponentLibrary
import DeviceUtils

Popup {
    id: popupParrotWatering

    x: Theme.singleColumn ? 0 : (appWindow.width / 2) - (width / 2)
    y: Theme.singleColumn ? (appWindow.height - height)
                          : ((appWindow.height / 2) - (height / 2))

    width: Theme.singleColumn ? appWindow.width : 720
    height: Math.min(columnContent.height + topPadding + bottomPadding, maxHeight)
    padding: Theme.componentMarginXL
    bottomPadding: Theme.componentMarginXL + Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

    readonly property int maxHeight: Theme.singleColumn ?
        appWindow.height - Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop) - Theme.componentHeightXL :
        appWindow.height - Theme.componentMarginXL*2
    margins: 0

    dim: true
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    ////////////////////////////////////////////////////////////////////////////

    property var device: null           // the Parrot Pot being configured
    property bool saving: false
    property bool saveFailed: false

    property int wateringMode: 1        // 1: manual, 2: perfect drop, 3: plant sitter, 4: custom
    property int wateringThreshold: 10  // soil moisture, in %
    property int wateringTarget: 38     // soil moisture, in %
    property int wateringDelay: 0       // wait once the threshold is reached, before watering, in hours, 0: disabled
    property int wateringNeed: 38       // plant water need (reference soil moisture), in %

    readonly property int wateringNeedMin: 29
    readonly property int wateringNeedMax: 41
    readonly property int wateringNeedDefault: 38
    readonly property int wateringBandLow: (wateringMode === 3) ? wateringNeed - 6 : wateringNeed
    readonly property int wateringBandHigh: (wateringMode === 3) ? wateringNeed : wateringNeed + 6

    readonly property bool canSave: (device && !saving && device.status <= DeviceUtils.DEVICE_AVAILABLE)

    onAboutToShow: loadSettings()

    /*!
     * Load the device watering settings, and the water need kept locally.
     * The device doesn't store a mode, so it is inferred from its settings:
     * manual when automatic watering is off, perfect drop or plant sitter when the bounds
     * are the band around the water need, with no delay, and custom otherwise.
     */
    function loadSettings() {
        saving = false
        saveFailed = false

        wateringNeed = wateringNeedDefault
        wateringThreshold = 10
        wateringTarget = 38
        wateringDelay = 0
        wateringMode = 1

        if (!device) return

        if (device.hasSetting("watering_need")) {
            const need = Number(device.getSetting("watering_need"))
            if (need >= wateringNeedMin && need <= wateringNeedMax) wateringNeed = need
        }

        if (!device.hasWateringSettings) return

        wateringThreshold = Math.round(device.wateringThreshold)
        wateringTarget = Math.round(device.wateringTarget)
        wateringDelay = device.wateringDelay

        if (!device.wateringAuto) wateringMode = 1
        else if (wateringDelay === 0 && wateringThreshold === wateringNeed && wateringTarget === wateringNeed + 6) wateringMode = 2
        else if (wateringDelay === 0 && wateringThreshold === wateringNeed - 6 && wateringTarget === wateringNeed) wateringMode = 3
        else wateringMode = 4
    }

    function saveSettings() {
        if (!canSave) return

        let enabled = true
        let threshold = wateringThreshold
        let target = wateringTarget
        let delay = wateringDelay

        if (wateringMode === 1) {
            enabled = false
        } else if (wateringMode === 2 || wateringMode === 3) {
            threshold = wateringBandLow
            target = wateringBandHigh
            delay = 0
        }

        saving = device.actionWateringSettings(enabled, threshold, target, delay)
        saveFailed = !saving
    }

    Connections {
        target: popupParrotWatering.device
        ignoreUnknownSignals: true

        function onWateringSettingsSaved(success) {
            if (!popupParrotWatering.saving) return
            popupParrotWatering.saving = false
            popupParrotWatering.saveFailed = !success

            if (success) {
                popupParrotWatering.device.setSetting("watering_need", popupParrotWatering.wateringNeed)
                popupParrotWatering.close()
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.5; to: 1.0; duration: 133; } }
    //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.24 : 0.48
    }

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.singleColumn ? 0 : Theme.componentBorderWidth
        radius: Theme.singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.componentBorderWidth
            visible: Theme.singleColumn
            color: Theme.colorSeparator
        }

        layer.enabled: !Theme.singleColumn
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            blurMax: 48
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#cc000000"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Flickable {
        contentWidth: width
        contentHeight: columnContent.height

        clip: interactive
        interactive: (contentHeight > height)
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: columnContent
            width: parent.width
            spacing: Theme.componentMargin

            ////////

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTr("Watering settings")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            ////////

            Column { // mode selection
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXS

                Repeater {
                    model: ListModel {
                        ListElement {
                            idx: 1
                            title: qsTr("Manual")
                            desc: qsTr("The pot only waters your plant when you ask it to.")
                        }
                        ListElement {
                            idx: 2
                            title: qsTr("Perfect drop")
                            desc: qsTr("The pot keeps the soil moisture just above what your plant needs.")
                        }
                        ListElement {
                            idx: 3
                            title: qsTr("Plant sitter")
                            desc: qsTr("The pot keeps the soil moisture just below what your plant needs, using less water. Best while you are away.")
                        }
                        ListElement {
                            idx: 4
                            title: qsTr("Custom")
                            desc: qsTr("The pot waters your plant using your own soil moisture levels.")
                        }
                    }

                    delegate: Rectangle {
                        id: modeDelegate
                        required property var model

                        readonly property bool selected: (popupParrotWatering.wateringMode === modeDelegate.model.idx)

                        width: parent.width
                        height: modeTexts.height + Theme.componentMargin*2
                        radius: Theme.componentRadius

                        color: modeDelegate.selected ? Theme.colorForeground : "transparent"
                        border.width: Theme.componentBorderWidth
                        border.color: modeDelegate.selected ? Theme.colorSecondary : Theme.colorSeparator

                        Rectangle { // indicator
                            id: modeIndicator
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            width: 24
                            height: 24
                            radius: 12

                            color: Theme.colorComponentBackground
                            border.width: Theme.componentBorderWidth
                            border.color: modeDelegate.selected ? Theme.colorSecondary : Theme.colorComponentBorder

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 6

                                color: Theme.colorSecondary
                                opacity: modeDelegate.selected ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: Theme.animationSpeedFast } }
                            }
                        }

                        Column {
                            id: modeTexts
                            anchors.left: modeIndicator.right
                            anchors.leftMargin: Theme.componentMargin
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                text: modeDelegate.model.title
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                text: modeDelegate.model.desc
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentSmall
                                color: Theme.colorSubText
                                wrapMode: Text.WordWrap
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: popupParrotWatering.wateringMode = modeDelegate.model.idx
                        }
                    }
                }
            }

            ////////

            Column { // water need, for perfect drop and plant sitter
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXS

                visible: (popupParrotWatering.wateringMode === 2 || popupParrotWatering.wateringMode === 3)

                Item { // default marker
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: textDefault.height + tickDefault.height + 2

                    readonly property real defaultX: sliderWaterNeed.leftPadding +
                        ((popupParrotWatering.wateringNeedDefault - sliderWaterNeed.from) / (sliderWaterNeed.to - sliderWaterNeed.from)) *
                        (sliderWaterNeed.availableWidth - sliderWaterNeed.handle.width) + (sliderWaterNeed.handle.width / 2)

                    Text {
                        id: textDefault
                        x: Math.max(0, Math.min(parent.width - width, parent.defaultX - (width / 2)))

                        text: qsTr("Default")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentSmall
                        color: Theme.colorSubText
                    }
                    Rectangle {
                        id: tickDefault
                        x: parent.defaultX - (width / 2)
                        anchors.bottom: parent.bottom

                        width: 2
                        height: 6
                        radius: 1
                        color: Theme.colorSubText
                    }
                }

                SliderValueSolid {
                    id: sliderWaterNeed
                    anchors.left: parent.left
                    anchors.right: parent.right

                    height: 32
                    hhh: 22

                    unit: "%"
                    from: popupParrotWatering.wateringNeedMin
                    to: popupParrotWatering.wateringNeedMax
                    stepSize: 1
                    snapMode: Slider.SnapAlways

                    value: popupParrotWatering.wateringNeed
                    onMoved: popupParrotWatering.wateringNeed = value
                }

                Item { // legend
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.max(textLess.height, textMore.height)

                    Text {
                        id: textLess
                        anchors.left: parent.left
                        anchors.right: parent.horizontalCenter

                        text: qsTr("Less water")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentSmall
                        color: Theme.colorSubText
                        elide: Text.ElideRight
                    }
                    Text {
                        id: textMore
                        anchors.left: parent.horizontalCenter
                        anchors.right: parent.right

                        text: qsTr("More water")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentSmall
                        color: Theme.colorSubText
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    topPadding: Theme.componentMarginS

                    text: qsTr("The pot keeps the soil moisture between %1% and %2%.")
                              .arg(popupParrotWatering.wateringBandLow).arg(popupParrotWatering.wateringBandHigh)
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
            }

            ////////

            Column { // custom settings
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXS

                visible: (popupParrotWatering.wateringMode === 4)

                WateringChart {
                    id: wateringChart
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Theme.singleColumn ? 220 : 280

                    target: popupParrotWatering.wateringTarget
                    threshold: popupParrotWatering.wateringThreshold
                    delay: popupParrotWatering.wateringDelay

                    onTargetEdited: (value) => popupParrotWatering.wateringTarget = value
                    onThresholdEdited: (value) => popupParrotWatering.wateringThreshold = value
                    onDelayEdited: (value) => popupParrotWatering.wateringDelay = value
                }

                LegendRow {
                    dotColor: Theme.colorGreen
                    text: qsTr("Stop watering when soil moisture reaches %1%").arg(popupParrotWatering.wateringTarget)
                }
                LegendRow {
                    dotColor: Theme.colorRed
                    text: qsTr("Water when soil moisture drops below %1%").arg(popupParrotWatering.wateringThreshold)
                }
                LegendRow {
                    dotColor: Theme.colorGrey
                    text: qsTr("Watering delay: %1").arg(wateringChart.formatDelay(popupParrotWatering.wateringDelay))
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Once the soil moisture drops below the threshold, the pot waits for this delay before watering, letting the soil dry a little longer. Move the grey handle back to the threshold to turn the delay off.")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
            }

            ////////

            Item { width: 4; height: 4; } // spacer

            ////////

            Flow {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMargin

                property int btnSize: ((width-spacing) / 2)

                ButtonClear {
                    width: parent.btnSize
                    color: Theme.colorGrey

                    text: qsTr("Cancel")
                    onClicked: popupParrotWatering.close()
                }

                ButtonFlat {
                    width: parent.btnSize

                    enabled: popupParrotWatering.canSave
                    color: popupParrotWatering.saveFailed ? Theme.colorWarning : Theme.colorPrimary
                    text: {
                        if (popupParrotWatering.saving) return qsTr("Saving…")
                        if (popupParrotWatering.saveFailed) return qsTr("Error. Retry?")
                        return qsTr("Save")
                    }
                    onClicked: popupParrotWatering.saveSettings()
                }
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    component LegendRow: Item {
        property alias text: legendText.text
        property alias dotColor: legendDot.color

        anchors.left: parent.left
        anchors.right: parent.right
        height: legendText.height

        Rectangle {
            id: legendDot
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            radius: 6
        }

        Text {
            id: legendText
            anchors.left: legendDot.right
            anchors.leftMargin: Theme.componentMargin
            anchors.right: parent.right

            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
            wrapMode: Text.WordWrap
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}

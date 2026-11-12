import QtQuick
import QtQuick.Shapes

import ComponentLibrary

Item {
    id: wateringChart

    implicitWidth: 400
    implicitHeight: 280

    property int target: 38         // soil moisture, in %
    property int threshold: 10      // soil moisture, in %
    property int delay: 0           // watering delay once the threshold is reached, in hours, 0: disabled

    signal targetEdited(int value)
    signal thresholdEdited(int value)
    signal delayEdited(int value)

    readonly property int moistureMin: 5
    readonly property int moistureMax: 60
    readonly property int delayMin: 0
    readonly property int delayMax: 168

    // Illustrative drying model, the soil moisture decays as target * exp(-dryingRate * days)
    readonly property real dryingRate: 0.25
    readonly property int spanDays: 8

    readonly property real dryDays: Math.max(Math.log(target / Math.max(threshold, 1)) / dryingRate, 0.05)
    readonly property real waterDays: dryDays + (delay / 24)

    readonly property int axisWidth: 40
    readonly property int axisHeight: 24
    readonly property int handleSize: 14

    readonly property real plotLeft: handleSize / 2
    readonly property real plotTop: handleSize
    readonly property real plotWidth: Math.max(1, width - axisWidth - plotLeft)
    readonly property real plotHeight: Math.max(1, height - axisHeight - plotTop)
    readonly property real plotRight: plotLeft + plotWidth
    readonly property real plotBottom: plotTop + plotHeight

    readonly property int labelDaysStep: (plotWidth / spanDays < 28) ? 2 : 1

    readonly property var curvePoints: computeCurve()

    property int dragging: 0        // 0: none, 1: target, 2: threshold, 3: delay

    ////////////////////////////////////////////////////////////////////////////

    function xOf(days) { return plotLeft + (days / spanDays) * plotWidth }
    function yOf(percent) { return plotTop + ((moistureMax - Math.min(percent, moistureMax)) / moistureMax) * plotHeight }
    function daysAt(x) { return ((x - plotLeft) / plotWidth) * spanDays }
    function percentAt(y) { return moistureMax - ((y - plotTop) / plotHeight) * moistureMax }

    function formatDelay(hours) {
        if (hours <= 0) return qsTr("off", "watering delay disabled")
        return qsTr("%1d %2h", "watering delay, in days and hours").arg(Math.floor(hours / 24)).arg(hours % 24)
    }

    function computeCurve() {
        const pts = []
        const period = waterDays

        for (let start = 0; start < spanDays; start += period) {
            const end = Math.min(start + period, spanDays)
            const samples = Math.max(4, Math.ceil((end - start) * 24))
            for (let i = 0; i <= samples; i++) {
                const t = start + ((end - start) * i / samples)
                pts.push(Qt.point(xOf(t), yOf(target * Math.exp(-dryingRate * (t - start)))))
            }
            if (end < spanDays) pts.push(Qt.point(xOf(end), yOf(target)))
        }

        return pts
    }

    ////////////////////////////////////////////////////////////////////////////

    Repeater { // vertical grid, one line per day
        model: wateringChart.spanDays + 1

        Rectangle {
            required property int index

            x: wateringChart.xOf(index)
            y: wateringChart.plotTop
            width: 1
            height: wateringChart.plotHeight
            color: Theme.colorSeparator
        }
    }

    Repeater { // horizontal grid, and moisture labels
        model: (wateringChart.moistureMax / 10) + 1

        Item {
            required property int index
            readonly property int percent: index * 10

            Rectangle {
                x: wateringChart.plotLeft
                y: wateringChart.yOf(parent.percent)
                width: wateringChart.plotWidth
                height: 1
                color: Theme.colorSeparator
            }
            Text {
                x: wateringChart.plotRight + 6
                y: wateringChart.yOf(parent.percent) - (height / 2)

                text: qsTr("%1%").arg(parent.percent)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVerySmall
                color: Theme.colorSubText
            }
        }
    }

    Repeater { // days labels
        model: Math.floor(wateringChart.spanDays / wateringChart.labelDaysStep) + 1

        Text {
            required property int index
            readonly property int day: index * wateringChart.labelDaysStep

            x: wateringChart.xOf(day) - (width / 2)
            y: wateringChart.plotBottom + 6

            text: qsTr("%1d", "days").arg(day)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVerySmall
            color: Theme.colorSubText
        }
    }

    ////////

    Rectangle { // delay period, after the threshold is reached
        x: wateringChart.xOf(wateringChart.dryDays)
        y: wateringChart.plotTop
        width: Math.max(0, Math.min(wateringChart.xOf(wateringChart.waterDays), wateringChart.plotRight) - x)
        height: wateringChart.plotHeight

        visible: (wateringChart.delay > 0 && wateringChart.dryDays < wateringChart.spanDays)
        color: Qt.rgba(Theme.colorGrey.r, Theme.colorGrey.g, Theme.colorGrey.b, 0.16)
    }

    Shape { // simulated soil moisture
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillGradient: LinearGradient {
                x1: 0; y1: wateringChart.plotTop
                x2: 0; y2: wateringChart.plotBottom
                GradientStop { position: 0; color: Qt.rgba(Theme.colorBlue.r, Theme.colorBlue.g, Theme.colorBlue.b, 0.5) }
                GradientStop { position: 1; color: Qt.rgba(Theme.colorBlue.r, Theme.colorBlue.g, Theme.colorBlue.b, 0.05) }
            }

            PathPolyline {
                path: wateringChart.curvePoints.concat([Qt.point(wateringChart.plotRight, wateringChart.plotBottom),
                                                        Qt.point(wateringChart.plotLeft, wateringChart.plotBottom)])
            }
        }
        ShapePath {
            strokeWidth: 2
            strokeColor: Theme.colorBlue
            fillColor: "transparent"

            PathPolyline { path: wateringChart.curvePoints }
        }
    }

    ////////

    Rectangle { // target line
        x: wateringChart.plotLeft
        y: wateringChart.yOf(wateringChart.target) - (height / 2)
        width: wateringChart.plotWidth
        height: 2
        color: Theme.colorGreen
    }
    Rectangle { // threshold line
        x: wateringChart.plotLeft
        y: wateringChart.yOf(wateringChart.threshold) - (height / 2)
        width: wateringChart.plotWidth
        height: 2
        color: Theme.colorRed
    }

    ChartHandle { // target
        labelLimit: wateringChart.plotRight
        cx: wateringChart.plotLeft
        cy: wateringChart.yOf(wateringChart.target)
        color: Theme.colorGreen
        active: (wateringChart.dragging === 1)
        label: qsTr("%1%").arg(wateringChart.target)
        labelBelow: true
    }
    ChartHandle { // threshold
        labelLimit: wateringChart.plotRight
        cx: Math.min(wateringChart.xOf(wateringChart.dryDays), wateringChart.plotRight)
        cy: wateringChart.yOf(wateringChart.threshold)
        color: Theme.colorRed
        active: (wateringChart.dragging === 2)
        label: qsTr("%1%").arg(wateringChart.threshold)
        labelBelow: (wateringChart.threshold > 15)
    }
    ChartHandle { // delay
        labelLimit: wateringChart.plotRight
        cx: Math.min(wateringChart.xOf(wateringChart.waterDays), wateringChart.plotRight)
        cy: wateringChart.plotBottom
        color: Theme.colorGrey
        active: (wateringChart.dragging === 3)
        label: wateringChart.formatDelay(wateringChart.delay)
        labelBelow: false
    }

    component ChartHandle: Rectangle {
        property real cx
        property real cy
        property bool active
        property string label
        property bool labelBelow
        property real labelLimit

        x: cx - (width / 2)
        y: cy - (height / 2)
        width: 14
        height: 14
        radius: width
        scale: active ? 1.33 : 1
        border.width: 2
        border.color: Theme.colorBackground

        Text {
            x: (parent.cx + parent.width + width > parent.labelLimit) ? -width - 4 : parent.width + 4
            y: parent.labelBelow ? parent.height : -height

            text: parent.label
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentSmall
            font.bold: true
            color: parent.color
        }
    }

    ////////

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        cursorShape: (wateringChart.dragging === 3) ? Qt.SizeHorCursor :
                     (wateringChart.dragging !== 0) ? Qt.SizeVerCursor : Qt.ArrowCursor

        onPressed: (mouse) => {
            const tolerance = 24
            const dTarget = Math.abs(mouse.y - wateringChart.yOf(wateringChart.target))
            const dThreshold = Math.abs(mouse.y - wateringChart.yOf(wateringChart.threshold))
            const dDelay = Math.hypot(mouse.x - Math.min(wateringChart.xOf(wateringChart.waterDays), wateringChart.plotRight),
                                      mouse.y - wateringChart.plotBottom)

            let best = 0
            let bestDistance = tolerance
            if (dTarget < bestDistance) { best = 1; bestDistance = dTarget }
            if (dThreshold < bestDistance) { best = 2; bestDistance = dThreshold }
            if (dDelay < bestDistance) { best = 3; bestDistance = dDelay }

            wateringChart.dragging = best
            mouse.accepted = (best !== 0)
        }
        onPositionChanged: (mouse) => {
            if (wateringChart.dragging === 1) {
                const v = Math.round(Math.max(wateringChart.threshold + 1, Math.min(wateringChart.moistureMax, wateringChart.percentAt(mouse.y))))
                if (v !== wateringChart.target) wateringChart.targetEdited(v)
            } else if (wateringChart.dragging === 2) {
                const v = Math.round(Math.max(wateringChart.moistureMin, Math.min(wateringChart.target - 1, wateringChart.percentAt(mouse.y))))
                if (v !== wateringChart.threshold) wateringChart.thresholdEdited(v)
            } else if (wateringChart.dragging === 3) {
                const h = Math.round((wateringChart.daysAt(mouse.x) - wateringChart.dryDays) * 24)
                const v = Math.max(wateringChart.delayMin, Math.min(wateringChart.delayMax, h))
                if (v !== wateringChart.delay) wateringChart.delayEdited(v)
            }
        }
        onReleased: wateringChart.dragging = 0
        onCanceled: wateringChart.dragging = 0
    }
}

import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    implicitWidth: 32
    implicitHeight: 32

    property alias source: sourceImg.source
    property alias fillMode: sourceImg.fillMode
    property string color

    Image {
        id: sourceImg
        anchors.fill: parent
        visible: parent.color ? false : true

        asynchronous: false
        smooth: false

        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        source: sourceImg
        anchors.fill: sourceImg
        visible: parent.color ? true : false

        cached: visible
        color: parent.color
    }
}

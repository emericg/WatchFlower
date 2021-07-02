import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    implicitWidth: 32
    implicitHeight: 32

    property alias source: sourceImg.source
    property alias fillMode: sourceImg.fillMode
    property alias color: overlayImg.color
    property alias asynchronous: sourceImg.asynchronous

    Image {
        id: sourceImg
        anchors.fill: parent
        visible: overlayImg.color ? false : true

        asynchronous: false
        smooth: false

        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        id: overlayImg
        source: sourceImg
        anchors.fill: sourceImg
        visible: parent.color ? true : false

        cached: true
        color: parent.color
    }
}

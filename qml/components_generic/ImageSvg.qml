import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Item {
    implicitWidth: 32
    implicitHeight: 32

    property string source
    property string color
    property int fillMode: Image.PreserveAspectCrop

    Image {
        id: sourceImg
        anchors.fill: parent
        visible: (parent.visible && parent.color) ? false : true

        source: parent.source
        sourceSize: Qt.size(width, height)
        fillMode: parent.fillMode
    }
    ColorOverlay {
        source: sourceImg
        anchors.fill: parent
        visible: (parent.visible && parent.color) ? true : false

        color: parent.color
        cached: visible
    }
}

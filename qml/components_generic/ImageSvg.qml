import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Item {
    implicitWidth: 32
    implicitHeight: 32

    property string source
    property string color
    property int fillMode: Image.PreserveAspectFit

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

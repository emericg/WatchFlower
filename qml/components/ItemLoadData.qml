import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: itemLoadData
    anchors.centerIn: parent

    width: singleColumn ? (parent.width*0.26) : (parent.height*0.26)
    height: width
    radius: width
    color: Theme.colorForeground
    opacity: 0.8

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: width

        source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorSubText
        smooth: true
    }
}

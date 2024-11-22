import QtQuick

import ThemeEngine

Rectangle {
    id: itemLoadData
    anchors.centerIn: parent

    width: singleColumn ? (parent.width*0.26) : (parent.height*0.26)
    height: width
    radius: width
    color: Theme.colorForeground
    opacity: 0.33

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: width

        source: "qrc:/IconLibrary/material-symbols/autorenew.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorSubText
        smooth: true
    }
}

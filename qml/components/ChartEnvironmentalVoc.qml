import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Item {
    id: chartEnvironmentalVoc
    width: parent.width
    height: 400

    function loadGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartEnvironmentalVoc // loadGraph() >> " + currentDevice)
    }

    function updateGraph() {
        if (typeof currentDevice === "undefined" || !currentDevice) return
        //console.log("chartEnvironmentalVoc // loadGraph() >> " + currentDevice)
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: vocLegend
        anchors.fill: parent

        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.bottomMargin: 24

        color: "transparent"
        //border.color: Theme.colorSeparator

        Rectangle {
            id: vocLegendVert
            width: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            color: Theme.colorSeparator

            Rectangle {
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.top: parent.top
                anchors.right: parent.right

                Rectangle {
                    width: vocLegend.width; height: 2;
                    //visible: false
                    opacity: 0.15
                    color: Theme.colorSeparator
                }
            }
            Rectangle {
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.top: parent.top
                anchors.topMargin: parent.height*0.33
                anchors.right: parent.right

                Rectangle {
                    width: vocLegend.width; height: 2;
                    //visible: false
                    opacity: 0.15
                    color: Theme.colorSeparator
                }
            }
            Rectangle {
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.top: parent.top
                anchors.topMargin: parent.height*0.66
                anchors.right: parent.right

                Rectangle {
                    width: vocLegend.width; height: 2;
                    //visible: false
                    opacity: 0.15
                    color: Theme.colorSeparator
                }
            }
            Rectangle {
                width: 6; height: 2;
                color: Theme.colorSeparator
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Rectangle {
                    width: vocLegend.width; height: 2;
                    visible: false
                    opacity: 0.15
                    color: Theme.colorSeparator
                }
            }
        }

        ////////

        Rectangle {
            id: vocLegendHor
            height: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Flickable {
        id: vocFlickable
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.bottomMargin: 26

        contentWidth: vocRow.width
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: vocRow
            height: parent.height
            spacing: 16

            Repeater {
                model: currentDevice.aioEnvData

                Item {
                    height: parent.height
                    width: 16

                    Rectangle {
                        height: parent.height
                        width: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Theme.colorSeparator
                        opacity: 0.15
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom

                        height: (modelData.vocMax / 1500) * parent.height
                        width: 11
                        radius: 11
                        clip: true

                        color: {
                            if (modelData.vocMax > 1000)
                                return Theme.colorOrange
                            else if (modelData.vocMax > 500)
                                return Theme.colorYellow
                            else
                                return Theme.colorGreen
                        }

                        Rectangle {
                            y: (modelData.vocMean / 1500) * parent.height
                            anchors.horizontalCenter: parent.horizontalCenter

                            width: 9
                            height: 9
                            radius: 9
                            color: "white"
                            opacity: 0.8
                        }
/*
                        Rectangle {
                            anchors.top: parent.top
                            anchors.topMargin: 1
                            anchors.horizontalCenter: parent.horizontalCenter

                            height: (modelData.hchoMax / 1500) * parent.height
                            width: 9
                            radius: 9
                            color: "white"
                            opacity: 0.8
                        }
*/
                    }

                    Text {
                        anchors.top: parent.bottom
                        anchors.topMargin: 6
                        anchors.horizontalCenter: parent.horizontalCenter

                        rotation: -45
                        text: modelData.day
                        color: Theme.colorSubText
                        font.pixelSize: (Theme.fontSizeContentSmall - 2)
                    }
                }
            }
        }
    }
}

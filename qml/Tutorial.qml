import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Rectangle {
    width: 480
    height: 640
    anchors.fill: parent

    color: Theme.colorHeader

    property int lastPage: 3
    property string exitTo: "DeviceList"

    function reopen() {
        exitTo = "About"
        tutorialPages.currentIndex = 0
        appContent.state = "Tutorial"
    }

    SwipeView {
        id: tutorialPages
        anchors.fill: parent
        anchors.leftMargin: screenPaddingLeft
        anchors.rightMargin: screenPaddingRight
        anchors.bottomMargin: 56

        currentIndex: 0
        onCurrentIndexChanged: {
            if (currentIndex < 0) currentIndex = 0
            if (currentIndex > lastPage) {
                currentIndex = 0 // reset
                appContent.state = exitTo
            }
        }

        ////////

        Item {
            id: page1

            Column {
                id: column
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("<b>WatchFlower</b> is a plant monitoring application for Xiaomi '<b>Flower Care</b>' and '<b>RoPot</b>' or Parrot '<b>Flower Power</b>' sensors.")
                    textFormat: Text.StyledText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorHeaderContent
                    horizontalAlignment: Text.AlignHCenter
                }
                ImageSvg {
                    width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                    height: width*0.229
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-devices.svg"
                    color: Theme.colorHeaderContent
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("It also works great with a couple of <b>thermometers</b>!")
                    textFormat: Text.StyledText
                    color: Theme.colorHeaderContent
                    font.pixelSize: Theme.fontSizeContentBig
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
        }

        Item {
            id: page2

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("To start using WatchFlower, you'll need to <b>scan</b> for <b>compatible Bluetooth sensors</b> around you.")
                    textFormat: Text.StyledText
                    color: Theme.colorHeaderContent
                    font.pixelSize: Theme.fontSizeContentBig
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }
                ImageSvg {
                    width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                    height: width*0.777
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-bluetooth-searching.svg"
                    color: Theme.colorHeaderContent
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("You can <b>rescan</b> for new devices at any time, or <b>delete</b> the ones you don't want.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            id: page3

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("Once <b>paired</b>, sensors will periodically <b>sync</b> their data.")
                    textFormat: Text.StyledText
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeContentBig
                }
                ImageSvg {
                    width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                    height: width*0.229
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-app-connected.svg"
                    color: Theme.colorHeaderContent
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("Click on one of the sensors to access <b>detailed infos</b>, <b>graphs</b> and <b>historical data</b>.")
                    textFormat: Text.StyledText
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeContentBig
                }
            }
        }

        Item {
            id: page4

            Column {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("You can <b>name your plants</b> and set devices <b>location</b>.")
                    textFormat: Text.StyledText
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeContentBig
                }
                ImageSvg {
                    width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                    height: width*0.328
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: "qrc:/assets/devices/welcome-limits.svg"
                    color: Theme.colorHeaderContent
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 32

                    text: qsTr("Set <b>limits</b> like <b>optimal moisture level</b> or <b>temperature range</b> and more depending on available sensors metrics.")
                    textFormat: Text.StyledText
                    color: Theme.colorHeaderContent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeContentBig
                }
            }
        }
    }

    ////////

    Text {
        id: pagePrevious
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        visible: (tutorialPages.currentIndex != 0)

        text: qsTr("Previous")
        textFormat: Text.PlainText
        color: Theme.colorHeaderContent
        font.bold: true
        font.pixelSize: Theme.fontSizeContent

        Behavior on opacity { OpacityAnimator { duration: 133 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 0.8
            onExited: parent.opacity = 1
            onClicked: tutorialPages.currentIndex--
        }
    }

    Text {
        id: pageNext
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: pageIndicator.verticalCenter

        text: (tutorialPages.currentIndex === lastPage) ? qsTr("All right!") : qsTr("Next")
        textFormat: Text.PlainText
        color: Theme.colorHeaderContent
        font.bold: true
        font.pixelSize: Theme.fontSizeContent

        Behavior on opacity { OpacityAnimator { duration: 133 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 0.8
            onExited: parent.opacity = 1
            onClicked: tutorialPages.currentIndex++
        }
    }

    PageIndicatorThemed {
        id: pageIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16

        count: tutorialPages.count
        currentIndex: tutorialPages.currentIndex
    }
}

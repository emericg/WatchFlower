import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: tutorialScreen
    anchors.fill: parent

    color: Theme.colorHeader

    property string entryPoint: "DeviceList"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        entryPoint = "DeviceList"
        appContent.state = "Tutorial"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        appContent.state = "Tutorial"
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: tutorialLoader
        anchors.fill: parent

        active: (appContent.state === "Tutorial")
        asynchronous: true

        sourceComponent: Item {
            id: itemTutorial

            function reset() {
                tutorialPages.disableAnimation()
                tutorialPages.currentIndex = 0
                tutorialPages.enableAnimation()
            }
            function exit() {
                reset()
                if (entryPoint === "About") screenAbout.loadScreen()
                else screenDeviceList.loadScreen()
            }

            ////////////////

            SwipeView {
                id: tutorialPages
                anchors.fill: parent
                anchors.bottomMargin: 56

                property int margins: isPhone ? 24 : 40

                currentIndex: 0
                onCurrentIndexChanged: {
                    if (currentIndex < 0) currentIndex = 0
                    else if (currentIndex > count-1) exit()
                }

                function enableAnimation() {
                    contentItem.highlightMoveDuration = 333
                }
                function disableAnimation() {
                    contentItem.highlightMoveDuration = 0
                }

                ////////

                Item {
                    id: page1

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 32

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("<b>WatchFlower</b> is a plant monitoring application for Xiaomi '<b>Flower Care</b>' or Parrot '<b>Flower Power</b>' sensors.")
                            textFormat: Text.StyledText
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHeaderContent
                            horizontalAlignment: Text.AlignHCenter
                        }
                        IconSvg {
                            width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                            height: width*0.229
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "qrc:/assets/tutorial/welcome-devices.svg"
                            color: Theme.colorHeaderContent
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("It also works great with a couple of <b>thermometers</b> and other sensors like <b>air quality monitors</b> and <b>weather stations</b>!")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            font.pixelSize: Theme.fontSizeContentBig
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                        ButtonWireframeIcon {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: qsTr("Supported sensors")
                            source: "qrc:/assets/icons_material/duotone-launch-24px.svg"
                            sourceSize: 20
                            layoutDirection: Qt.RightToLeft
                            fullColor: true
                            primaryColor: Theme.colorHeaderHighlight

                            onClicked: Qt.openUrlExternally("https://github.com/emericg/WatchFlower/blob/master/docs/README.md")
                        }
                    }
                }

                ////////

                Item {
                    id: page2

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 32

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("To start using WatchFlower, you'll need to <b>scan</b> for <b>compatible Bluetooth sensors</b> around you.")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            font.pixelSize: Theme.fontSizeContentBig
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                        }
                        IconSvg {
                            width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                            height: width*0.777
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "qrc:/assets/tutorial/welcome-bluetooth-searching.svg"
                            color: Theme.colorHeaderContent
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("You can <b>rescan</b> for new devices at any time, or <b>delete</b> the ones you don't want.")
                            textFormat: Text.StyledText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                ////////

                Item {
                    id: page3

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 20

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins

                            text: qsTr("Once <b>paired</b>, sensors will periodically <b>sync</b> their data when you use WatchFlower.")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontSizeContentBig
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            visible: (Qt.platform.os !== "ios")
                            text: qsTr("WatchFlower <b>might</b> be able to sync sensors in the background. Check out the <b>settings</b> page for instructions.")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: singleColumn ? Theme.fontSizeContent : Theme.fontSizeContentBig
                        }
                        IconSvg {
                            width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                            height: width*0.229
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "qrc:/assets/tutorial/welcome-app-connected.svg"
                            color: Theme.colorHeaderContent
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("Keep in mind that Bluetooth only works in <b>close proximity</b>.")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontSizeContentBig
                        }
                    }
                }

                ////////

                Item {
                    id: page4

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 20

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("Click on sensors to access <b>historical data</b>, <b>graphs</b> and <b>detailed infos</b>.") + "<br>" +
                                  qsTr("You can set a custom <b>name</b> and a <b>location</b> for each sensor.")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: singleColumn ? Theme.fontSizeContent : Theme.fontSizeContentBig
                        }
                        IconSvg {
                            width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.66 : 0.3)
                            height: width*0.2
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "qrc:/assets/tutorial/welcome-plants.svg"
                            color: Theme.colorHeaderContent
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("You can also <b>choose a plant</b> from our database to automatically set <b>optimal limits</b> and get <b>plant care tips</b>!")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: singleColumn ? Theme.fontSizeContent : Theme.fontSizeContentBig
                        }
                        IconSvg {
                            width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.66 : 0.3)
                            height: width*0.1797
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "qrc:/assets/tutorial/welcome-limits.svg"
                            color: Theme.colorHeaderContent
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins

                            text: qsTr("You can always customize <b>limits</b> (like <b>moisture level</b> or <b>temperature range</b>) to your liking.")
                            textFormat: Text.StyledText
                            color: Theme.colorHeaderContent
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: singleColumn ? Theme.fontSizeContent : Theme.fontSizeContentBig
                        }
                        ButtonWireframe {
                            anchors.horizontalCenter: parent.horizontalCenter

                            fullColor: true
                            primaryColor: Theme.colorHeaderHighlight
                            text: qsTr("Start")

                            onClicked: tutorialPages.currentIndex++
                        }
                    }
                }

                ////////
            }

            ////////////////

            Text {
                id: pagePrevious
                anchors.left: parent.left
                anchors.leftMargin: tutorialPages.margins
                anchors.verticalCenter: pageIndicator.verticalCenter

                visible: (tutorialPages.currentIndex !== 0)

                text: qsTr("Previous")
                textFormat: Text.PlainText
                color: Theme.colorHeaderContent
                font.bold: true
                font.pixelSize: Theme.fontSizeContent

                opacity: 0.8
                Behavior on opacity { OpacityAnimator { duration: 133 } }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: isDesktop
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.8
                    onCanceled: parent.opacity = 0.8
                    onClicked: tutorialPages.currentIndex--
                }
            }

            PageIndicatorThemed {
                id: pageIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: tutorialPages.margins/2

                count: tutorialPages.count
                currentIndex: tutorialPages.currentIndex
            }

            Text {
                id: pageNext
                anchors.right: parent.right
                anchors.rightMargin: tutorialPages.margins
                anchors.verticalCenter: pageIndicator.verticalCenter

                text: (tutorialPages.currentIndex === tutorialPages.count-1) ? qsTr("Start") : qsTr("Next")
                textFormat: Text.PlainText
                color: Theme.colorHeaderContent
                font.bold: true
                font.pixelSize: Theme.fontSizeContent

                opacity: 0.8
                Behavior on opacity { OpacityAnimator { duration: 133 } }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: isDesktop
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.8
                    onCanceled: parent.opacity = 0.8
                    onClicked: tutorialPages.currentIndex++
                }
            }

            ////////////////
        }
    }
}

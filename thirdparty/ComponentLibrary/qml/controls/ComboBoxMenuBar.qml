import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

/*!
 * \brief A ComboBoxBar with a square icon button at its end, opening a menu sliding down below it, or up above it.
 *
 * Taller, without radius nor side borders, separated from the content by a line above and below.
 * Meant to be anchored to the screen edges, its texts aligned with the screen margins.
 * The list and the menu slide down the same way (or up, for a bar along the bottom edge),
 * and opening one closes the other.
 *
 * \property menuContentItem The menu content, set by the caller (ex: a Column of controls).
 * \property menu The menu popup, to open() or close() it.
 * \property menuSource The menu button icon.
 * \property menuButtonVisible Show the menu button, ex: false for a view without a menu.
 * \property edge The screen edge the bar is along: Qt.TopEdge (default), opening the list and the menu below it,
 *           or Qt.BottomEdge, opening them above it. Any other edge is handled as Qt.TopEdge.
 * \property leftSafeArea, rightSafeArea Width of the screen safe areas beside the control, in pixels:
 *           its background, its list and its menu extend under them, their content stays clear of them.
 */
ComboBoxThemed {
    id: control

    leftPadding: Theme.componentMarginXL
    rightPadding: Theme.componentMarginXL + (menuButton.visible ? menuButton.width : 0)

    leftInset: -leftSafeArea
    rightInset: -rightSafeArea

    radius: 0

    colorBackground: control.down ? Theme.colorComponentDown : Qt.lighter(Theme.colorTabletmenu, Theme.isLight ? 1.02 : 1.1)
    colorBackgroundBorder: Theme.colorSeparator

    property alias menu: menuPopup
    property alias menuContentItem: menuPopup.contentItem
    property url menuSource: "qrc:/IconLibrary/material-symbols/settings.svg"
    property bool menuButtonVisible: true

    property int edge: Qt.TopEdge
    indicator.rotation: (popup.visible === (edge !== Qt.BottomEdge)) ? 180 : 0

    property real leftSafeArea: 0
    property real rightSafeArea: 0

    // A popup spanning the control width below it, sliding up/down when opened.
    component SlidingPopup: T.Popup {
        id: sliding

        property real revealed: 0
        property color colorBorder: Theme.colorSeparator

        x: -control.leftSafeArea
        y: (control.edge !== Qt.BottomEdge) ? control.height : -height
        width: control.leftSafeArea + (parent ? parent.width : 0) + control.rightSafeArea
        leftPadding: padding + control.leftSafeArea
        rightPadding: padding + control.rightSafeArea
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                 implicitContentHeight + topPadding + bottomPadding)
        height: implicitHeight * revealed

        topMargin: Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop)
        bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        clip: true

        enter: Transition {
            NumberAnimation {
                property: "revealed"
                from: 0; to: 1
                duration: Theme.animationSpeedFast
                easing.type: Easing.OutQuad
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "revealed"
                to: 0
                duration: Theme.animationSpeedFast
                easing.type: Easing.InQuad
            }
        }

        background: Rectangle {
            color: Theme.colorComponentBackground

            Rectangle { // separator
                y: (control.edge !== Qt.BottomEdge) ? (parent.height - height) : 0
                width: parent.width
                height: 1
                color: sliding.colorBorder
            }
        }
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.componentHeightXL

        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground

        Rectangle { // top separator
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: control.colorBackgroundBorder
        }
        Rectangle { // bottom separator
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: control.colorBackgroundBorder
        }
    }

    ////////////////

    popup: SlidingPopup {
        padding: 1

        colorBorder: control.colorBackgroundBorder

        onAboutToShow: menuPopup.close()

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }
    }

    SlidingPopup {
        id: menuPopup

        padding: Theme.componentMargin

        colorBorder: control.colorBackgroundBorder
        closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent

        onAboutToShow: control.popup.close()
    }

    ////////////////

    T.Button {
        id: menuButton

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: height

        visible: control.menuButtonVisible
        focusPolicy: Qt.NoFocus
        hoverEnabled: Theme.isDesktop

        onClicked: menuPopup.visible ? menuPopup.close() : menuPopup.open()

        background: Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            anchors.bottomMargin: 1

            opacity: control.enabled ? 1 : 0.66
            color: (menuButton.down || menuPopup.visible) ? Theme.colorComponentDown : "transparent"
        }

        contentItem: Item {
            IconSvg {
                anchors.centerIn: parent
                width: UtilsNumber.alignTo(menuButton.height * 0.5, 2)
                height: width

                opacity: control.enabled ? 1 : 0.66
                color: menuPopup.visible ? Theme.colorPrimary : Theme.colorIcon
                Behavior on color { ColorAnimation { duration: Theme.animationSpeedFast } }

                source: control.menuSource
            }
        }
    }

    ////////////////
}

import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

PageIndicator {
    id: control
    count: 3
    currentIndex: 1

    delegate: Rectangle {
        implicitWidth: 12
        implicitHeight: 12
        radius: (width / 2)

        color: Theme.colorHeaderContent
        opacity: (index === control.currentIndex) ? (0.95) : (control.pressed ? 0.7 : 0.45)

        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }
}

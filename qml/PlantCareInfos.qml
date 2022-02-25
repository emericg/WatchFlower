import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Flickable {
    id: plantCareInfos
    implicitWidth: 480
    implicitHeight: 800

    contentWidth: -1
    contentHeight: column.height

    ////////////////////////////////////////////////////////////////////////////

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
    }
}

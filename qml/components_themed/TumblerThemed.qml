import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

Tumbler {
    id: control
    model: 24

    background: Item {
        //
    }

    delegate: Text {
        text: modelData
        font.pixelSize: (Tumbler.tumbler.currentIndex === modelData) ? 20 : 18
        font.bold: false
        color: (Tumbler.tumbler.currentIndex === modelData) ? Theme.colorPrimary : "black"
        opacity: 1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount / 2)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}

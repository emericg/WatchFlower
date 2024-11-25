import QtQuick

import ComponentLibrary

Rectangle {
    id: control

    implicitWidth: 64
    implicitHeight: 20
    radius: Theme.componentRadius

    required property string text

    color: {
        if (control.text === "4") return "#ff914d"
        if (control.text === "5") return "#ffbd59"
        if (control.text === "6") return "#ffde59"
        if (control.text === "7") return "#c9e265"
        if (control.text === "8") return "#03989e"
        if (control.text === "9") return "#2163bb"
        return "grey"
    }

    Text {
        anchors.centerIn: parent
        text: control.text
        textFormat: Text.PlainText
        color: "white"
        font.bold: true
        font.pixelSize: Theme.fontSizeContentVerySmall
    }
}

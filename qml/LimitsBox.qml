import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: item5

    Rectangle {
        id: rectangleHeader
        height: 48
        color: "#FBFBFB"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        Text {
            id: text4
            height: 40
            text: qsTr("Limits editor:")
            anchors.right: parent.right
            anchors.rightMargin: 16
            font.bold: false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
        }
    }

    Column {
        id: column
        anchors.top: rectangleHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: 0

        Item {
            id: itemHygro
            height: 80
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Image {
                id: imageHygro
                width: 48
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/hygro.svg"
            }
            Text {
                id: text8
                y: 0
                width: 40
                height: 40
                text: rangeSlider_hygro.first.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.left: imageHygro.right
                anchors.leftMargin: 4
            }
            RangeSlider {
                id: rangeSlider_hygro
                y: 0
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: text9.left
                anchors.left: text8.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4

                from: 1
                to: 66
                stepSize: 1
                first.value: myDevice.limitHygroMin
                second.value: myDevice.limitHygroMax
                first.onValueChanged: myDevice.limitHygroMin = first.value.toFixed(0);
                second.onValueChanged: myDevice.limitHygroMax = second.value.toFixed(0);
            }
            Text {
                id: text9
                x: 0
                y: 0
                width: 40
                height: 40
                text: rangeSlider_hygro.second.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 4
            }
        }

        Item {
            id: itemTemp
            height: 80
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Image {
                id: imageTemp
                width: 48
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/temp.svg"
            }
            Text {
                id: text3
                width: 40
                height: 40
                text: rangeSlider_temp.first.value.toFixed(0)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: imageTemp.right
                anchors.leftMargin: 4
                font.pixelSize: 14
            }
            RangeSlider {
                id: rangeSlider_temp
                height: 40
                anchors.right: text5.left
                anchors.rightMargin: 4
                anchors.left: text3.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                from: 0
                to: 50
                stepSize: 1
                first.value: myDevice.limitTempMin
                second.value: myDevice.limitTempMax
                first.onValueChanged: myDevice.limitTempMin = first.value.toFixed(0);
                second.onValueChanged: myDevice.limitTempMax = second.value.toFixed(0);
            }
            Text {
                id: text5
                width: 40
                height: 40
                text: rangeSlider_temp.second.value.toFixed(0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
        }

        Item {
            id: itemLumi
            height: 80
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Image {
                id: imageLumi
                width: 48
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/day.svg"
            }
            Text {
                id: text1
                x: 72
                y: -140
                width: 40
                height: 40
                text: qsTr("MIN")
                anchors.left: imageLumi.right
                anchors.leftMargin: 8
                anchors.verticalCenterOffset: 0
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
            SpinBox {
                id: spinBox1
                x: 128
                y: -140
                anchors.left: text1.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                from: 1
                to: 5000
                stepSize: 100
                value: myDevice.limitLumiMin
                onValueChanged: myDevice.limitLumiMin = value;
            }
            SpinBox {
                id: spinBox2
                x: 340
                y: -140
                anchors.left: spinBox1.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                from: 500
                to: 50000
                stepSize: 100
                value: myDevice.limitLumiMax
                onValueChanged: myDevice.limitLumiMax = value;
            }
            Text {
                id: text2
                y: -140
                width: 40
                height: 40
                text: qsTr("MAX")
                anchors.left: spinBox2.right
                anchors.leftMargin: 8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
        }

        Item {
            id: itemCondu
            height: 80
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            Image {
                id: imageCondu
                width: 48
                height: 48
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/conductivity.svg"
            }
            Text {
                id: text7
                x: 596
                y: -60
                width: 40
                height: 40
                text: rangeSlider_condu.second.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 4
            }
            RangeSlider {
                id: rangeSlider_condu
                x: 104
                y: -60
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: text7.left
                anchors.left: text6.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4

                from: 100
                to: 1000
                stepSize: 10
                first.value: myDevice.limitConduMin
                second.value: myDevice.limitConduMax
                first.onValueChanged: myDevice.limitConduMin = first.value.toFixed(0);
                second.onValueChanged: myDevice.limitConduMax = second.value.toFixed(0);
            }
            Text {
                id: text6
                x: 60
                y: -60
                width: 40
                height: 40
                text: rangeSlider_condu.first.value.toFixed(0)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                anchors.left: imageCondu.right
                anchors.leftMargin: 4
            }
        }
    }
}

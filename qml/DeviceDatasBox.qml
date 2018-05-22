import QtQuick 2.7

Rectangle {
    id: rectangleDeviceDatas
    anchors.rightMargin: 0
    anchors.leftMargin: 0
    anchors.topMargin: 0

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: parent.bottom

    //var badColor = "#ffbf66";
    //var neutralColor = "#e4e4e4";
    //var goodColor = "#87d241";

    function setDatas() {

        if (myDevice.deviceBattery < 15) {
            imageBatt.source = "qrc:/assets/battery_low.svg";
        } else if (myDevice.deviceBattery > 75) {
            imageBatt.source = "qrc:/assets/battery_full.svg";
        } else {
            imageBatt.source = "qrc:/assets/battery_mid.svg";
        }

        var hours = Qt.formatDateTime (new Date(), "hh");
        if (hours > 22 || hours < 8) {
            imageLuminosity.source = "qrc:/assets/night.svg";
        } else {
            imageLuminosity.source = "qrc:/assets/day.svg";
        }

        // Hygro
        if (myDevice.deviceHygro < myDevice.limitHygroMin)
        {
            barHygro_low.color = "#ffbf66"
            barHygro_good.color = "#e4e4e4"
            barHygro_high.color = "#e4e4e4"
        }
        else if (myDevice.deviceHygro > myDevice.limitHygroMax)
        {
            barHygro_low.color = "#e4e4e4"
            barHygro_good.color = "#e4e4e4"
            barHygro_high.color = "#ffbf66"
        }
        else
        {
            barHygro_low.color = "#e4e4e4"
            barHygro_good.color = "#87d241"
            barHygro_high.color = "#e4e4e4"
        }

        // Temp
        textTemp.text = myDevice.getTempString();
        if (myDevice.deviceTempC < myDevice.limitTempMin)
        {
            barTemp_low.color = "#ffbf66"
            barTemp_good.color = "#e4e4e4"
            barTemp_high.color = "#e4e4e4"
        }
        else if (myDevice.deviceTempC > myDevice.limitTempMax)
        {
            barTemp_low.color = "#e4e4e4"
            barTemp_good.color = "#e4e4e4"
            barTemp_high.color = "#ffbf66"
        }
        else
        {
            barTemp_low.color = "#e4e4e4"
            barTemp_good.color = "#87d241"
            barTemp_high.color = "#e4e4e4"
        }
        
        // Luminosity
        if (myDevice.deviceLuminosity < myDevice.limitLumiMin)
        {
            barLux_low.color = "#ffbf66"
            barLux_good.color = "#e4e4e4"
            barLux_high.color = "#e4e4e4"
        }
        else if (myDevice.deviceLuminosity > myDevice.limitLumiMax)
        {
            barLux_low.color = "#e4e4e4"
            barLux_good.color = "#e4e4e4"
            barLux_high.color = "#ffbf66"
        }
        else
        {
            barLux_low.color = "#e4e4e4"
            barLux_good.color = "#87d241"
            barLux_high.color = "#e4e4e4"
        }
        
        // Conductivity
        if (myDevice.deviceConductivity < myDevice.limitConduMin)
        {
            barCond_low.color = "#ffbf66"
            barCond_good.color = "#e4e4e4"
            barCond_high.color = "#e4e4e4"
        }
        else if (myDevice.deviceConductivity > myDevice.limitConduMax)
        {
            barCond_low.color = "#e4e4e4"
            barCond_good.color = "#e4e4e4"
            barCond_high.color = "#ffbf66"
        }
        else
        {
            barCond_low.color = "#e4e4e4"
            barCond_good.color = "#87d241"
            barCond_high.color = "#e4e4e4"
        }
    }

    Flow {
        id: flow1
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top

        Rectangle {
            id: rectangle
            width: 200
            height: 48
            color: "#ffffff"

            Image {
                id: imageHygro
                x: 16
                y: 3
                width: 40
                height: 40
                source: "qrc:/assets/hygro.svg"
            }

            Text {
                id: textHygro
                x: 63
                y: 8
                width: 69
                height: 15
                text: myDevice.deviceHygro + "%"
                font.pixelSize: 13
            }

            Rectangle {
                id: barHygro_low
                x: 63
                y: 27
                width: 24
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_good
                x: 93
                y: 27
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barHygro_high
                x: 147
                y: 27
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }
        }

        Rectangle {
            id: rectangle1
            width: 200
            height: 48
            color: "#ffffff"

            Image {
                id: imageTemp
                x: 8
                y: 6
                width: 40
                height: 40
                source: "qrc:/assets/temp.svg"
            }

            Text {
                id: textTemp
                x: 54
                y: 8
                width: 108
                height: 15
                text: myDevice.getTempString()
                font.pixelSize: 13
            }

            Rectangle {
                id: barTemp_low
                x: 54
                y: 27
                width: 24
                height: 8
                color: "#e4e4e4"
                border.color: "#00000000"
                border.width: 0
            }

            Rectangle {
                id: barTemp_good
                x: 84
                y: 27
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barTemp_high
                x: 138
                y: 27
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }
        }

        Rectangle {
            id: rectangle2
            width: 200
            height: 48
            color: "#ffffff"

            Image {
                id: imageLuminosity
                x: 16
                y: 4
                width: 40
                height: 40
                source: "qrc:/assets/day.svg"
            }

            Text {
                id: textLuminosity
                x: 62
                y: 8
                text: myDevice.deviceLuminosity + " lumens"
                font.pixelSize: 13
            }

            Rectangle {
                id: barLux_low
                x: 62
                y: 27
                width: 24
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barLux_good
                x: 92
                y: 27
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barLux_high
                x: 146
                y: 27
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }
        }

        Rectangle {
            id: rectangle3
            width: 200
            height: 48
            color: "#ffffff"

            Image {
                id: imageConductivity
                x: 8
                y: 4
                width: 40
                height: 40
                source: "qrc:/assets/conductivity.svg"
            }

            Text {
                id: textConductivity
                x: 55
                y: 8
                text: myDevice.deviceConductivity + " µS/cm"
                font.pixelSize: 13
            }

            Rectangle {
                id: barCond_low
                x: 55
                y: 27
                width: 24
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barCond_good
                x: 85
                y: 27
                width: 48
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }

            Rectangle {
                id: barCond_high
                x: 139
                y: 27
                width: 23
                height: 8
                color: "#e4e4e4"
                border.width: 0
                border.color: "#00000000"
            }
        }
    }

    ChartBox {
        id: chartBox
        x: 0
        y: 0
        anchors.top: flow1.bottom
        anchors.bottom: parent.bottom
    }
}

// UtilsDeviceSensors.js
// Version 3

.import DeviceUtils 1.0 as DeviceUtils
.import ThemeEngine 1.0 as ThemeEngine

/* ************************************************************************** */

function isDeviceSupported(deviceName) {
    if (deviceName === "Flower care" || deviceName === "Flower power" ||
        deviceName === "Flower mate" || deviceName === "Grow care garden" ||
        deviceName === "ropot" || deviceName === "Parrot pot" ||
        deviceName === "HiGrow" ||
        deviceName === "ThermoBeacon" ||
        deviceName === "MJ_HT_V1" ||
        deviceName === "LYWSD02" || deviceName === "MHO-C303" ||
        deviceName === "LYWSD03MMC" || deviceName === "MHO-C401" || deviceName === "XMWSDJO4MMC" ||
        deviceName === "ClearGrass Temp & RH" || deviceName === "Qingping Temp & RH M" ||
        deviceName === "Qingping Temp RH Lite" ||
        deviceName === "Qingping Alarm Clock" || deviceName === "Qingping Temp RH Barometer" ||
        deviceName === "WP6003" || deviceName === "JQJCY01YM" || deviceName === "AirQualityMonitor" ||
        deviceName === "GeigerCounter")
        return true
    return false
}

/* ************************************************************************** */

function getDeviceImage(deviceName) {
    if (deviceName === "Flower care") return "qrc:/devices/flowercare.svg"
    if (deviceName === "Grow care garden") return "qrc:/devices/flowercaremax.svg"
    if (deviceName === "Flower power") return "qrc:/devices/flowerpower.svg"
    if (deviceName === "Parrot pot") return "qrc:/devices/parrotpot.svg"
    if (deviceName === "ropot") return "qrc:/devices/ropot.svg"
    if (deviceName === "HiGrow") return "qrc:/devices/higrow.svg"
    return ""
}

function getDeviceIcon(device, devicePlanted) {
    var src = ""
    var deviceName = device.deviceName

    if (device.isPlantSensor) {
        if (devicePlanted) {
            if (deviceName === "ropot" || deviceName === "Parrot pot")
                src = "qrc:/assets/icons_custom/pot_flower-24px.svg"
            else
                src = "qrc:/assets/icons_material/outline-local_florist-24px.svg"
        } else {
            if (deviceName === "ropot" || deviceName === "Parrot pot")
                src = "qrc:/assets/icons_custom/pot_empty-24px.svg"
            else
                src = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
        }
    } else if (device.isThermometer) {
        if (deviceName === "ThermoBeacon" ||
            deviceName === "MJ_HT_V1" ||
            deviceName === "ClearGrass Temp & RH" || deviceName === "Qingping Temp & RH M" ||
            deviceName === "Qingping Temp RH Lite") {
            src = "qrc:/assets/icons_material/baseline-trip_origin-24px.svg"
        } else if (deviceName === "LYWSD02" ||
                   deviceName === "MHO-C303") {
            src = "qrc:/assets/icons_material/baseline-crop_16_9-24px.svg"
        } else if (deviceName === "LYWSD03MMC" ||
                   deviceName === "MHO-C401" ||
                   deviceName === "XMWSDJO4MMC") {
            src = "qrc:/assets/icons_material/baseline-crop_square-24px.svg"
        } else if (deviceName === "Qingping Alarm Clock" ||
                   deviceName === "Qingping Temp RH Barometer") {
            src = "qrc:/assets/icons_material/duotone-timer-24px.svg"
        } else {
            src = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
        }
    } else if (device.isEnvironmentalSensor) {
        if (deviceName === "GeigerCounter") {
            src = "qrc:/assets/icons_custom/nuclear_icon.svg"
        } else {
            src = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
        }
    } else {
        src = "qrc:/assets/icons_material/outline-settings_remote-24px.svg"
    }

    return src
}

/* ************************************************************************** */

function getDeviceStatusText(deviceStatus) {
    var txt = ""

    if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_OFFLINE) {
        txt = qsTr("Offline")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_QUEUED) {
        txt = qsTr("Queued")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTING) {
        txt = qsTr("Connecting...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTED) {
        txt = qsTr("Connected")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_WORKING) {
        txt = qsTr("Working...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING) {
        txt = qsTr("Updating...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_HISTORY) {
        txt = qsTr("Syncing...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_REALTIME) {
        txt = qsTr("Realtime data")
    }

    return txt + " "
}

function getDeviceStatusColor(deviceStatus) {
    var clr = ""

    if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_OFFLINE) {
        clr = ThemeEngine.Theme.colorRed
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_QUEUED) {
        clr = ThemeEngine.Theme.colorYellow
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTING) {
        clr = ThemeEngine.Theme.colorYellow
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTED) {
        clr = ThemeEngine.Theme.colorGreen
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_WORKING) {
        clr = ThemeEngine.Theme.colorYellow
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_HISTORY ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_REALTIME) {
        clr = ThemeEngine.Theme.colorYellow
    }

    return clr
}

/* ************************************************************************** */

function getDeviceBatteryIcon(batteryLevel) {
    var src = ""

    if (batteryLevel > 95) {
        src = "qrc:/assets/icons_material/baseline-battery_full-24px.svg";
    } else if (batteryLevel > 85) {
        src = "qrc:/assets/icons_material/baseline-battery_90-24px.svg";
    } else if (batteryLevel > 75) {
        src = "qrc:/assets/icons_material/baseline-battery_80-24px.svg";
    } else if (batteryLevel > 55) {
        src = "qrc:/assets/icons_material/baseline-battery_60-24px.svg";
    } else if (batteryLevel > 45) {
        src = "qrc:/assets/icons_material/baseline-battery_50-24px.svg";
    } else if (batteryLevel > 25) {
        src = "qrc:/assets/icons_material/baseline-battery_30-24px.svg";
    } else if (batteryLevel > 15) {
        src = "qrc:/assets/icons_material/baseline-battery_20-24px.svg";
    } else if (batteryLevel > 1) {
        src = "qrc:/assets/icons_material/baseline-battery_10-24px.svg";
    } else if (batteryLevel >= 0) {
        src = "qrc:/assets/icons_material/baseline-battery_unknown-24px.svg";
    }

    return src
}

function getDeviceBatteryColor(batteryLevel) {
    var clr = ""

    if (batteryLevel <= 0) {
        clr = ThemeEngine.Theme.colorRed
    } else if (batteryLevel <= 10) {
        clr = ThemeEngine.Theme.colorYellow
    } else {
        clr = ThemeEngine.Theme.colorIcon
    }

    return clr
}

/* ************************************************************************** */

function getDeviceCapabilityName(capabilityId) {
    var name = ""

    if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_REALTIME) {
        name = qsTr("Realtime")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_HISTORY) {
        name = qsTr("History")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_BATTERY) {
        name = qsTr("Battery")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_CLOCK) {
        name = qsTr("Clock")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_LED_STATUS) {
        name = qsTr("LED status")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_LED_RGB) {
        name = qsTr("LED RGB")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_BUTTONS) {
        name = qsTr("Buttons")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_LAST_MOVE) {
        name = qsTr("Last move")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_WATER_TANK) {
        name = qsTr("Watering")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_CALIBRATION) {
        name = qsTr("Calibration")
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_REBOOT) {
        name = qsTr("Reboot")
    }
    return name
}

function getDeviceCapabilityIcon(capabilityId) {
    var src = ""

    if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_REALTIME) {
        src = "qrc:/assets/icons_material/duotone-update-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_HISTORY) {
        src = "qrc:/assets/icons_custom/duotone-date_all-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_BATTERY) {
        src = "qrc:/assets/icons_material/baseline-battery_full-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_CLOCK) {
        src = "qrc:/assets/icons_material/duotone-timer-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_LED_STATUS) {
        src = "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_LED_RGB) {
        src = "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_BUTTONS) {
        src = "qrc:/assets/icons_material/duotone-touch_app-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_LAST_MOVE) {
        src = "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_WATER_TANK) {
        src = "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_CALIBRATION) {
        src = "qrc:/assets/icons_material/duotone-model_training-24px.svg"
    } else if (capabilityId === DeviceUtils.DeviceUtils.DEVICE_REBOOT) {
        src = "qrc:/assets/icons_material/duotone-restart_alt-24px.svg"
    }

    return src
}

/* ************************************************************************** */

function getDeviceSensorName(sensorId) {
    var name = ""

    if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_MOISTURE) {
        name = qsTr("Soil moisture")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_CONDUCTIVITY) {
        name = qsTr("Soil conductivity")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_TEMPERATURE) {
        name = qsTr("Soil temperature")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_PH) {
        name = qsTr("Soil PH")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_TEMPERATURE) {
        name = qsTr("Temperature")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_HUMIDITY) {
        name = qsTr("Humididty")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PRESSURE) {
        name = qsTr("Pressure")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_LUMINOSITY) {
        name = qsTr("Luminosity")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_UV) {
        name = qsTr("UV luminosity")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOUND) {
        name = qsTr("Sound")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_WATER_LEVEL) {
        name = qsTr("Water level")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_WIND_DIRECTION) {
        name = qsTr("Wind direction")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_WIND_SPEED) {
        name = qsTr("Wind speed")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PM1) {
        name = qsTr("PM1")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PM25) {
        name = qsTr("PM2.5")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PM10) {
        name = qsTr("PM10")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_O2) {
        name = qsTr("O2")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_O3) {
        name = qsTr("O3")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_CO) {
        name = qsTr("CO")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_CO2) {
        name = qsTr("CO2")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_eCO2) {
        name = qsTr("eCO2")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_NO2) {
        name = qsTr("NO2")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SO2) {
        name = qsTr("SO2")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_VOC) {
        name = qsTr("VOC")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_HCHO) {
        name = qsTr("HCHO")
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_GEIGER) {
        name = qsTr("Geiger Counter")
    }

    return name
}

function getDeviceSensorIcon(sensorId) {
    var src = ""

    if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_MOISTURE) {
        src = "qrc:/assets/icons_material/duotone-water_mid-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_CONDUCTIVITY) {
        src = "qrc:/assets/icons_material/baseline-tonality-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_TEMPERATURE) {
        src = "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOIL_PH) {
        src = "qrc:/assets/icons_material/baseline-tonality-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_TEMPERATURE) {
        src = "qrc:/assets/icons_material/baseline-ac_unit-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_HUMIDITY) {
        src = "qrc:/assets/icons_material/duotone-water_full-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PRESSURE) {
        src = "qrc:/assets/icons_material/duotone-speed-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_LUMINOSITY) {
        src = "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_UV) {
        src = "qrc:/assets/icons_material/duotone-wb_sunny-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SOUND) {
        src = "qrc:/assets/icons_material/duotone-mic-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_WATER_LEVEL) {
        src = "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_WIND_DIRECTION) {
        src = "qrc:/assets/icons_material/baseline-near_me-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_WIND_SPEED) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PM1) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PM25) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_PM10) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_O2) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_O3) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_CO) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_CO2) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_eCO2) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_NO2) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_SO2) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_VOC) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_HCHO) {
        src = "qrc:/assets/icons_material/baseline-air-24px.svg"
    } else if (sensorId === DeviceUtils.DeviceUtils.SENSOR_GEIGER) {
        src = "qrc:/assets/icons_custom/nuclear_icon.svg"
    }

    return src
}

/* ************************************************************************** */

/*!
 * This file is part of SmartCare.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_sensor.h"

#include <cstdint>
#include <cmath>

#include <QBluetoothUuid>
#include <QLowEnergyService>

#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

enum MiBeacon_sensors {
    mi_sleep_state              = 0x1002,
    mi_RSSI                     = 0x1003,
    mi_temperature              = 0x1004,
    mi_humidity                 = 0x1006,
    mi_luminosity               = 0x1007,
    mi_soil_moisture            = 0x1008,
    mi_soil_conductivity        = 0x1009,
    mi_battery_level            = 0x100a,
    mi_temperature_humidity     = 0x100d,
    mi_lock_state               = 0x100e,
    mi_door_state               = 0x100f,
    mi_formaldehyde             = 0x1010,
    mi_bind_state               = 0x1011,
    mi_switch_state             = 0x1012,
    mi_consumables_remaining    = 0x1013,
    mi_water_immersion_state    = 0x1014,
    mi_smoke_state              = 0x1015,
    mi_gas_state                = 0x1016,
};

enum Qingping_sensors {
    qp_temperature_humidity     = 0x01,
    qp_battery_level            = 0x02,
    qp_air_pressure             = 0x07,
    qp_particulate_matter       = 0x12,
    qp_co2                      = 0x13,
    qp_door_state               = 0x0F,
};

enum BtHome_sensors {
    bth_packetid_uint8          = 0x00,
    bth_battery_uint8           = 0x01,
    bth_co2_uint16              = 0x12,
    bth_count_uint8             = 0x09,
    bth_count_uint16            = 0x3D,
    bth_count_uint32            = 0x3E,
    bth_current_uint16          = 0x43,
    bth_dewpoint_sint16         = 0x08,
    bth_distance_mm_uint16      = 0x40,
    bth_distance_m_uint16       = 0x41,
    bth_duration_uint24         = 0x42,
    bth_energy_uint24           = 0X0A,
    bth_gas_uint24              = 0X4B,
    bth_humidity_uint16         = 0x03,
    bth_humidity_uint8          = 0x2E,
    bth_illuminance_uint24      = 0x05,
    bth_mass_kg_uint16          = 0x06,
    bth_mass_lb_uint16          = 0x07,
    bth_moisture_uint16         = 0x14,
    bth_moisture_uint8          = 0x2F,
    bth_pm25_uint16             = 0x0D,
    bth_pm10_uint16             = 0x0E,
    bth_power_uint24            = 0x0B,
    bth_pressure_uint24         = 0x04,
    bth_rotation_sint16         = 0x3F,
    bth_speed_uint16            = 0x44,
    bth_temperature_sint16      = 0x45,
    bth_temperature_p_sint16    = 0x02,
    bth_tvoc_uint16             = 0x13,
    bth_voltage_p_uint16        = 0x0C,
    bth_voltage_uint16          = 0x4A,
    bth_volume_p_uint16         = 0x47,
    bth_volume_uint16           = 0x48,
    bth_volume_flow_uint16      = 0x49,
    bth_UVindex_uint8           = 0x46,

    bth_binary_battery          = 0x15,
    bth_binary_batterycharging  = 0x16,
    bth_binary_carbonmonoxide   = 0x17,
    bth_binary_cold             = 0x18,
    bth_binary_connectivity     = 0x19,
    bth_binary_door             = 0x1A,
    bth_binary_garagedoor       = 0x1B,
    bth_binary_gas              = 0x1C,
    bth_binary_generic          = 0x0F,
    bth_binary_heat             = 0x1D,
    bth_binary_light            = 0x1E,
    bth_binary_lock             = 0x1F,
    bth_binary_moisture         = 0x20,
    bth_binary_motion           = 0x21,
    bth_binary_moving           = 0x22,
    bth_binary_occupancy        = 0x23,
    bth_binary_opening          = 0x11,
    bth_binary_plug             = 0x24,
    bth_binary_power            = 0x10,
    bth_binary_presence         = 0x25,
    bth_binary_problem          = 0x26,
    bth_binary_running          = 0x27,
    bth_binary_safety           = 0x28,
    bth_binary_smoke            = 0x29,
    bth_binary_sound            = 0x2A,
    bth_binary_tamper           = 0x2B,
    bth_binary_vibration        = 0x2C,
    bth_binary_window           = 0x2D,

    bth_event_button            = 0x3A,
    bth_event_dimmer            = 0x3C,
};

/* ************************************************************************** */

bool DeviceSensor::parseBeaconXiaomi(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceSensor::parseBeaconXiaomi()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());
    const int data_size = ba.size();
    bool status = false;

    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == 0xFE95 && data_size >= 12)
    {
        // Frame control
        uint16_t framecontrol = static_cast<uint16_t>(data[0] + (data[1] << 8));

        bool isEncrypted = (framecontrol & 0x0008);
        bool hasMAC = (framecontrol & 0x0010);
        bool hasCapability = (framecontrol & 0x0020);
        bool hasObject = (framecontrol & 0x0040);
        bool isMeshed = (framecontrol & 0x0080);
        bool isRegistered = (framecontrol & 0x0100);
        bool isSolicited = (framecontrol & 0x0200);
        int AuthMode = (framecontrol & 0x1800) >> 11;
        int version = (framecontrol & 0xE000) >> 13;

        //qDebug() << "framecontrol 0x" << QString::number(framecontrol, 16);
        //qDebug() << "- isEncrypted  :" << isEncrypted;
        //qDebug() << "- hasMAC       :" << hasMAC;
        //qDebug() << "- hasCapability:" << hasCapability;
        //qDebug() << "- hasObject    :" << hasObject;
        //qDebug() << "- isMeshed     :" << isMeshed;
        //qDebug() << "- isRegistered :" << isRegistered;
        //qDebug() << "- isSolicited  :" << isSolicited;
        //qDebug() << "- AuthMode     :" << AuthMode;
        //qDebug() << "- version      :" << version;

        // Product ID
        uint16_t productid = static_cast<uint16_t>(data[2] + (data[3] << 8));

        // Frame counter
        uint8_t framecounter = static_cast<uint8_t>(data[4]);

        // MAC address (for macOS and iOS)
        if (!hasAddressMAC())
        {
            QString mac;

            mac += ba.mid(10,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(9,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(8,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(7,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(6,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(5,1).toHex().toUpper();

            setAddressMAC(mac);
        }

        int pos = 11;
        int capability = 0;
        int capability_io = 0;

        // Capability field?
        if (hasCapability)
        {
            capability = static_cast<uint8_t>(data[pos++]);

            // IO capability field?
            if (capability & 0x20)
            {
                capability_io = static_cast<int>(data[pos] + (data[pos+1] << 8));
                pos += 2;
            }
        }

        Q_UNUSED(isEncrypted)
        Q_UNUSED(hasMAC)
        Q_UNUSED(isMeshed)
        Q_UNUSED(isRegistered)
        Q_UNUSED(isSolicited)
        Q_UNUSED(AuthMode)
        Q_UNUSED(version)
        Q_UNUSED(productid)
        Q_UNUSED(framecounter)
        Q_UNUSED(capability_io)

        // Data
        int batt = -99;
        int moist = -99;
        int fert = -99;
        float temp = -99.f;
        float humi = -99.f;
        int lumi = -99;
        float hcho = -99.f;

        if (hasObject)
        {
            int payload_data_type = static_cast<int>(data[pos] + (data[pos+1] << 8));
            int payload_data_size = static_cast<int>(data[pos+2]);
            pos += 3;

            if (payload_data_type == mi_battery_level)
            {
                batt = static_cast<int>(data[pos++]);
                setBattery(batt);
            }
            else if (payload_data_type == mi_soil_moisture)
            {
                moist = static_cast<int16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (moist >= 0 && moist <= 100)
                {
                    if (moist != m_soilMoisture)
                    {
                        if (m_deviceName != "ropot") // ropot hack // device always broadcast 0
                        {
                            m_soilMoisture = moist;
                            Q_EMIT dataUpdated();
                            status = true;
                        }
                    }
                }
            }
            else if (payload_data_type == mi_soil_conductivity)
            {
                fert = static_cast<int16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (fert >= 0 && fert < 20000)
                {
                    if (fert != m_soilConductivity)
                    {
                        if (m_deviceName != "ropot") // ropot hack // device always broadcast 0
                        {
                            m_soilConductivity = fert;
                            Q_EMIT dataUpdated();
                            status = true;
                        }
                    }
                }
            }
            else if (payload_data_type == mi_temperature_humidity)
            {
                temp = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (temp > -30.f && temp < 100.f)
                {
                    if (temp != m_temperature)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
                humi = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (humi >= 0.f && humi <= 100.f)
                {
                    if (humi != m_humidity)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == mi_temperature)
            {
                temp = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (temp > -30.f && temp < 100.f)
                {
                    if (temp != m_temperature)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == mi_humidity)
            {
                humi = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (humi >= 0.f && humi <= 100.f)
                {
                    if (humi != m_humidity)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == mi_luminosity)
            {
                lumi = static_cast<int32_t>(data[pos] + (data[pos+1] << 8) + (data[pos+2] << 16));
                pos += 3;
                if (lumi >= 0 && lumi < 150000)
                {
                    if (lumi != m_luminosityLux)
                    {
                        m_luminosityLux = lumi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == mi_formaldehyde)
            {
                hcho = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (hcho >= 0.f && hcho <= 100.f)
                {
                    if (hcho != m_hcho)
                    {
                        m_hcho = hcho;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == 0x100b)
            {
                pos += 2; // but what is it?
            }
            else
            {
                qDebug() << "* MiBeacon payload ERROR >" << getName() << getAddress() << "(" << data_size << ") bytes";
                qDebug() << "- data  >  0x" << ba.toHex();
                qDebug() << "- payload_data_type: 0x" << QString::number(payload_data_type, 16);
                qDebug() << "- position:" << pos << " / " << data_size;
            }

            Q_UNUSED(payload_data_size);
            Q_UNUSED(pos);
        }
/*
        if (batt > -99 || moist > -99.f || fert > -99.f ||
            temp > -99.f || humi > -99.f || lumi > -99 || hcho > -99.f)
        {
            qDebug() << "* MiBeacon service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
            if (batt > -99) qDebug() << "- battery:" << batt;
            if (moist > -99) qDebug() << "- soil moisture:" << moist;
            if (fert > -99) qDebug() << "- soil conductivity:" << fert;
            if (temp > -99.f) qDebug() << "- temperature:" << temp;
            if (humi > -99.f) qDebug() << "- humidity:" << humi;
            if (lumi > -99) qDebug() << "- luminosity:" << lumi;
            if (hcho > -99.f) qDebug() << "- formaldehyde:" << hcho;
        }
*/
    }

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::parseBeaconQingping(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceSensor::parseBeaconQingping()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());
    const int data_size = ba.size();
    bool status = false;

    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == 0xFDCD && data_size >= 14)
    {
        // MAC address (for macOS and iOS)
        if (!hasAddressMAC())
        {
            QString mac;

            mac += ba.mid(7,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(6,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(5,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(4,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(3,1).toHex().toUpper();
            mac += ':';
            mac += ba.mid(2,1).toHex().toUpper();

            setAddressMAC(mac);
        }

        // Data
        int batt = -99;
        float temp = -99.f;
        float humi = -99.f;
        float pres = -99.f;
        float co2 = -99.f;
        float pm25 = -99.f;
        float pm10 = -99.f;

        for (int pos = 8; pos < data_size;)
        {
            int payload_data_type = data[pos++];
            int payload_data_size = data[pos++];

            if (payload_data_type == qp_battery_level)
            {
                batt = static_cast<int>(data[pos]);
                setBattery(batt);
            }
            else if (payload_data_type == qp_temperature_humidity)
            {
                temp = static_cast<int32_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (temp > -30.f && temp < 100.f)
                {
                    if (temp != m_temperature)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
                humi = static_cast<int32_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (humi >= 0.f && humi <= 100.f)
                {
                    if (humi != m_humidity)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == qp_air_pressure)
            {
                pres = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (pres >= 0 && pres <= 2000)
                {
                    if (pres != m_pressure)
                    {
                        m_pressure = pres;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == qp_particulate_matter)
            {
                pm25 = static_cast<int16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (pm25 >= 0 && pm25 <= 1000)
                {
                    if (pm25 != m_pm_25)
                    {
                        m_pm_25 = pm25;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
                pm10 = static_cast<int16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (pm10 >= 0 && pm10 <= 1000)
                {
                    if (pm10 != m_pm_10)
                    {
                        m_pm_10 = pm10;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (payload_data_type == qp_co2)
            {
                co2 = static_cast<int16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (co2 >= 0 && co2 <= 9999)
                {
                    if (co2 != m_co2)
                    {
                        m_co2 = co2;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else
            {
                qDebug() << "* Qingping payload ERROR >" << getName() << getAddress() << "(" << data_size << ") bytes";
                qDebug() << "- data  >  0x" << ba.toHex();
                qDebug() << "- payload_data_type: 0x" << QString::number(payload_data_type, 16);
                qDebug() << "- payload_data_size:" << payload_data_size;
                qDebug() << "- position:" << pos << " / " << data_size;
            }
        }
/*
        if (batt > -99 || temp > -99.f || humi > -99.f ||
            pres > -99.f || co2 > -99.f || pm25 > -99.f || pm10 > -99.f)
        {
            qDebug() << "* Qingping service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
            if (batt > -99) qDebug() << "- battery:" << batt;
            if (temp > -99.f) qDebug() << "- temperature:" << temp;
            if (humi > -99.f) qDebug() << "- humidity:" << humi;
            if (pres > -99.f) qDebug() << "- air pressure:" << pres;
            if (co2 > -99.f) qDebug() << "- co2:" << co2;
            if (pm25 > -99.f) qDebug() << "- pm 2.5:" << pm25;
            if (pm10 > -99.f) qDebug() << "- pm 10 :" << pm10;
        }
*/
    }

    return status;
}

/* ************************************************************************** */

bool DeviceSensor::parseBeaconBtHome(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &ba)
{
/*
    qDebug() << "DeviceSensor::parseBeaconBtHome()" << m_deviceName << m_deviceAddress
             << "[mode: " << adv_mode << " /  id: 0x" << QString::number(adv_id, 16) << "]";
    qDebug() << "DATA (" << ba.size() << "bytes)   >  0x" << ba.toHex();
*/
    const quint8 *data = reinterpret_cast<const quint8 *>(ba.constData());
    const int data_size = ba.size();
    bool status = false;

    bool isEncrypted = false;
    int version = 0;
    int pos = 0;

    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == 0x181E)
    {
        // BTHome format (v1, encrypted)
        version = 1;
        isEncrypted = true;
    }
    else if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == 0x181C)
    {
        // BTHome format (v1)
        // Skip 2 bytes UUID ?

        version = 1;
        isEncrypted = false;
    }
    else if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA && adv_id == 0xFCD2)
    {
        // BTHome format (v2)
        // Skip 2 bytes UUID ?

        uint8_t bthome_info_byte = data[pos++];
        isEncrypted = (bthome_info_byte & 0x0001);
        //int reserved = (bthome_info_byte & 0x1E) >> 1;
        version = (bthome_info_byte & 0xE0) >> 5;
    }

    //qDebug() << "BTHome format";
    //qDebug() << "- isEncrypted  :" << isEncrypted;
    //qDebug() << "- version      :" << version;

    // Data
    int batt = -99;
    int moist = -99;
    float temp = -99.f;
    float humi = -99.f;
    int lumi = -99;
    float pres = -99.f;
    float voc = -99.f;
    float co2 = -99.f;
    float pm25 = -99.f;
    float pm10 = -99.f;

    if (isEncrypted)
    {
        qWarning() << "BTHome format (v" << version << ", encrypted) is UNSUPPORTED";
    }
    else if (version == 1 || version == 2)
    {
        for (; pos < data_size;)
        {
            uint8_t object_type = 0;
            int object_length = 0;
            int object_format = 0;

            if (version == 1)
            {
                uint8_t bthome_object = data[pos++];
                object_length = (bthome_object & 0x1F);
                object_format = (bthome_object & 0xE0) >> 5;
                Q_UNUSED(object_length)
                Q_UNUSED(object_format)
            }

            object_type = data[pos++];

            if (object_type == bth_packetid_uint8)
            {
                pos++;
            }
            else if (object_type == bth_battery_uint8)
            {
                batt = static_cast<int8_t>(data[pos++]);
                setBattery(batt);
            }
            else if (object_type == bth_temperature_sint16)
            {
                temp = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 10.f;
                pos += 2;
                if (temp > -30.f && temp < 100.f)
                {
                    if (temp != m_temperature)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_temperature_p_sint16)
            {
                temp = static_cast<int16_t>(data[pos] + (data[pos+1] << 8)) / 100.f;
                pos += 2;
                if (temp > -30.f && temp < 100.f)
                {
                    if (temp != m_temperature)
                    {
                        m_temperature = temp;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_humidity_uint8)
            {
                humi = static_cast<float>(data[pos++]);
                if (humi >= 0.f && humi <= 100.f)
                {
                    if (humi != m_humidity)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_humidity_uint16)
            {
                humi = static_cast<uint16_t>(data[pos] + (data[pos+1] << 8)) / 100.f;
                pos += 2;
                if (humi >= 0.f && humi <= 100.f)
                {
                    if (humi != m_humidity)
                    {
                        m_humidity = humi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_illuminance_uint24)
            {
                lumi = static_cast<uint32_t>(data[pos] + (data[pos+1] << 8) + (data[pos+2] << 16)) / 100.f;
                pos += 3;
                if (lumi >= 0 && lumi < 150000)
                {
                    if (lumi != m_luminosityLux)
                    {
                        m_luminosityLux = lumi;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_moisture_uint16)
            {
                moist = static_cast<uint16_t>(data[pos] + (data[pos+1] << 8)) / 100.f;
                pos += 2;
                if (moist >= 0 && moist <= 100)
                {
                    if (moist != m_soilMoisture)
                    {
                        m_soilMoisture = moist;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_moisture_uint8)
            {
                moist = static_cast<uint8_t>(data[pos++]);
                if (moist >= 0 && moist <= 100)
                {
                    if (moist != m_soilMoisture)
                    {
                        m_soilMoisture = moist;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_pressure_uint24)
            {
                pres = static_cast<uint32_t>(data[pos] + (data[pos+1] << 8) + (data[pos+2] << 16)) / 100.f;
                pos += 3;
                if (pres >= 0 && pres <= 2000)
                {
                    if (pres != m_pressure)
                    {
                        m_pressure = pres;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_tvoc_uint16)
            {
                voc = static_cast<uint16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (voc >= 0 && voc <= 9999)
                {
                    if (voc != m_voc)
                    {
                        m_voc = voc;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_co2_uint16)
            {
                co2 = static_cast<int16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (co2 >= 0 && co2 <= 9999)
                {
                    if (co2 != m_co2)
                    {
                        m_co2 = co2;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_pm25_uint16)
            {
                pm25 = static_cast<uint16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (pm25 >= 0 && pm25 <= 1000)
                {
                    if (pm25 != m_pm_25)
                    {
                        m_pm_25 = pm25;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_pm10_uint16)
            {
                pm10 = static_cast<uint16_t>(data[pos] + (data[pos+1] << 8));
                pos += 2;
                if (pm10 >= 0 && pm10 <= 1000)
                {
                    if (pm10 != m_pm_10)
                    {
                        m_pm_10 = pm10;
                        Q_EMIT dataUpdated();
                        status = true;
                    }
                }
            }
            else if (object_type == bth_voltage_p_uint16)
            {
                float voltage = static_cast<uint16_t>(data[pos] + (data[pos+1] << 8)) / 1000.f;
                pos += 2;
                Q_UNUSED(voltage)
            }
            else if (object_type == bth_binary_power)
            {
                bool power = data[pos++];
                Q_UNUSED(power)
            }
            else
            {
                qDebug() << "* BtHome payload ERROR >" << getName() << getAddress() << "(" << data_size << ") bytes";
                qDebug() << "- data  >  0x" << ba.toHex();
                qDebug() << "- object_type: 0x" << QString::number(object_type, 16);
                qDebug() << "- object_length: " << object_length;
                qDebug() << "- position:" << pos << " / " << data_size;

                if (object_length > 0) pos += object_length; // we ignore data if we know its size
                else break; // otherwise we are lost...
            }
        }
/*
        if (batt > -99 || temp > -99.f || humi > -99.f || lumi > -99 ||
            pres > -99 || voc > -99.f || co2 > -99.f || pm25 > -99.f || pm10 > -99.f)
        {
            qDebug() << "* BtHome service data:" << getName() << getAddress() << "(" << data_size << ") bytes";
            if (batt > -99) qDebug() << "- battery:" << batt;
            if (temp > -99.f) qDebug() << "- temperature:" << temp;
            if (humi > -99.f) qDebug() << "- humidity:" << humi;
            if (lumi > -99) qDebug() << "- luminosity:" << lumi;
            if (moist > -99) qDebug() << "- soil moisture:" << moist;
            if (pres > -99.f) qDebug() << "- air pressure:" << pres;
            if (voc > -99.f) qDebug() << "- voc:" << voc;
            if (co2 > -99.f) qDebug() << "- co2:" << co2;
            if (pm25 > -99.f) qDebug() << "- pm 2.5:" << pm25;
            if (pm10 > -99.f) qDebug() << "- pm 10 :" << pm10;
        }
*/
    }

    return status;
}

/* ************************************************************************** */

/*!
 * This file is part of WatchFlower.
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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_SENSOR_H
#define DEVICE_SENSOR_H
/* ************************************************************************** */

#include "device.h"
#include "device_infos.h"

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

/* ************************************************************************** */

/*!
 * \brief The DeviceSensor class
 */
class DeviceSensor: public Device
{
    Q_OBJECT

    Q_PROPERTY(bool hasData READ hasDataHistory NOTIFY dataAvailableUpdated)
    Q_PROPERTY(bool hasDataFresh READ hasDataFresh NOTIFY dataAvailableUpdated)
    Q_PROPERTY(bool hasDataToday READ hasDataToday NOTIFY dataAvailableUpdated)

    Q_PROPERTY(bool hasSoilMoistureSensor READ hasSoilMoistureSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasSoilConductivitySensor READ hasSoilConductivitySensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasSoilTemperatureSensor READ hasSoilTemperatureSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasSoilPhSensor READ hasSoilPhSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasTemperatureSensor READ hasTemperatureSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasHumiditySensor READ hasHumiditySensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasPressureSensor READ hasPressureSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasLuminositySensor READ hasLuminositySensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasUvSensor READ hasUvSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasSoundSensor READ hasSoundSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasWaterLevelSensor READ hasWaterLevelSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasWindDirectionSensor READ hasWindDirectionSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasWindSpeedSensor READ hasWindSpeedSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasPM1Sensor READ hasPM1Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasPM25Sensor READ hasPM25Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasPM10Sensor READ hasPM10Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasO2Sensor READ hasO2Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasO3Sensor READ hasO3Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasCoSensor READ hasCoSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasCo2Sensor READ hasCo2Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool haseCo2Sensor READ haseCo2Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasNo2Sensor READ hasNo2Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasSo2Sensor READ hasSo2Sensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasVocSensor READ hasVocSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasHchoSensor READ hasHchoSensor NOTIFY sensorsUpdated)
    Q_PROPERTY(bool hasGeigerCounter READ hasGeigerCounter NOTIFY sensorsUpdated)

    // plant data
    Q_PROPERTY(int soilMoisture READ getSoilMoisture NOTIFY dataUpdated)
    Q_PROPERTY(int soilConductivity READ getSoilConductivity NOTIFY dataUpdated)
    Q_PROPERTY(float soilTemperature READ getSoilTemperature NOTIFY dataUpdated)
    Q_PROPERTY(float soilPH READ getSoilPH NOTIFY dataUpdated)
    Q_PROPERTY(float waterTankLevel READ getWaterTankLevel NOTIFY dataUpdated)
    Q_PROPERTY(float waterTankCapacity READ getWaterTankCapacity NOTIFY dataUpdated)
    Q_PROPERTY(QDateTime lastMove READ getLastMove NOTIFY dataUpdated)
    // hygrometer data
    Q_PROPERTY(float temperature READ getTemp NOTIFY dataUpdated)
    Q_PROPERTY(float temperatureC READ getTempC NOTIFY dataUpdated)
    Q_PROPERTY(float temperatureF READ getTempF NOTIFY dataUpdated)
    Q_PROPERTY(float humidity READ getHumidity NOTIFY dataUpdated)
    // hygrometer data (virtual)
    Q_PROPERTY(float heatIndex READ getHeatIndex NOTIFY dataUpdated)
    Q_PROPERTY(float dewPoint READ getDewPoint NOTIFY dataUpdated)
    // environmental data
    Q_PROPERTY(int pressure READ getPressure NOTIFY dataUpdated)
    Q_PROPERTY(int luminosityLux READ getLuminosityLux NOTIFY dataUpdated)
    Q_PROPERTY(int luminosityMmol READ getLuminosityMmol NOTIFY dataUpdated)
    Q_PROPERTY(int uv READ getUV NOTIFY dataUpdated)
    Q_PROPERTY(float pm1 READ getPM1 NOTIFY dataUpdated)
    Q_PROPERTY(float pm25 READ getPM25 NOTIFY dataUpdated)
    Q_PROPERTY(float pm10 READ getPM10 NOTIFY dataUpdated)
    Q_PROPERTY(float o2 READ getO2 NOTIFY dataUpdated)
    Q_PROPERTY(float o3 READ getO3 NOTIFY dataUpdated)
    Q_PROPERTY(float co READ getCO NOTIFY dataUpdated)
    Q_PROPERTY(float co2 READ getCO2 NOTIFY dataUpdated)
    Q_PROPERTY(float no2 READ getNO2 NOTIFY dataUpdated)
    Q_PROPERTY(float so2 READ getSO2 NOTIFY dataUpdated)
    Q_PROPERTY(float voc READ getVOC NOTIFY dataUpdated)
    Q_PROPERTY(float hcho READ getHCHO NOTIFY dataUpdated)
    Q_PROPERTY(float radioactivity READ getRadioactivity NOTIFY dataUpdated)
    Q_PROPERTY(float radioactivityH READ getRH NOTIFY dataUpdated)
    Q_PROPERTY(float radioactivityM READ getRM NOTIFY dataUpdated)
    Q_PROPERTY(float radioactivityS READ getRS NOTIFY dataUpdated)

    // plant data (min/max)
    Q_PROPERTY(int hygroMin READ getSoilMoistureMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int hygroMax READ getSoilMoistureMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMin READ getSoilConduMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMax READ getSoilConduMax NOTIFY minmaxUpdated)
    // hygrometer data (min/max)
    Q_PROPERTY(float tempMin READ getTempMin NOTIFY minmaxUpdated)
    Q_PROPERTY(float tempMax READ getTempMax NOTIFY minmaxUpdated)
    Q_PROPERTY(float humiMin READ getHumiMin NOTIFY minmaxUpdated)
    Q_PROPERTY(float humiMax READ getHumiMax NOTIFY minmaxUpdated)
    // environmental data (min/max)
    Q_PROPERTY(int luxMin READ getLuxMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int luxMax READ getLuxMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int mmolMin READ getMmolMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int mmolMax READ getMmolMax NOTIFY minmaxUpdated)

    // plant limits
    Q_PROPERTY(int soilMoisture_limitMin READ getLimitSoilMoistureMin WRITE setLimitSoilMoistureMin NOTIFY limitsUpdated)
    Q_PROPERTY(int soilMoisture_limitMax READ getLimitSoilMoistureMax WRITE setLimitSoilMoistureMax NOTIFY limitsUpdated)
    Q_PROPERTY(int soilConductivity_limitMin READ getLimitSoilConduMin WRITE setLimitSoilConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int soilConductivity_limitMax READ getLimitSoilConduMax WRITE setLimitSoilConduMax NOTIFY limitsUpdated)
    Q_PROPERTY(float soilPH_limitMin READ getLimitSoilPhMin WRITE setLimitSoilPhMin NOTIFY limitsUpdated)
    Q_PROPERTY(float soilPH_limitMax READ getLimitSoilPhMax WRITE setLimitSoilPhMax NOTIFY limitsUpdated)
    // hygrometer limits
    Q_PROPERTY(int temperature_limitMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int temperature_limitMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    Q_PROPERTY(int humidity_limitMin READ getLimitHumiMin WRITE setLimitHumiMin NOTIFY limitsUpdated)
    Q_PROPERTY(int humidity_limitMax READ getLimitHumiMax WRITE setLimitHumiMax NOTIFY limitsUpdated)
    // environmental limits
    Q_PROPERTY(int luminosityLux_limitMin READ getLimitLuxMin WRITE setLimitLuxMin NOTIFY limitsUpdated)
    Q_PROPERTY(int luminosityLux_limitMax READ getLimitLuxMax WRITE setLimitLuxMax NOTIFY limitsUpdated)
    Q_PROPERTY(int luminosityMmol_limitMin READ getLimitMmolMin WRITE setLimitMmolMin NOTIFY limitsUpdated)
    Q_PROPERTY(int luminosityMmol_limitMax READ getLimitMmolMax WRITE setLimitMmolMax NOTIFY limitsUpdated)

    // sensor bias
    Q_PROPERTY(float soilMoisture_bias READ getBiasSoilMoisture WRITE setBiasSoilMoisture NOTIFY biasUpdated)
    Q_PROPERTY(float soilConductivity_bias READ getBiasSoilCondu WRITE setBiasSoilCondu NOTIFY biasUpdated)
    Q_PROPERTY(float soilTemperature_bias READ getBiasSoilTemp WRITE setBiasSoilTemp NOTIFY biasUpdated)
    Q_PROPERTY(float soilPH_bias READ getBiasSoilPH WRITE setBiasSoilPH NOTIFY biasUpdated)
    Q_PROPERTY(float temperature_bias READ getBiasTemperature WRITE setBiasTemperature NOTIFY biasUpdated)
    Q_PROPERTY(float humidity_bias READ getBiasHumidity WRITE setBiasHumidity NOTIFY biasUpdated)
    Q_PROPERTY(float luminosity_bias READ getBiasLuminosity WRITE setBiasLuminosity NOTIFY biasUpdated)
    Q_PROPERTY(float pressure_bias READ getBiasPressure WRITE setBiasPressure NOTIFY biasUpdated)

    // sensor history
    Q_PROPERTY(int historyUpdatePercent READ getHistoryUpdatePercent NOTIFY progressUpdated)

    // graphs
    Q_PROPERTY(QVariant aioHistoryData_month READ getChartData_history_month NOTIFY chartDataHistoryMonthsUpdated)
    Q_PROPERTY(QVariant aioHistoryData_week READ getChartData_history_week NOTIFY chartDataHistoryWeeksUpdated)
    Q_PROPERTY(QVariant aioHistoryData_day READ getChartData_history_day NOTIFY chartDataHistoryDaysUpdated)
    Q_PROPERTY(QVariant aioMinMaxData READ getChartData_minmax NOTIFY chartDataMinMaxUpdated)
    Q_PROPERTY(QVariant aioEnvData READ getChartData_env NOTIFY chartDataEnvUpdated)

Q_SIGNALS:
    void biasUpdated();
    void limitsUpdated();
    void minmaxUpdated();
    void progressUpdated();
    void chartDataHistoryMonthsUpdated();
    void chartDataHistoryWeeksUpdated();
    void chartDataHistoryDaysUpdated();
    void chartDataMinMaxUpdated();
    void chartDataEnvUpdated();

protected:
    bool m_hasDataFresh = false;
    bool m_hasDataToday = false;
    bool m_hasDataHistory = false;

    bool hasDataFresh() const { return m_hasDataFresh; }
    bool hasDataToday() const { return m_hasDataFresh || m_hasDataToday; }
    bool hasDataHistory() const { return m_hasDataFresh || m_hasDataToday || m_hasDataHistory; }

    // plant data
    int m_soilMoisture = -99;
    int m_soilConductivity = -99;
    float m_soilTemperature = -99.f;
    float m_soilPH = -99.f;
    float m_watertank_level = -99.f;
    float m_watertank_capacity = -99.f;
    // hygrometer data
    float m_temperature = -99.f;
    float m_humidity = -99.f;
    // environmental data
    float m_pressure = -99.f;
    int m_luminosityLux = -99;
    int m_luminosityMmol = -99;
    float m_uv = -99.f;
    float m_water_level = -99.f;
    float m_sound_level = -99.f;
    float m_windDirection = -99.f;
    float m_windSpeed = -99.f;
    float m_pm_1 = -99.f;
    float m_pm_25 = -99.f;
    float m_pm_10 = -99.f;
    float m_o2 = -99.f;
    float m_o3 = -99.f;
    float m_co = -99.f;
    float m_co2 = -99.f;
    float m_no2 = -99.f;
    float m_so2 = -99.f;
    float m_voc = -99.f;
    float m_hcho = -99.f;
    float m_radioactivity = -99.f;
    float m_rh = -99.f;
    float m_rm = -99.f;
    float m_rs = -99.f;

    // plant limits
    int m_soilMoisture_limit_min = 15;
    int m_soilMoisture_limit_max = 50;
    int m_soilConductivity_limit_min = 100;
    int m_soilConductivity_limit_max = 500;
    float m_soilPH_limit_min = 6.5f;
    float m_soilPH_limit_max = 7.5f;
    // hygrometer limits
    int m_temperature_limit_min = 14;
    int m_temperature_limit_max = 28;
    int m_humidity_limit_min = 40;
    int m_humidity_limit_max = 60;
    // environmental limits
    int m_luminosityLux_limit_min = 1000;
    int m_luminosityLux_limit_max = 3000;
    int m_luminosityMmol_limit_min = 0;
    int m_luminosityMmol_limit_max = 0;

    // sensor bias
    float m_soilMoisture_bias = 0.f;
    float m_soilConductivity_bias = 0.f;
    float m_soilTemperature_bias = 0.f;
    float m_soilPH_bias = 0.f;
    float m_temperature_bias = 0.f;
    float m_humidity_bias = 0.f;
    float m_luminosity_bias = 0.f;
    float m_pressure_bias = 0.f;

    // min/max data (generated - 30 days period)
    int m_soilMoistureMin = 999999;
    int m_soilMoistureMax = -99;
    int m_soilConduMin = 999999;
    int m_soilConduMax = -99;
    float m_soilTempMin = 99.f;
    float m_soilTempMax = -99.f;
    float m_soilPhMin = 999.f;
    float m_soilPhMax = -99.f;
    float m_tempMin = 999999.f;
    float m_tempMax = -99.f;
    float m_humiMin = 999999.f;
    float m_humiMax = -99.f;
    int m_luxMin = 999999;
    int m_luxMax = -99;
    int m_mmolMin = 999999;
    int m_mmolMax = -99;

    // device history control
    int m_history_entryCount = -1;
    int m_history_entryIndex = -1;
    int m_history_sessionCount = -1;
    int m_history_sessionRead = -1;

    // device clock
    int64_t m_device_lastmove = -1;

    // graphs data
    QList <QObject *> m_chartData_history_month;
    QList <QObject *> m_chartData_history_week;
    QList <QObject *> m_chartData_history_day;
    QList <QObject *> m_chartData_minmax;
    QList <QObject *> m_chartData_env;

    QVariant getChartData_history_month() const { return QVariant::fromValue(m_chartData_history_month); }
    QVariant getChartData_history_week() const { return QVariant::fromValue(m_chartData_history_week); }
    QVariant getChartData_history_day() const { return QVariant::fromValue(m_chartData_history_day); }
    QVariant getChartData_env() const { return QVariant::fromValue(m_chartData_env); }
    QVariant getChartData_minmax() const { return QVariant::fromValue(m_chartData_minmax); }

    // device infos
    DeviceInfos *m_deviceInfos = nullptr;
    DeviceInfos *getDeviceInfos() { return m_deviceInfos; }
    Q_PROPERTY(DeviceInfos *deviceInfos READ getDeviceInfos CONSTANT)

protected:
    virtual void refreshDataFinished(bool status, bool cached = false);
    virtual void refreshHistoryFinished(bool status);

    virtual bool getSqlDeviceInfos();

    virtual bool getSqlPlantData(int minutes);
    virtual bool getSqlPlantBias();
    virtual bool getSqlPlantLimits();

    virtual bool getSqlThermoLimits();
    virtual bool getSqlThermoBias();
    virtual bool getSqlThermoData(int minutes);

    virtual bool getSqlSensorData(int minutes);
    virtual bool getSqlSensorBias();
    virtual bool getSqlSensorLimits();

    virtual bool hasData() const;

public:
    DeviceSensor(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceSensor(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceSensor();

    Q_INVOKABLE bool hasDataNamed(const QString &dataName) const;
    Q_INVOKABLE int countDataNamed(const QString &dataName, int days = 31) const;

    bool hasSoilMoistureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_MOISTURE); }
    bool hasSoilConductivitySensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_CONDUCTIVITY); }
    bool hasSoilTemperatureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_TEMPERATURE); }
    bool hasSoilPhSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOIL_PH); }

    bool hasTemperatureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_TEMPERATURE); }
    bool hasHumiditySensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_HUMIDITY); }

    bool hasPressureSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PRESSURE); }
    bool hasLuminositySensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_LUMINOSITY); }
    bool hasUvSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_UV); }
    bool hasSoundSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SOUND); }
    bool hasWaterLevelSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_WATER_LEVEL); }
    bool hasWindDirectionSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_WIND_DIRECTION); }
    bool hasWindSpeedSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_WIND_SPEED); }
    bool hasPM1Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PM1); }
    bool hasPM25Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PM25); }
    bool hasPM10Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_PM10); }
    bool hasO2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_O2); }
    bool hasO3Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_O3); }
    bool hasCoSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_CO); }
    bool hasCo2Sensor() const { return ((m_deviceSensors & DeviceUtils::SENSOR_CO2) || (m_deviceSensors & DeviceUtils::SENSOR_eCO2)); }
    bool haseCo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_eCO2); }
    bool hasNo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_NO2); }
    bool hasSo2Sensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_SO2); }
    bool hasVocSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_VOC); }
    bool hasHchoSensor() const { return (m_deviceSensors & DeviceUtils::SENSOR_HCHO); }
    bool hasGeigerCounter() const { return (m_deviceSensors & DeviceUtils::SENSOR_GEIGER); }

    Q_INVOKABLE bool isDataAvailable() const;       //!< Has data, fresh or from history
    Q_INVOKABLE bool isDataToday() const;           //!< Has at most 12h old data
    Q_INVOKABLE bool isDataFresh_rt() const;        //!< Has at most Xh (user defined) old data (from immediate records)
    Q_INVOKABLE bool isDataFresh_db() const;        //!< Has at most Xh (user defined) old data (from database records)

    virtual void checkDataAvailability();
    virtual bool needsUpdateRt() const;             //!< Does this sensor has 'immediate' (but possibly incomplete) record
    virtual bool needsUpdateDb() const;             //!< Does this sensor has a recent record in the database
    virtual bool needsUpdateDb_mini() const;        //!< Does this sensor can save a new record in the database (instead of overwriting the current one)

    bool setSqlPlantBias();
    bool setSqlPlantLimits();
    bool setSqlThermoBias();
    bool setSqlThermoLimits();
    bool setSqlSensorBias();
    bool setSqlSensorLimits();

    // Plant sensor data
    int getSoilMoisture() const { return m_soilMoisture; }
    int getSoilConductivity() const { return m_soilConductivity; }
    float getSoilTemperature() const { return m_soilTemperature; }
    float getSoilPH() const { return m_soilPH; }
    float getWaterTankLevel() const { return m_watertank_level; }
    float getWaterTankCapacity() const { return m_watertank_capacity; }
    // Hygrometer
    float getTemp() const;
    float getTempC() const { return m_temperature; }
    float getTempF() const { return (m_temperature * 9.f/5.f + 32.f); }
    float getHumidity() const { return m_humidity; }
    // Environmental
    int getPressure() const { return m_pressure; }
    int getLuminosityLux() const { return m_luminosityLux; }
    int getLuminosityMmol() const { return m_luminosityMmol; }
    int getUV() const { return m_uv; }
    float getWaterLevel() const { return m_water_level; }
    float getSoundLevel() const { return m_sound_level; }
    float getWindDirection() const { return m_windDirection; }
    float getWindSpeed() const { return m_windSpeed; }
    float getPM1() { return m_pm_1; }
    float getPM25() { return m_pm_25; }
    float getPM10() { return m_pm_10; }
    float getO2() { return m_o2; }
    float getO3() { return m_o3; }
    float getCO() { return m_co; }
    float getCO2() { return m_co2; }
    float getSO2() { return m_so2; }
    float getNO2() { return m_no2; }
    float getVOC() { return m_voc; }
    float getHCHO() { return m_hcho; }
    // Geiger Counter
    float getRadioactivity() { return m_radioactivity; }
    float getRH() { return m_rh; }
    float getRM() { return m_rm; }
    float getRS() { return m_rs; }
    // others
    Q_INVOKABLE QString getTempString() const;
    Q_INVOKABLE float getHeatIndex() const;
    Q_INVOKABLE QString getHeatIndexString() const;
    Q_INVOKABLE float getDewPoint() const;
    Q_INVOKABLE QString getDewPointString() const;
    QDateTime getLastMove() const;
    float getLastMove_days() const;

    // Sensor bias
    float getBiasSoilMoisture() const { return m_soilMoisture_bias; }
    void setBiasSoilMoisture(float value) { m_soilMoisture_bias = value; setSqlPlantBias(); }
    float getBiasSoilCondu() const { return m_soilConductivity_bias; }
    void setBiasSoilCondu(float value) { m_soilConductivity_bias = value; setSqlPlantBias(); }
    float getBiasSoilTemp() const { return m_soilTemperature_bias; }
    void setBiasSoilTemp(float value) { m_soilTemperature_bias = value; setSqlPlantBias(); }
    float getBiasSoilPH() const { return m_soilPH_bias; }
    void setBiasSoilPH(float value) { m_soilPH_bias = value; setSqlPlantBias(); }
    float getBiasTemperature() const { return m_temperature_bias; }
    void setBiasTemperature(float value) { m_temperature_bias = value; setSqlPlantBias(); }
    float getBiasHumidity() const { return m_humidity_bias; }
    void setBiasHumidity(float value) { m_humidity_bias = value; setSqlPlantBias(); }
    float getBiasLuminosity() const { return m_luminosity_bias; }
    void setBiasLuminosity(float value) { m_luminosity_bias = value; setSqlPlantBias(); }
    float getBiasPressure() const { return m_pressure_bias; }
    void setBiasPressure(float value) { m_pressure_bias = value; setSqlPlantBias(); }

    // Sensor limits
    int getLimitSoilMoistureMin() const { return m_soilMoisture_limit_min; }
    int getLimitSoilMoistureMax() const { return m_soilMoisture_limit_max; }
    int getLimitSoilConduMin() const { return m_soilConductivity_limit_min; }
    int getLimitSoilConduMax() const { return m_soilConductivity_limit_max; }
    float getLimitSoilPhMin() const { return m_soilPH_limit_min; }
    float getLimitSoilPhMax() const { return m_soilPH_limit_max; }
    int getLimitTempMin() const { return m_temperature_limit_min; }
    int getLimitTempMax() const { return m_temperature_limit_max; }
    int getLimitHumiMin() const { return m_humidity_limit_min; }
    int getLimitHumiMax() const { return m_humidity_limit_max; }
    int getLimitLuxMin() const { return m_luminosityLux_limit_min; }
    int getLimitLuxMax() const { return m_luminosityLux_limit_max; }
    int getLimitMmolMin() const { return m_luminosityMmol_limit_min; }
    int getLimitMmolMax() const { return m_luminosityMmol_limit_max; }
    void setLimitSoilMoistureMin(int limitHygroMin) { if (m_soilMoisture_limit_min == limitHygroMin) return; m_soilMoisture_limit_min = limitHygroMin; setSqlPlantLimits(); }
    void setLimitSoilMoistureMax(int limitHygroMax) { if (m_soilMoisture_limit_max == limitHygroMax) return; m_soilMoisture_limit_max = limitHygroMax; setSqlPlantLimits(); }
    void setLimitSoilConduMin(int limitConduMin) { if (m_soilConductivity_limit_min == limitConduMin) return; m_soilConductivity_limit_min = limitConduMin; setSqlPlantLimits(); }
    void setLimitSoilConduMax(int limitConduMax) { if (m_soilConductivity_limit_max == limitConduMax) return; m_soilConductivity_limit_max = limitConduMax; setSqlPlantLimits(); }
    void setLimitSoilPhMin(float limitPhMin) { if (m_soilPH_limit_min == limitPhMin) return; m_soilPH_limit_min = limitPhMin; setSqlPlantLimits(); }
    void setLimitSoilPhMax(float limitPhMax) { if (m_soilPH_limit_max == limitPhMax) return; m_soilPH_limit_max = limitPhMax; setSqlPlantLimits(); }
    void setLimitTempMin(int limitTempMin) { if (m_temperature_limit_min == limitTempMin) return; m_temperature_limit_min = limitTempMin; setSqlPlantLimits(); }
    void setLimitTempMax(int limitTempMax) { if (m_temperature_limit_max == limitTempMax) return; m_temperature_limit_max = limitTempMax; setSqlPlantLimits(); }
    void setLimitHumiMin(int limitHumiMin) { if (m_humidity_limit_min == limitHumiMin) return; m_humidity_limit_min = limitHumiMin; setSqlPlantLimits(); }
    void setLimitHumiMax(int limitHumiMax) { if (m_humidity_limit_max == limitHumiMax) return; m_humidity_limit_max = limitHumiMax; setSqlPlantLimits(); }
    void setLimitLuxMin(int limitLuxMin) { if (m_luminosityLux_limit_min == limitLuxMin) return; m_luminosityLux_limit_min = limitLuxMin; setSqlPlantLimits(); }
    void setLimitLuxMax(int limitLuxMax) { if (m_luminosityLux_limit_max == limitLuxMax) return; m_luminosityLux_limit_max = limitLuxMax; setSqlPlantLimits(); }
    void setLimitMmolMin(int limitMmolMin) { if (m_luminosityMmol_limit_min == limitMmolMin) return; m_luminosityMmol_limit_min = limitMmolMin; setSqlPlantLimits(); }
    void setLimitMmolMax(int limitMmolMax) { if (m_luminosityMmol_limit_max == limitMmolMax) return; m_luminosityMmol_limit_max = limitMmolMax; setSqlPlantLimits(); }

    // Data min/max
    int getSoilMoistureMin() const { return m_soilMoistureMin; }
    int getSoilMoistureMax() const { return m_soilMoistureMax; }
    int getSoilConduMin() const { return m_soilConduMin; }
    int getSoilConduMax() const { return m_soilConduMax; }
    float getSoilTempMin() const { return m_soilTempMin; }
    float getSoilTempMax() const { return m_soilTempMax; }
    float getSoilPhMin() const { return m_soilPhMin; }
    float getSoilPhMax() const { return m_soilPhMax; }
    float getTempMin() const { return m_tempMin; }
    float getTempMax() const { return m_tempMax; }
    float getHumiMin() const { return m_humiMin; }
    float getHumiMax() const { return m_humiMax; }
    int getLuxMin() const { return m_luxMin; }
    int getLuxMax() const { return m_luxMax; }
    int getMmolMin() const { return m_mmolMin; }
    int getMmolMax() const { return m_mmolMax; }

    // History sync
    int getHistoryUpdatePercent() const;
};

/* ************************************************************************** */
#endif // DEVICE_SENSOR_H

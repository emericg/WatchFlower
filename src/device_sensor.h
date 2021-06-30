/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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

#include <QObject>
#include <QString>

#include "device.h"

/* ************************************************************************** */

/*!
 * \brief The DeviceSensor class
 */
class DeviceSensor: public Device
{
    Q_OBJECT

    Q_PROPERTY(QString devicePlantName READ getAssociatedName NOTIFY sensorUpdated) // legacy

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
    // environmental data
    Q_PROPERTY(int pressure READ getPressure NOTIFY dataUpdated)
    Q_PROPERTY(int luminosity READ getLuminosity NOTIFY dataUpdated)
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
    Q_PROPERTY(float radioactivityH READ getRH NOTIFY dataUpdated)
    Q_PROPERTY(float radioactivityM READ getRM NOTIFY dataUpdated)
    Q_PROPERTY(float radioactivityS READ getRS NOTIFY dataUpdated)

    // plant data (min/max)
    Q_PROPERTY(int hygroMin READ getHygroMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int hygroMax READ getHygroMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMin READ getConduMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMax READ getConduMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int mmolMin READ getMmolMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int mmolMax READ getMmolMax NOTIFY minmaxUpdated)
    // hygrometer data (min/max)
    Q_PROPERTY(float tempMin READ getTempMin NOTIFY minmaxUpdated)
    Q_PROPERTY(float tempMax READ getTempMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int humiMin READ getHumiMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int humiMax READ getHumiMax NOTIFY minmaxUpdated)
    // environmental data (min/max)
    Q_PROPERTY(int luxMin READ getLuxMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int luxMax READ getLuxMax NOTIFY minmaxUpdated)

    // plant limits
    Q_PROPERTY(int limitHygroMin READ getLimitHygroMin WRITE setLimitHygroMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHygroMax READ getLimitHygroMax WRITE setLimitHygroMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMin READ getLimitConduMin WRITE setLimitConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMax READ getLimitConduMax WRITE setLimitConduMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitMmolMin READ getLimitMmolMin WRITE setLimitMmolMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitMmolMax READ getLimitMmolMax WRITE setLimitMmolMax NOTIFY limitsUpdated)
    // hygrometer limits
    Q_PROPERTY(int limitTempMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    // environmental limits
    Q_PROPERTY(int limitLuxMin READ getLimitLuxMin WRITE setLimitLuxMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLuxMax READ getLimitLuxMax WRITE setLimitLuxMax NOTIFY limitsUpdated)

    // sensor history
    Q_PROPERTY(int historyUpdatePercent READ getHistoryUpdatePercent NOTIFY historyUpdated)

    // graphs
    Q_PROPERTY(QVariant aioHistoryData_month READ getChartData_history_month NOTIFY chartDataHistoryUpdated_days)
    Q_PROPERTY(QVariant aioHistoryData_week READ getChartData_history_week NOTIFY chartDataHistoryUpdated_days)
    Q_PROPERTY(QVariant aioHistoryData_day READ getChartData_history_day NOTIFY chartDataHistoryUpdated_hours)
    Q_PROPERTY(QVariant aioMinMaxData READ getChartData_minmax NOTIFY chartDataMinMaxUpdated)
    Q_PROPERTY(QVariant aioEnvData READ getChartData_env NOTIFY chartDataEnvUpdated)

Q_SIGNALS:
    void minmaxUpdated();
    void limitsUpdated();
    void chartDataHistoryUpdated_days();
    void chartDataHistoryUpdated_hours();
    void chartDataMinMaxUpdated();
    void chartDataEnvUpdated();

protected:
    // plant data
    int m_soil_moisture = -99;
    int m_soil_conductivity = -99;
    float m_soil_temperature = -99.f;
    float m_soil_ph = -99.f;
    float m_watertank_level = -99.f;
    float m_watertank_capacity = -99.f;
    // hygrometer data
    float m_temperature = -99.f;
    float m_humidity = -99.f;
    // environmental data
    float m_pressure = -99.f;
    int m_luminosity = -99;
    float m_uv = -99.f;
    float m_water_level = -99.f;
    float m_sound_level = -99.f;
    float m_wind_direction = -99.f;
    float m_wind_speed = -99.f;
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
    float m_rh = -99.f;
    float m_rm = -99.f;
    float m_rs = -99.f;

    // plant limits
    int m_limitHygroMin = 15;
    int m_limitHygroMax = 50;
    int m_limitConduMin = 100;
    int m_limitConduMax = 500;
    float m_limitPhMin = 6.5;
    float m_limitPhMax = 7.5;
    int m_limitLuxMin = 1000;
    int m_limitLuxMax = 3000;
    int m_limitMmolMin = 0;
    int m_limitMmolMax = 0;
    // hygrometer limits
    int m_limitTempMin = 14;
    int m_limitTempMax = 28;
    int m_limitHumiMin = 40;
    int m_limitHumiMax = 60;
    // environmental limits

    // min/max data (30 days period)
    int m_soilMoistureMin = 999999;
    int m_soildMoistureMax = -99;
    int m_soilConduMin = 999999;
    int m_soilConduMax = -99;
    int m_soilTempMin = 99.f;
    int m_soilTempMax = -99.f;
    float m_soilPhMin = 999.f;
    float m_soilPhMax = -99.f;
    int m_tempMin = 99.f;
    int m_tempMax = -99.f;
    int m_humiMin = 999999;
    int m_humiMax = -99;
    int m_luxMin = 999999;
    int m_luxMax = -99;
    int m_mmolMin = 999999;
    int m_mmolMax = -99;

    // history control
    int m_history_entry_count = -1;
    int m_history_entry_index = -1;
    int m_history_session_count = -1;
    int m_history_session_read = -1;

    // device clock
    int64_t m_device_lastmove = -1;

    // graphs data
    QList <QObject *> m_chartData_history_month;
    QList <QObject *> m_chartData_history_week;
    QList <QObject *> m_chartData_history_day;
    QList <QObject *> m_chartData_minmax;
    QList <QObject *> m_chartData_env;

protected:
    virtual void refreshDataFinished(bool status, bool cached = false);
    virtual void refreshHistoryFinished(bool status);

    virtual bool getSqlDeviceInfos();
    virtual bool getSqlPlantLimits();
    virtual bool getSqlPlantData(int minutes);
    virtual bool getSqlSensorLimits();
    virtual bool getSqlSensorData(int minutes);

public:
    DeviceSensor(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceSensor(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceSensor();

public slots:
    virtual bool hasData() const;
    bool hasData(const QString &dataName) const;
    int countData(const QString &dataName, int days = 31) const;

    // Plant sensor data
    int getSoilMoisture() const { return m_soil_moisture; }
    int getSoilConductivity() const { return m_soil_conductivity; }
    float getSoilTemperature() const { return m_soil_temperature; }
    float getSoilPH() const { return m_soil_ph; }
    float getWaterTankLevel() const { return m_watertank_level; }
    float getWaterTankCapacity() const { return m_watertank_capacity; }
    QDateTime getLastMove() const;
    float getLastMove_days() const;
    // Hygrometer
    float getTemp() const;
    float getTempC() const { return m_temperature; }
    float getTempF() const { return (m_temperature * 9.f/5.f + 32.f); }
    QString getTempString() const;
    float getHeatIndex() const;
    QString getHeatIndexString() const;
    float getHumidity() const { return m_humidity; }
    // Environmental
    int getPressure() const { return m_pressure; }
    int getLuminosity() const { return m_luminosity; }
    int getUV() const { return m_uv; }
    float getWaterLevel() const { return m_water_level; }
    float getSoundLevel() const { return m_sound_level; }
    float getWindDirection() const { return m_wind_direction; }
    float getWindSpeed() const { return m_wind_speed; }
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
    float getRH() { return m_rh; }
    float getRM() { return m_rm; }
    float getRS() { return m_rs; }

    // BLE device limits
    bool setDbLimits();
    int getLimitHygroMin() const { return m_limitHygroMin; }
    int getLimitHygroMax() const { return m_limitHygroMax; }
    int getLimitConduMin() const { return m_limitConduMin; }
    int getLimitConduMax() const { return m_limitConduMax; }
    int getLimitTempMin() const { return m_limitTempMin; }
    int getLimitTempMax() const { return m_limitTempMax; }
    int getLimitHumiMin() const { return m_limitHumiMin; }
    int getLimitHumiMax() const { return m_limitHumiMax; }
    int getLimitLuxMin() const { return m_limitLuxMin; }
    int getLimitLuxMax() const { return m_limitLuxMax; }
    int getLimitMmolMin() const { return m_limitMmolMin; }
    int getLimitMmolMax() const { return m_limitMmolMax; }
    void setLimitHygroMin(int limitHygroMin) { if (m_limitHygroMin == limitHygroMin) return; m_limitHygroMin = limitHygroMin; setDbLimits(); }
    void setLimitHygroMax(int limitHygroMax) { if (m_limitHygroMax == limitHygroMax) return; m_limitHygroMax = limitHygroMax; setDbLimits(); }
    void setLimitConduMin(int limitConduMin) { if (m_limitConduMin == limitConduMin) return; m_limitConduMin = limitConduMin; setDbLimits(); }
    void setLimitConduMax(int limitConduMax) { if (m_limitConduMax == limitConduMax) return; m_limitConduMax = limitConduMax; setDbLimits(); }
    void setLimitTempMin(int limitTempMin) { if (m_limitTempMin == limitTempMin) return; m_limitTempMin = limitTempMin; setDbLimits(); }
    void setLimitTempMax(int limitTempMax) { if (m_limitTempMax == limitTempMax) return; m_limitTempMax = limitTempMax; setDbLimits(); }
    void setLimitHumiMin(int limitHumiMin) { if (m_limitHumiMin == limitHumiMin) return; m_limitHumiMin = limitHumiMin; setDbLimits(); }
    void setLimitHumiMax(int limitHumiMax) { if (m_limitHumiMax == limitHumiMax) return; m_limitHumiMax = limitHumiMax; setDbLimits(); }
    void setLimitLuxMin(int limitLuxMin) { if (m_limitLuxMin == limitLuxMin) return; m_limitLuxMin = limitLuxMin; setDbLimits(); }
    void setLimitLuxMax(int limitLuxMax) { if (m_limitLuxMax == limitLuxMax) return; m_limitLuxMax = limitLuxMax; setDbLimits(); }
    void setLimitMmolMin(int limitMmolMin) { if (m_limitMmolMin == limitMmolMin) return; m_limitMmolMin = limitMmolMin; setDbLimits(); }
    void setLimitMmolMax(int limitMmolMax) { if (m_limitMmolMax == limitMmolMax) return; m_limitMmolMax = limitMmolMax; setDbLimits(); }

    // Data min/max
    int getHygroMin() const { return m_soilMoistureMin; }
    int getHygroMax() const { return m_soildMoistureMax; }
    int getConduMin() const { return m_soilConduMin; }
    int getConduMax() const { return m_soilConduMax; }
    float getTempMin() const { return m_tempMin; }
    float getTempMax() const { return m_tempMax; }
    int getHumiMin() const { return m_humiMin; }
    int getHumiMax() const { return m_humiMax; }
    int getLuxMin() const { return m_luxMin; }
    int getLuxMax() const { return m_luxMax; }
    int getMmolMin() const { return m_mmolMin; }
    int getMmolMax() const { return m_mmolMax; }

    // History sync
    int getHistoryUpdatePercent() const;

    // Chart history
    void updateChartData_history_days(int maxDays);
    void updateChartData_history_hours();
    QVariant getChartData_history_month() const { return QVariant::fromValue(m_chartData_history_month); }
    QVariant getChartData_history_week() const { return QVariant::fromValue(m_chartData_history_week); }
    QVariant getChartData_history_day() const { return QVariant::fromValue(m_chartData_history_day); }

    // Chart environmental histogram
    void updateChartData_environmentalVoc(int maxDays);
    QVariant getChartData_env() const { return QVariant::fromValue(m_chartData_env); }

    // Chart temperature "min max"
    void updateChartData_thermometerMinMax(int maxDays);
    QVariant getChartData_minmax() const { return QVariant::fromValue(m_chartData_minmax); }

    // Chart plant AIO
    void getChartData_plantAIO(int maxDays, QtCharts::QDateTimeAxis *axis,
                               QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *condu,
                               QtCharts::QLineSeries *temp, QtCharts::QLineSeries *lumi);
};

/* ************************************************************************** */
#endif // DEVICE_SENSOR_H

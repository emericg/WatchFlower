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
#include "Journal.h"

#include <QObject>
#include <QString>
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
    Q_PROPERTY(float heatIndex READ getHeatIndex NOTIFY dataUpdated)
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
    Q_PROPERTY(int humiMin READ getHumiMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int humiMax READ getHumiMax NOTIFY minmaxUpdated)
    // environmental data (min/max)
    Q_PROPERTY(int luxMin READ getLuxMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int luxMax READ getLuxMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int mmolMin READ getMmolMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int mmolMax READ getMmolMax NOTIFY minmaxUpdated)

    // plant limits
    Q_PROPERTY(int limitHygroMin READ getLimitSoilMoistureMin WRITE setLimitSoilMoistureMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHygroMax READ getLimitSoilMoistureMax WRITE setLimitSoilMoistureMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMin READ getLimitSoilConduMin WRITE setLimitSoilConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMax READ getLimitSoilConduMax WRITE setLimitSoilConduMax NOTIFY limitsUpdated)
    Q_PROPERTY(float limitSoilPhMin READ getLimitSoilPhMin WRITE setLimitSoilPhMin NOTIFY limitsUpdated)
    Q_PROPERTY(float limitSoilPhMax READ getLimitSoilPhMax WRITE setLimitSoilPhMax NOTIFY limitsUpdated)
    // hygrometer limits
    Q_PROPERTY(int limitTempMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHumiMin READ getLimitHumiMin WRITE setLimitHumiMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHumiMax READ getLimitHumiMax WRITE setLimitHumiMax NOTIFY limitsUpdated)
    // environmental limits
    Q_PROPERTY(int limitLuxMin READ getLimitLuxMin WRITE setLimitLuxMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLuxMax READ getLimitLuxMax WRITE setLimitLuxMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitMmolMin READ getLimitMmolMin WRITE setLimitMmolMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitMmolMax READ getLimitMmolMax WRITE setLimitMmolMax NOTIFY limitsUpdated)

    // sensor bias
    Q_PROPERTY(float biasSoilMoisture READ getBiasSoilMoisture WRITE setBiasSoilMoisture NOTIFY biasUpdated)
    Q_PROPERTY(float biasSoilConductivity READ getBiasSoilCondu WRITE setBiasSoilCondu NOTIFY biasUpdated)
    Q_PROPERTY(float biasSoilTemperature READ getBiasSoilTemp WRITE setBiasSoilTemp NOTIFY biasUpdated)
    Q_PROPERTY(float biasSoilPH READ getBiasSoilPH WRITE setBiasSoilPH NOTIFY biasUpdated)
    Q_PROPERTY(float biasTemperature READ getBiasTemperature WRITE setBiasTemperature NOTIFY biasUpdated)
    Q_PROPERTY(float biasHumidity READ getBiasHumidity WRITE setBiasHumidity NOTIFY biasUpdated)
    Q_PROPERTY(float biasPressure READ getBiasPressure WRITE setBiasPressure NOTIFY biasUpdated)
    Q_PROPERTY(float biasLuminosityLux READ getBiasLuminosity WRITE setBiasLuminosity NOTIFY biasUpdated)

    // sensor history
    Q_PROPERTY(int historyUpdatePercent READ getHistoryUpdatePercent NOTIFY progressUpdated)

    // journal entries
    Q_PROPERTY(QVariant journalEntries READ getJournalEntries NOTIFY journalUpdated)

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
    void journalUpdated();
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
    float m_rh = -99.f;
    float m_rm = -99.f;
    float m_rs = -99.f;

    // plant limits
    int m_limit_soilMoistureMin = 15;
    int m_limit_soilMoistureMax = 50;
    int m_limit_soilConduMin = 100;
    int m_limit_soilConduMax = 500;
    float m_limit_soilPhMin = 6.5f;
    float m_limit_soilPhMax = 7.5f;
    // hygrometer limits
    int m_limit_tempMin = 14;
    int m_limit_tempMax = 28;
    int m_limit_humiMin = 40;
    int m_limit_humiMax = 60;
    // environmental limits
    int m_limit_luxMin = 1000;
    int m_limit_luxMax = 3000;
    int m_limit_mmolMin = 0;
    int m_limit_mmolMax = 0;

    // sensor bias
    float m_bias_soilMoisture = 0.f;
    float m_bias_soilConductivity = 0.f;
    float m_bias_soilTemperature = 0.f;
    float m_bias_soilPH = 0.f;
    float m_bias_temperature = 0.f;
    float m_bias_humidity = 0.f;
    float m_bias_pressure = 0.f;
    float m_bias_luminosityLux = 0.f;

    // min/max data (30 days period)
    int m_soilMoistureMin = 999999;
    int m_soilMoistureMax = -99;
    int m_soilConduMin = 999999;
    int m_soilConduMax = -99;
    float m_soilTempMin = 99.f;
    float m_soilTempMax = -99.f;
    float m_soilPhMin = 999.f;
    float m_soilPhMax = -99.f;
    float m_tempMin = 99.f;
    float m_tempMax = -99.f;
    int m_humiMin = 999999;
    int m_humiMax = -99;
    int m_luxMin = 999999;
    int m_luxMax = -99;
    int m_mmolMin = 999999;
    int m_mmolMax = -99;

    // history control
    int m_history_entryCount = -1;
    int m_history_entryIndex = -1;
    int m_history_sessionCount = -1;
    int m_history_sessionRead = -1;

    // device clock
    int64_t m_device_lastmove = -1;

    // journal entries
    QList <QObject *> m_journal_entries;
    QVariant getJournalEntries() const { return QVariant::fromValue(m_journal_entries); }

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
    virtual bool getSqlPlantLimits();
    virtual bool getSqlPlantData(int minutes);
    virtual bool getSqlSensorBias();
    virtual bool getSqlSensorLimits();
    virtual bool getSqlSensorData(int minutes);

    virtual bool hasData() const;

public:
    DeviceSensor(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceSensor(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceSensor();

    Q_INVOKABLE bool hasDataNamed(const QString &dataName) const;
    Q_INVOKABLE int countDataNamed(const QString &dataName, int days = 31) const;

    Q_INVOKABLE bool isDataFresh() const;           //!< Has at most Xh (user set) old data
    Q_INVOKABLE bool isDataToday() const;           //!< Has at most 12h old data
    Q_INVOKABLE bool isDataAvailable() const;       //!< Has data, immediate or from history

    virtual void checkDataAvailability();
    virtual bool needsUpdateRt() const;
    virtual bool needsUpdateDb() const;

    // Plant sensor data
    int getSoilMoisture() const { return m_soilMoisture; }
    int getSoilConductivity() const { return m_soilConductivity; }
    float getSoilTemperature() const { return m_soilTemperature; }
    float getSoilPH() const { return m_soilPH; }
    float getWaterTankLevel() const { return m_watertank_level; }
    float getWaterTankCapacity() const { return m_watertank_capacity; }
    QDateTime getLastMove() const;
    float getLastMove_days() const;
    // Hygrometer
    float getTemp() const;
    float getTempC() const { return m_temperature; }
    float getTempF() const { return (m_temperature * 9.f/5.f + 32.f); }
    Q_INVOKABLE QString getTempString() const;
    Q_INVOKABLE float getHeatIndex() const;
    Q_INVOKABLE QString getHeatIndexString() const;
    Q_INVOKABLE float getDewPoint() const;
    Q_INVOKABLE QString getDewPointString() const;
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
    float getRH() { return m_rh; }
    float getRM() { return m_rm; }
    float getRS() { return m_rs; }

    // Sensor bias
    bool setDbBias();
    float getBiasSoilMoisture() const { return m_bias_soilMoisture; }
    void setBiasSoilMoisture(float value) { m_bias_soilMoisture = value; setDbBias(); }
    float getBiasSoilCondu() const { return m_bias_soilConductivity; }
    void setBiasSoilCondu(float value) { m_bias_soilConductivity = value; setDbBias(); }
    float getBiasSoilTemp() const { return m_bias_soilTemperature; }
    void setBiasSoilTemp(float value) { m_bias_soilTemperature = value; setDbBias(); }
    float getBiasSoilPH() const { return m_bias_soilPH; }
    void setBiasSoilPH(float value) { m_bias_soilPH = value; setDbBias(); }
    float getBiasTemperature() const { return m_bias_temperature; }
    void setBiasTemperature(float value) { m_bias_temperature = value; setDbBias(); }
    float getBiasHumidity() const { return m_bias_humidity; }
    void setBiasHumidity(float value) { m_bias_humidity = value; setDbBias(); }
    float getBiasPressure() const { return m_bias_pressure; }
    void setBiasPressure(float value) { m_bias_pressure = value; setDbBias(); }
    float getBiasLuminosity() const { return m_bias_luminosityLux; }
    void setBiasLuminosity(float value) { m_bias_luminosityLux = value; setDbBias(); }

    // Sensor limits
    bool setDbLimits();
    int getLimitSoilMoistureMin() const { return m_limit_soilMoistureMin; }
    int getLimitSoilMoistureMax() const { return m_limit_soilMoistureMax; }
    int getLimitSoilConduMin() const { return m_limit_soilConduMin; }
    int getLimitSoilConduMax() const { return m_limit_soilConduMax; }
    float getLimitSoilPhMin() const { return m_limit_soilPhMin; }
    float getLimitSoilPhMax() const { return m_limit_soilPhMax; }
    int getLimitTempMin() const { return m_limit_tempMin; }
    int getLimitTempMax() const { return m_limit_tempMax; }
    int getLimitHumiMin() const { return m_limit_humiMin; }
    int getLimitHumiMax() const { return m_limit_humiMax; }
    int getLimitLuxMin() const { return m_limit_luxMin; }
    int getLimitLuxMax() const { return m_limit_luxMax; }
    int getLimitMmolMin() const { return m_limit_mmolMin; }
    int getLimitMmolMax() const { return m_limit_mmolMax; }
    void setLimitSoilMoistureMin(int limitHygroMin) { if (m_limit_soilMoistureMin == limitHygroMin) return; m_limit_soilMoistureMin = limitHygroMin; setDbLimits(); }
    void setLimitSoilMoistureMax(int limitHygroMax) { if (m_limit_soilMoistureMax == limitHygroMax) return; m_limit_soilMoistureMax = limitHygroMax; setDbLimits(); }
    void setLimitSoilConduMin(int limitConduMin) { if (m_limit_soilConduMin == limitConduMin) return; m_limit_soilConduMin = limitConduMin; setDbLimits(); }
    void setLimitSoilConduMax(int limitConduMax) { if (m_limit_soilConduMax == limitConduMax) return; m_limit_soilConduMax = limitConduMax; setDbLimits(); }
    void setLimitSoilPhMin(float limitPhMin) { if (m_limit_soilPhMin == limitPhMin) return; m_limit_soilPhMin = limitPhMin; setDbLimits(); }
    void setLimitSoilPhMax(float limitPhMax) { if (m_limit_soilPhMax == limitPhMax) return; m_limit_soilPhMax = limitPhMax; setDbLimits(); }
    void setLimitTempMin(int limitTempMin) { if (m_limit_tempMin == limitTempMin) return; m_limit_tempMin = limitTempMin; setDbLimits(); }
    void setLimitTempMax(int limitTempMax) { if (m_limit_tempMax == limitTempMax) return; m_limit_tempMax = limitTempMax; setDbLimits(); }
    void setLimitHumiMin(int limitHumiMin) { if (m_limit_humiMin == limitHumiMin) return; m_limit_humiMin = limitHumiMin; setDbLimits(); }
    void setLimitHumiMax(int limitHumiMax) { if (m_limit_humiMax == limitHumiMax) return; m_limit_humiMax = limitHumiMax; setDbLimits(); }
    void setLimitLuxMin(int limitLuxMin) { if (m_limit_luxMin == limitLuxMin) return; m_limit_luxMin = limitLuxMin; setDbLimits(); }
    void setLimitLuxMax(int limitLuxMax) { if (m_limit_luxMax == limitLuxMax) return; m_limit_luxMax = limitLuxMax; setDbLimits(); }
    void setLimitMmolMin(int limitMmolMin) { if (m_limit_mmolMin == limitMmolMin) return; m_limit_mmolMin = limitMmolMin; setDbLimits(); }
    void setLimitMmolMax(int limitMmolMax) { if (m_limit_mmolMax == limitMmolMax) return; m_limit_mmolMax = limitMmolMax; setDbLimits(); }

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
    int getHumiMin() const { return m_humiMin; }
    int getHumiMax() const { return m_humiMax; }
    int getLuxMin() const { return m_luxMin; }
    int getLuxMax() const { return m_luxMax; }
    int getMmolMin() const { return m_mmolMin; }
    int getMmolMax() const { return m_mmolMax; }

    // History sync
    int getHistoryUpdatePercent() const;

    // Journal
    Q_INVOKABLE void addJournalEntry(const int type, const QDateTime &date, const QString &comment);

    // Chart history
    Q_INVOKABLE void updateChartData_history_month(int maxDays);
    Q_INVOKABLE void updateChartData_history_month(const QDateTime &f, const QDateTime &l);
    Q_INVOKABLE void updateChartData_history_day();
    Q_INVOKABLE void updateChartData_history_day(const QDateTime &d);

    // Chart environmental histogram
    Q_INVOKABLE void updateChartData_environmentalVoc(int maxDays);

    // Chart temperature "min max"
    Q_INVOKABLE void updateChartData_thermometerMinMax(int maxDays);

    // Chart plant AIO
    Q_INVOKABLE void getChartData_plantAIO(int maxDays, QDateTimeAxis *axis,
                                           QLineSeries *hygro, QLineSeries *condu,
                                           QLineSeries *temp, QLineSeries *lumi);
};

/* ************************************************************************** */
#endif // DEVICE_SENSOR_H

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

#ifndef DEVICE_SENSORS_H
#define DEVICE_SENSORS_H
/* ************************************************************************** */

#include <QObject>

#include "device.h"

/* ************************************************************************** */

/*!
 * \brief The DeviceSensors class
 */
class DeviceSensors: public Device
{
    Q_OBJECT

    // data
    Q_PROPERTY(float deviceTemp READ getTemp NOTIFY dataUpdated)
    Q_PROPERTY(float deviceTempC READ getTempC NOTIFY dataUpdated)
    Q_PROPERTY(float deviceTempF READ getTempF NOTIFY dataUpdated)
    Q_PROPERTY(int deviceHumidity READ getHumidity NOTIFY dataUpdated)
    Q_PROPERTY(int deviceLuminosity READ getLuminosity NOTIFY dataUpdated)
    Q_PROPERTY(int deviceSoilMoisture READ getSoilMoisture NOTIFY dataUpdated)
    Q_PROPERTY(int deviceSoilConductivity READ getSoilConductivity NOTIFY dataUpdated)

    // min/max
    Q_PROPERTY(int hygroMin READ getHygroMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int hygroMax READ getHygroMax NOTIFY minmaxUpdated)
    Q_PROPERTY(float tempMin READ getTempMin NOTIFY minmaxUpdated)
    Q_PROPERTY(float tempMax READ getTempMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int lumiMin READ getLumiMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int lumiMax READ getLumiMax NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMin READ getConduMin NOTIFY minmaxUpdated)
    Q_PROPERTY(int conduMax READ getConduMax NOTIFY minmaxUpdated)

    // plant limits
    Q_PROPERTY(int limitHygroMin READ getLimitHygroMin WRITE setLimitHygroMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHygroMax READ getLimitHygroMax WRITE setLimitHygroMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMin READ getLimitLumiMin WRITE setLimitLumiMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMax READ getLimitLumiMax WRITE setLimitLumiMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMin READ getLimitConduMin WRITE setLimitConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMax READ getLimitConduMax WRITE setLimitConduMax NOTIFY limitsUpdated)

    // other sensors
    Q_PROPERTY(float deviceRadioactivityH READ getRH NOTIFY dataUpdated)
    Q_PROPERTY(float deviceRadioactivityM READ getRM NOTIFY dataUpdated)
    Q_PROPERTY(float deviceRadioactivityS READ getRS NOTIFY dataUpdated)

    // graphs
    Q_PROPERTY(QVariant aioMinMaxData READ getAioMinMaxData NOTIFY aioMinMaxDataUpdated)

Q_SIGNALS:
    void minmaxUpdated();
    void limitsUpdated();
    void aioMinMaxDataUpdated();

protected:
    // plant data
    int m_soil_moisture = -99;
    int m_soil_conductivity = -99;
    float m_soil_temperature = -99.f;
    float m_soil_ph = -99.f;
    // hygrometer data
    float m_temperature = -99.f;
    int m_humidity = -99;
    // environmental data
    int m_luminosity = -99;
    int m_uv = -99;
    float m_rh = 999.f;
    float m_rm = -99.f;
    float m_rs = -99.f;

    // plant limits
    int m_limitHygroMin = 15;
    int m_limitHygroMax = 50;
    int m_limitTempMin = 14;
    int m_limitTempMax = 28;
    int m_limitLumiMin = 1000;
    int m_limitLumiMax = 3000;
    int m_limitConduMin = 100;
    int m_limitConduMax = 500;

    // SQL min/max data (x days period)
    float m_tempMin = 999.f;
    float m_tempMax = -99.f;
    int m_hygroMin = 99999;
    int m_hygroMax = -99;
    int m_luminosityMin = 99999;
    int m_luminosityMax = -99;
    int m_conductivityMin = 99999;
    int m_conductivityMax = -99;

    //
    QList <QObject *> m_aio_minmax_data;

    virtual void refreshDataFinished(bool status, bool cached = false);

    virtual bool getSqlInfos();
    virtual bool getSqlLimits();
    virtual bool getSqlData(int minutes);

public:
    DeviceSensors(QString &deviceAddr, QString &deviceName, QObject *parent = nullptr);
    DeviceSensors(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~DeviceSensors();

public slots:
    bool hasData() const;
    bool hasData(const QString &dataName) const;
    int countData(const QString &dataName, int days = 31) const;

    // BLE device data
    int getSoilMoisture() const { return m_soil_moisture; }
    int getSoilConductivity() const { return m_soil_conductivity; }
    int getSoilTemperature() const { return m_soil_temperature; }
    int getSoilPH() const { return m_soil_ph; }
    //
    float getTemp() const;
    float getTempC() const { return m_temperature; }
    float getTempF() const { return (m_temperature * 9.f/5.f + 32.f); }
    QString getTempString() const;
    int getHumidity() const { return m_humidity; }
    int getLuminosity() const { return m_luminosity; }
    //
    float getRH() { return m_rh; }
    float getRM() { return m_rm; }
    float getRS() { return m_rs; }

    int getHygroMin() const { return m_hygroMin; }
    int getHygroMax() const { return m_hygroMax; }
    float getTempMin() const { return m_tempMin; }
    float getTempMax() const { return m_tempMax; }
    int getLumiMin() const { return m_luminosityMin; }
    int getLumiMax() const { return m_luminosityMax; }
    int getConduMin() const { return m_conductivityMin; }
    int getConduMax() const { return m_conductivityMax; }

    // BLE device limits
    int getLimitHygroMin() const { return m_limitHygroMin; }
    int getLimitHygroMax() const { return m_limitHygroMax; }
    int getLimitTempMin() const { return m_limitTempMin; }
    int getLimitTempMax() const { return m_limitTempMax; }
    int getLimitLumiMin() const { return m_limitLumiMin; }
    int getLimitLumiMax() const { return m_limitLumiMax; }
    int getLimitConduMin() const { return m_limitConduMin; }
    int getLimitConduMax() const { return m_limitConduMax; }
    void setLimitHygroMin(int limitHygroMin) { if (m_limitHygroMin == limitHygroMin) return; m_limitHygroMin = limitHygroMin; setDbLimits(); }
    void setLimitHygroMax(int limitHygroMax) { if (m_limitHygroMax == limitHygroMax) return; m_limitHygroMax = limitHygroMax; setDbLimits(); }
    void setLimitTempMin(int limitTempMin) { if (m_limitTempMin == limitTempMin) return; m_limitTempMin = limitTempMin; setDbLimits(); }
    void setLimitTempMax(int limitTempMax) { if (m_limitTempMax == limitTempMax) return; m_limitTempMax = limitTempMax; setDbLimits(); }
    void setLimitLumiMin(int limitLumiMin) { if (m_limitLumiMin == limitLumiMin) return; m_limitLumiMin = limitLumiMin; setDbLimits(); }
    void setLimitLumiMax(int limitLumiMax) { if (m_limitLumiMax == limitLumiMax) return; m_limitLumiMax = limitLumiMax; setDbLimits(); }
    void setLimitConduMin(int limitConduMin) { if (m_limitConduMin == limitConduMin) return; m_limitConduMin = limitConduMin; setDbLimits(); }
    void setLimitConduMax(int limitConduMax) { if (m_limitConduMax == limitConduMax) return; m_limitConduMax = limitConduMax; setDbLimits(); }
    bool setDbLimits();

    // AIO temperature "min max" graph
    void updateAioMinMaxData(int maxDays);
    QVariant getAioMinMaxData() const { return QVariant::fromValue(m_aio_minmax_data); }

    // AIO line graph
    void getAioLinesData(int maxDays, QtCharts::QDateTimeAxis *axis,
                         QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *temp,
                         QtCharts::QLineSeries *lumi, QtCharts::QLineSeries *cond);

    // Histograms (days)
    QVariantList getDataDays(const QString &dataName, int maxDays);
    QVariantList getBackgroundDays(float maxValue, int maxDays);
    QVariantList getLegendDays(int maxDays);

    // Histograms (hours)
    QVariantList getDataHours(const QString &dataName);
    QVariantList getBackgroundDaytime(float maxValue);
    QVariantList getBackgroundNighttime(float maxValue);
    QVariantList getLegendHours();
};

/* ************************************************************************** */
#endif // DEVICE_SENSORS_H

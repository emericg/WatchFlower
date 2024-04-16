/*!
 * Copyright (c) 2023 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "SunAndMoon.h"

/* ************************************************************************** */

SunAndMoon::SunAndMoon(QObject *parent) : QObject(parent)
{
    //
}

SunAndMoon::~SunAndMoon()
{
    //
}

/* ************************************************************************** */

void SunAndMoon::update()
{
    if (m_latitude_saved > -720.0 && m_longitude_saved > -720.0)
    {
        set(m_latitude_saved, m_longitude_saved, QDateTime::currentDateTimeUtc());
    }
    else
    {
        qWarning() << "SunAndMoon::update() ERROR latitude and longitude note set";
    }
}

void SunAndMoon::set(const double latitude, const double longitude, const QDateTime datetime)
{
    //QDateTime t1 = QDateTime::currentDateTime(); // benchmark

    // Results are cached for 10 minutes
    if (m_latitude_saved == latitude && m_longitude_saved == longitude &&
        m_lastupdate.isValid() && m_lastupdate.secsTo(datetime) < 600) return;

    m_latitude_saved = latitude;
    m_longitude_saved = longitude;
    m_lastupdate = datetime;
    time_t time = datetime.toSecsSinceEpoch();

    m_sr.calculate(latitude, longitude, time);
    m_mr.calculate(latitude, longitude, time);
    m_mp.calculate(time);

    int interval_s1 = (m_sr.setTime - m_sr.riseTime);
    if (interval_s1 < 0) interval_s1 += 24*3600;
    int interval_s2 = (QDateTime::currentDateTimeUtc().toSecsSinceEpoch() - m_sr.riseTime);
    if (interval_s2 < 0) interval_s2 += 24*3600;
    sun_percent = std::round((interval_s2 / static_cast<float>(interval_s1)) * 100.f);
    if (sun_percent < 0) sun_percent = 0;
    if (sun_percent > 100) sun_percent = 100;

    int interval_m1 = (m_mr.setTime - m_mr.riseTime);
    if (interval_m1 < 0) interval_m1 += 24*3600;
    int interval_m2 = (QDateTime::currentDateTimeUtc().toSecsSinceEpoch() - m_mr.riseTime);
    if (interval_m2 < 0) interval_s2 += 24*3600;
    moon_percent = std::round((interval_m2 / static_cast<float>(interval_m1)) * 100.f);
    if (moon_percent < 0) moon_percent = 0;
    if (moon_percent > 100) moon_percent = 100;

    Q_EMIT updated();

    //QDateTime t2 = QDateTime::currentDateTime(); // benchmark
    //int64_t load_ms = t2.toMSecsSinceEpoch() - t1.toMSecsSinceEpoch();
    //qDebug() << "SunAndMoon::update()" << load_ms << "ms";
}

void SunAndMoon::print()
{
    update();

    qDebug() << "SunAndMoon::print()";
    qDebug() << "- SunRise: " << QDateTime::fromSecsSinceEpoch(m_sr.riseTime, Qt::UTC, 0);
    qDebug() << "- SunSet: " << QDateTime::fromSecsSinceEpoch(m_sr.setTime, Qt::UTC, 0);
    qDebug() << "- MoonRise: " << QDateTime::fromSecsSinceEpoch(m_mr.riseTime, Qt::UTC, 0);
    qDebug() << "- MoonSet: " << QDateTime::fromSecsSinceEpoch(m_mr.setTime, Qt::UTC, 0);
}

/* ************************************************************************** */

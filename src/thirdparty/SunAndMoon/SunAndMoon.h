/*!
 * Copyright (c) 2007 Stephen R. Schmitt
 * Copyright (c) 2020 Cyrus Rahman
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

#ifndef SUN_AND_MOON_H
#define SUN_AND_MOON_H
/* ************************************************************************** */

#include <QObject>
#include <QList>
#include <QDate>
#include <QDateTime>

#include "SunRise/SunRise.h"
#include "MoonRise/MoonRise.h"
#include "MoonPhase/MoonPhase.h"

/* ************************************************************************** */

/*!
 * \brief The SunAndMoon class
 *
 * This is a Qt/QML wrapper for MoonPhase, MoonRise and SunRise from:
 * - https://github.com/signetica
 */
class SunAndMoon: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDateTime sunset READ getSunSet NOTIFY updated)
    Q_PROPERTY(QDateTime sunrise READ getSunRise NOTIFY updated)
    Q_PROPERTY(int sunpath READ getSunPath NOTIFY updated)

    Q_PROPERTY(QDateTime moonset READ getMoonSet NOTIFY updated)
    Q_PROPERTY(QDateTime moonrise READ getMoonRise NOTIFY updated)
    Q_PROPERTY(QString moonphaseName READ getMoonPhaseName NOTIFY updated)
    Q_PROPERTY(float moonphase READ getMoonPhase NOTIFY updated)
    Q_PROPERTY(int moonpath READ getMoonPath NOTIFY updated)
    Q_PROPERTY(int moonfraction READ getMoonFraction NOTIFY updated)

    double m_latitude_saved = -720.0;
    double m_longitude_saved = -720.0;
    QDateTime m_lastupdate;

    SunRise m_sr;
    MoonRise m_mr;
    MoonPhase m_mp;

    /// SunRise
    //bool sr.isVisible;            // If sun is visible at *time*.
    //bool sr.hasRise;              // There was a sunrise event found in the search interval (default 48 hours, 24 hours before and after *time*).
    //bool sr.hasSet;               // There was a sunset event found in the search interval.
    //float sr.riseAz;              // Where the sun will rise in degrees from north.
    //float sr.setAz;               // Where the sun will set in degrees from north.
    //time_t sr.queryTime;          // The *time* passed as the third argument.
    //time_t sr.riseTime;           // The sun rise event, in UTC seconds from the Unix epoch.
    //time_t sr.setTime;            // The sun set event.

    /// MoonRise
    //bool mr.isVisible;            // If moon is visible at *time*.
    //bool mr.hasRise;              // There was a moonrise event found in the search interval (default 48 hours, 24 hours before and after *time*).
    //bool mr.hasSet;               // There was a moonset event found in the search interval.
    //float mr.riseAz;              // Where the moon will rise in degrees from north.
    //float mr.setAz;               // Where the moon will set in degrees from north.
    //time_t mr.queryTime;          // The *time* passed as the third argument.
    //time_t mr.riseTime;           // The moon rise event, in UTC seconds from the Unix epoch.
    //time_t mr.setTime;            // The moon set event.

    /// MoonPhase
    //double mp.jDate;              // The fractional Julian date for *time*.
    //double mp.phase;              // The phase of the moon, from 0 (new) to 0.5 (full) to 1.0 (new).
    //double mp.age;                // Age in days of the current cycle.
    //double mp.fraction;           // The illumination fraction, from 0% - 100%.
    //double mp.distance;           // Moon distance in earth radii.
    //double mp.latitude;           // Moon ecliptic latitude in degrees.
    //double mp.longitude;          // Moon ecliptic longitude in degrees.
    //const char * mp.phaseName;    // The name of the moon phase: New, Full, etc.
    //const char * mp.zodiacName;   // The name of the Zodiac constellation the moon is in.

    int sun_percent = 0;
    int moon_percent = 0;

Q_SIGNALS:
    void updated();

public:
    SunAndMoon(QObject *parent = nullptr);
    virtual ~SunAndMoon();

    Q_INVOKABLE void set(const double latitude, const double longitude, const QDateTime datetime);
    Q_INVOKABLE void update();
    Q_INVOKABLE void print();

    QDateTime getSunSet() const { return QDateTime::fromSecsSinceEpoch(m_sr.setTime); }
    QDateTime getSunRise() const { return QDateTime::fromSecsSinceEpoch(m_sr.riseTime); }
    QDateTime getMoonSet() const { return QDateTime::fromSecsSinceEpoch(m_mr.setTime); }
    QDateTime getMoonRise() const { return QDateTime::fromSecsSinceEpoch(m_mr.riseTime); }
    QString getMoonPhaseName() const { return QString::fromLocal8Bit(m_mp.phaseName); }
    float getMoonPhase() const { return m_mp.phase; }
    int getMoonFraction() const { return m_mp.fraction*100.f; }

    int getSunPath() const { return sun_percent; }
    int getMoonPath() const { return moon_percent; }
};

/* ************************************************************************** */
#endif // SUN_AND_MOON_H

/*!
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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef UTILS_VERSIONCHECKER_H
#define UTILS_VERSIONCHECKER_H
/* ************************************************************************** */

#include <QString>
#include <QDebug>

struct Version
{
    int major = 0, minor = 0, revision = 0, build = 0;

    Version(const QString &version_qstr)
    {
        sscanf(version_qstr.toLatin1().constData(), "%d.%d.%d.%d",
               &major, &minor, &revision, &build);
    }

    bool operator == (const Version &other)
    {
        return (major == other.major
                && minor == other.minor
                && revision == other.revision
                && build == other.build);
    }
    bool operator < (const Version &other)
    {
/*
        qDebug() << "operator <";
        qDebug() << major << "." << minor << "." << revision << "." << build;
        qDebug() << other.major << "." << other.minor << "." << other.revision << "." << other.build;
*/
        if (major < other.major)
            return true;
        if (major > other.major)
            return false;
        if (minor < other.minor)
            return true;
        if (minor > other.minor)
            return false;
        if (revision < other.revision)
            return true;
        if (revision > other.revision)
            return false;
        if (build < other.build)
            return true;
        if (build > other.build)
            return false;

        return false;
    }
    bool operator <= (const Version &other)
    {
        if (*this < other || *this == other)
            return true;

        return false;
    }
    bool operator >= (const Version &other)
    {
        if (*this > other || *this == other)
            return true;

        return false;
    }
    bool operator > (const Version &other)
    {
        if (!(*this == other) && !(*this < other))
            return true;

        return false;
    }
};
/*
static void testVersionStringComparison()
{
    assert( (Version("3.7.8.0")  ==  Version("3.7.8.0") )   == true);
    assert( (Version("3.7.8.0")  ==  Version("3.7.8") )     == true);
    assert( (Version("3.7.8.0")  ==  Version("3.7.8") )     == true);
    assert( (Version("3.7.0.0")  ==  Version("3.7") )       == true);
    assert( (Version("3.0.0.0")  ==  Version("3") )         == true);
    assert( (Version("3")        ==  Version("3.0.0.0") )   == true);
    assert( (Version("3.7.8.0")  ==  Version("3.7") )       == false);
    assert( (Version("3.7.8.0")  ==  Version("3.6.8") )     == false);
    assert( (Version("3.7.8.0")  ==  Version("5") )         == false);
    assert( (Version("3.7.8.0")  ==  Version("2.7.8") )     == false);
    assert( (Version("01.02.03") ==  Version("01.02.03") )  == true);
    assert( (Version("01.02.03") ==  Version("02.02.03") )  == false);

    assert( (Version("3")         <  Version("3.7.9") )     == true);
    assert( (Version("1.7.9")     <  Version("3.1") )       == true);
    assert( (Version("3.7.8.0")   <  Version("3.7.8") )     == false);
    assert( (Version("3.7.9")     <  Version("3.7.8") )     == false);
    assert( (Version("3.7.8")     <  Version("3.7.9") )     == true);
    assert( (Version("3.7")       <  Version("3.7.0") )     == false);
    assert( (Version("3.7.8.0")   <  Version("3.7.8") )     == false);
    assert( (Version("2.7.9")     <  Version("3.8.8") )     == true);
    assert( (Version("3.7.9")     <  Version("3.8.8") )     == true);
    assert( (Version("4")         <  Version("3.7.9") )     == false);
    assert( (Version("01.02.03")  <  Version("01.02.03") )  == false);
    assert( (Version("01.02.03")  <  Version("02.02.03") )  == true);

    assert( (Version("4")         >  Version("3.7.9") )     == true);
    assert( (Version("3.7.9")     >  Version("3.7.8") )     == true);
    assert( (Version("4.7.9")     >  Version("3.1") )       == true);
    assert( (Version("3.10")      >  Version("3.8.8") )     == true);
    assert( (Version("3.7")       >  Version("3.7.0") )     == false);
    assert( (Version("3.7.8.0")   >  Version("3.7.8") )     == false);
    assert( (Version("2.7.9")     >  Version("3.8.8") )     == false);
    assert( (Version("3.7.9")     >  Version("3.8.8") )     == false);
    assert( (Version("02.02.03")  >  Version("01.02.03") )  == true);
    assert( (Version("01.02.03")  >  Version("02.02.03") )  == false);
}
*/
/* ************************************************************************** */
#endif // UTILS_VERSIONCHECKER_H

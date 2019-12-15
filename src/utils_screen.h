/*!
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2019
 */

#ifndef UTILS_SCREEN_H
#define UTILS_SCREEN_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QQuickWindow>

/* ************************************************************************** */

/*!
 * \brief The UtilsScreen class
 */
class UtilsScreen: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int screenDpi READ getScreenDpi NOTIFY screenChanged)
    Q_PROPERTY(double screenSize READ getScreenSize NOTIFY screenChanged)

    int m_screenDpi = -1;
    double m_screenSize = -1.0;

Q_SIGNALS:
    void screenChanged();

public:
    UtilsScreen() = default;
    ~UtilsScreen() = default;

    Q_INVOKABLE void getScreenInfos();

    Q_INVOKABLE double getScreenSize();

    Q_INVOKABLE int getScreenDpi();

    Q_INVOKABLE QVariantMap getSafeAreaMargins(QQuickWindow *window);
};

/* ************************************************************************** */
#endif // UTILS_SCREEN_H

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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef ANDROID_SERVICE_H
#define ANDROID_SERVICE_H
/* ************************************************************************** */

#include <QObject>
#include <QTimer>

class DeviceManager;

/* ************************************************************************** */

/*!
 * \brief The AndroidService class
 */
class AndroidService: public QObject
{
    Q_OBJECT

    QTimer m_workTimer;
    void setWorkTimer(int workInterval = 60);

    DeviceManager *m_deviceManager = nullptr;

private slots:
    void gotowork();

public:
    AndroidService(DeviceManager *devicemanager, QObject *parent = nullptr);
    ~AndroidService();

    static void service_start();
    static void service_stop();
    static void service_registerCommService();
};

/* ************************************************************************** */
#endif // ANDROID_SERVICE_H

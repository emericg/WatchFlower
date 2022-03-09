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

#include "AndroidService.h"

#if defined(Q_OS_ANDROID)

#include "DeviceManager.h"
#include "SettingsManager.h"
#include "NotificationManager.h"

#include <QtCore/private/qandroidextras_p.h>
#include <QCoreApplication>
#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

AndroidService::AndroidService(DeviceManager *devicemanager, QObject *parent) : QObject(parent)
{
    // Save the device manager
    m_deviceManager = devicemanager;

    // Configure update timer (only started on desktop)
    connect(&m_workTimer, &QTimer::timeout, this, &AndroidService::gotowork);
    setWorkTimer();
}

AndroidService::~AndroidService()
{
    //
}

/* ************************************************************************** */

void AndroidService::setWorkTimer(int workInterval)
{
    m_workTimer.setInterval(workInterval*60*1000);
    m_workTimer.start();
}

void AndroidService::gotowork()
{
    if (m_deviceManager && m_deviceManager->areDevicesAvailable())
    {
        //m_deviceManager->refreshDevices_listen();
        m_deviceManager->refreshDevices_check();
        //m_deviceManager->refreshDevices_start();
    }
}

/* ************************************************************************** */

void AndroidService::service_start()
{
    QJniObject::callStaticMethod<void>("com.emeric.watchflower.WatchFlowerAndroidService",
                                       "serviceStart",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::service_stop()
{
    QJniObject::callStaticMethod<void>("com.emeric.watchflower.WatchFlowerAndroidService",
                                       "serviceStop", "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::service_registerCommService()
{
    QJniEnvironment env;
    jclass javaClass = env.findClass("com/emeric/watchflower/ActivityUtils");
    QJniObject classObject(javaClass);

    classObject.callMethod<void>("registerServiceBroadcastReceiver",
                                 "(Landroid/content/Context;)V",
                                 QNativeInterface::QAndroidApplication::context());
}

/* ************************************************************************** */
#endif // Q_OS_ANDROID

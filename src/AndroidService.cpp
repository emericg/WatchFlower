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

#include "DatabaseManager.h"
#include "SettingsManager.h"
#include "DeviceManager.h"

#include "NotificationManager.h"
#include "utils_log.h"

#include <QtCore/private/qandroidextras_p.h>
#include <QCoreApplication>
#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

AndroidService::AndroidService(QObject *parent) : QObject(parent)
{
    DatabaseManager::getInstance();

    m_settingsManager = SettingsManager::getInstance();

    //m_notificationManager = NotificationManager::getInstance(); // DEBUG
    //m_notificationManager->setNotification("AndroidService starting", QDateTime::currentDateTime().toString());

    // Configure update timer
    connect(&m_workTimer, &QTimer::timeout, this, &AndroidService::gotowork);
    setWorkTimer(5);
}

AndroidService::~AndroidService()
{
    //
}

/* ************************************************************************** */

void AndroidService::setWorkTimer(int workInterval_mins)
{
    m_workTimer.setInterval(workInterval_mins*60*1000);
    m_workTimer.start();
}

void AndroidService::gotowork()
{
    //m_notificationManager = NotificationManager::getInstance(); // DEBUG
    //m_notificationManager->setNotification("AndroidService gotowork", QDateTime::currentDateTime().toString());

    // Reload settings, user might have changed them
    m_settingsManager->reloadSettings();

    // Is the background service enabled?
    if (m_settingsManager->getSysTray())
    {
        // Check when was the last run, to be sure we need an update
        if (DeviceManager::getLastRun() > 60)
        {
            // Reload the device manager, a new scan might have occured
            if (m_deviceManager) delete m_deviceManager;
            m_deviceManager = new DeviceManager(true);

            // Device manager is operational?
            if (m_deviceManager &&
                m_deviceManager->checkBluetooth() &&
                m_deviceManager->areDevicesAvailable())
            {
                // Start background refresh process
                m_deviceManager->refreshDevices_background();
            }
        }
    }

    // Restart timer
    setWorkTimer(5);
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

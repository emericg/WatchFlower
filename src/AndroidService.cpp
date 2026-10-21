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
#include <QMetaObject>
#include <QDateTime>
#include <QTimer>
#include <QDebug>

#include <jni.h>

/* ************************************************************************** */

AndroidService *AndroidService::instance = nullptr;
QMutex AndroidService::instanceMutex;

AndroidService::AndroidService(QObject *parent) : QObject(parent)
{
    {
        QMutexLocker locker(&instanceMutex);
        instance = this;
    }

    DatabaseManager::getInstance();
    m_settingsManager = SettingsManager::getInstance();
    m_notificationManager = NotificationManager::getInstance();

    //m_notificationManager->setNotification("AndroidService starting", QDateTime::currentDateTime().toString()); // DEBUG
    //UtilsLog::getInstance()->pushLog("(daemon) service started", UtilsLog::Info); // DEBUG

    // Listen for app messages, then ask for the app state and announce our presence
    registerServiceReceiver();
    checkAppState();
    sendServiceAlive();
    //UtilsLog::getInstance()->pushLog("(daemon) announced alive to app", UtilsLog::Info);

    // Configure watchdog timer
    m_watchdogTimer.setSingleShot(true);
    m_watchdogTimer.setInterval(s_work_watchdog*60*1000);
    connect(&m_watchdogTimer, &QTimer::timeout, this, &AndroidService::onWatchdogTimeout);

    // Configure update timer
    connect(&m_workTimer, &QTimer::timeout, this, &AndroidService::gotowork);
    setWorkTimer(s_work_timer);

    //UtilsLog::getInstance()->pushLog("(daemon) setWorkTimer(set)", UtilsLog::Info);
}

AndroidService::~AndroidService()
{
    //UtilsLog::getInstance()->pushLog("(daemon) service stopped", UtilsLog::Info);

    unregisterServiceReceiver();

    // Calls already queued by invokeOnInstance() are discarded by ~QObject()
    QMutexLocker locker(&instanceMutex);
    if (instance == this) instance = nullptr;
}

void AndroidService::invokeOnInstance(const std::function<void (AndroidService *)> &fn)
{
    QMutexLocker locker(&instanceMutex);

    AndroidService *as = instance;
    if (as)
    {
        QMetaObject::invokeMethod(as, [as, fn]() { fn(as); }, Qt::QueuedConnection);
    }
}

/* ************************************************************************** */

void AndroidService::setWorkTimer(int workInterval_mins)
{
    m_workTimer.setInterval(workInterval_mins*60*1000);
    m_workTimer.start();
}

bool AndroidService::isAppForegroundFresh() const
{
    return (m_appForeground && m_appForegroundAt.isValid() &&
            m_appForegroundAt.secsTo(QDateTime::currentDateTime()) < s_appForeground_staleness);
}

void AndroidService::gotowork()
{
    //m_notificationManager->setNotification("AndroidService gotowork", QDateTime::currentDateTime().toString());
    //UtilsLog::getInstance()->pushLog("(daemon) gotowork: waking up", UtilsLog::Info);

    // Reload settings, user might have changed them
    m_settingsManager->reloadSettings();

    // The app is in foreground, it handles BLE itself
    if (isAppForegroundFresh())
    {
        //UtilsLog::getInstance()->pushLog("(daemon) gotowork: app is in foreground, standing down", UtilsLog::Info);
        return;
    }
    if (m_appForeground)
    {
        //UtilsLog::getInstance()->pushLog("(daemon) gotowork: app foreground flag is stale (no heartbeat), assuming app is gone", UtilsLog::Warning);
        m_appForeground = false;
        m_appForegroundAt = QDateTime();
    }

    // Is the background service enabled?
    if (!m_settingsManager->getSysTray())
    {
        //UtilsLog::getInstance()->pushLog("(daemon) gotowork: background disabled (systray off)", UtilsLog::Warning);
        return;
    }

    // Was the last run too recent? (-1 means no valid last run)
    const int lastRunMin = DeviceManager::getLastRun_min();
    if (lastRunMin >= 0 && lastRunMin <= s_work_guard)
    {
        //UtilsLog::getInstance()->pushLog("(daemon) gotowork: last run " + QString::number(lastRunMin) +
        //                                 " min ago, too soon, skipping", UtilsLog::Info);
        return;
    }

    // Is the previous cycle still running?
    if (m_deviceManager)
    {
        //UtilsLog::getInstance()->pushLog("(daemon) gotowork: previous refresh still running, skipping this cycle", UtilsLog::Warning);
        return;
    }

    m_deviceManager = new DeviceManager(true);

    // Device manager is operational?
    if (m_deviceManager)
    {
        connect(m_deviceManager, &DeviceManager::backgroundScanningFinished,
                this, &AndroidService::onBackgroundScanningFinished);

        // Start background refresh process
        //UtilsLog::getInstance()->pushLog("(daemon) start scanning", UtilsLog::Info);
        m_watchdogTimer.start();
        m_deviceManager->refreshDevices_background();
    }
    else
    {
        //UtilsLog::getInstance()->pushLog("(daemon) gotowork: failed to create DeviceManager", UtilsLog::Error);
    }
}

void AndroidService::onWatchdogTimeout()
{
    if (m_deviceManager)
    {
        //UtilsLog::getInstance()->pushLog("(daemon) watchdog: refresh cycle timed out, stopping it", UtilsLog::Warning);
        m_deviceManager->refreshDevices_stop();
    }
}

void AndroidService::setAppForeground(bool foreground)
{
    m_appForeground = foreground;

    if (foreground)
    {
        m_appForegroundAt = QDateTime::currentDateTime();

        if (m_deviceManager)
        {
            //UtilsLog::getInstance()->pushLog("(daemon) app moved to foreground, stopping in-progress background refresh", UtilsLog::Info);
            m_deviceManager->refreshDevices_stop();
        }
    }
}

void AndroidService::onBackgroundScanningFinished(bool dataUpdated)
{
    //UtilsLog::getInstance()->pushLog("(daemon) stop scanning", UtilsLog::Info);
    m_watchdogTimer.stop();

    if (dataUpdated) sendDataUpdated();

    if (m_deviceManager)
    {
        m_deviceManager->disconnect(this);
        m_deviceManager->deleteLater();
        m_deviceManager = nullptr;
    }
}

/* ************************************************************************** */

void AndroidService::onServicePinged()
{
    //UtilsLog::getInstance()->pushLog("(daemon) received ping from app, replying alive", UtilsLog::Info);
    sendServiceAlive();
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

void AndroidService::setServiceEnabled(bool enabled)
{
    QJniObject::callStaticMethod<void>("com.emeric.watchflower.WatchFlowerAndroidService",
                                       "setServiceEnabled",
                                       "(Landroid/content/Context;Z)V",
                                       QNativeInterface::QAndroidApplication::context(),
                                       static_cast<jboolean>(enabled));
}

void AndroidService::registerServiceReceiver()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "registerServiceBroadcastReceiver",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());

    //UtilsLog::getInstance()->pushLog("(daemon) service broadcast receiver registered", UtilsLog::Info);
}

void AndroidService::registerActivityReceiver()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "registerActivityBroadcastReceiver",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::unregisterServiceReceiver()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "unregisterServiceBroadcastReceiver",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::unregisterActivityReceiver()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "unregisterActivityBroadcastReceiver",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::sendAppState(bool foreground)
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "sendAppState",
                                       "(Landroid/content/Context;Z)V",
                                       QNativeInterface::QAndroidApplication::context(),
                                       static_cast<jboolean>(foreground));
}

void AndroidService::sendDataUpdated()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "sendDataUpdated",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::checkAppState()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "pingApp",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::checkServiceState()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "checkServiceState",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

void AndroidService::sendServiceAlive()
{
    QJniObject::callStaticMethod<void>("com/emeric/watchflower/ActivityUtils",
                                       "sendServiceAlive",
                                       "(Landroid/content/Context;)V",
                                       QNativeInterface::QAndroidApplication::context());
}

/* ************************************************************************** */

// JNI bridge (service process), called from the ActivityUtils BroadcastReceivers.
// These run on the Android main thread, not on the Qt thread: marshal with a queued invocation.

extern "C" JNIEXPORT void JNICALL
Java_com_emeric_watchflower_ActivityUtils_nativeAppStateReceived(JNIEnv *, jclass, jboolean foreground)
{
    const bool fg = static_cast<bool>(foreground);
    AndroidService::invokeOnInstance([fg](AndroidService *as) { as->setAppForeground(fg); });
}

extern "C" JNIEXPORT void JNICALL
Java_com_emeric_watchflower_ActivityUtils_nativeServicePinged(JNIEnv *, jclass)
{
    AndroidService::invokeOnInstance([](AndroidService *as) { as->onServicePinged(); });
}

/* ************************************************************************** */
#endif // Q_OS_ANDROID

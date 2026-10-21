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

#include "AndroidServiceLink.h"
#include "DeviceManager.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QJSEngine>

#if defined(Q_OS_ANDROID)
#include "AndroidService.h"
#include "SettingsManager.h"
#include "utils_log.h"
#include <QString>
#include <QMetaObject>
#include <jni.h>
#endif

/* ************************************************************************** */

#if defined(Q_OS_ANDROID)
AndroidServiceLink *AndroidServiceLink::instance = nullptr;
QMutex AndroidServiceLink::instanceMutex;
#endif

AndroidServiceLink *AndroidServiceLink::getInstance()
{
    static AndroidServiceLink *singleton = new AndroidServiceLink(QCoreApplication::instance());
    return singleton;
}

AndroidServiceLink *AndroidServiceLink::create(QQmlEngine *, QJSEngine *)
{
    AndroidServiceLink *singleton = getInstance();
    QJSEngine::setObjectOwnership(singleton, QJSEngine::CppOwnership);
    return singleton;
}

AndroidServiceLink::AndroidServiceLink(QObject *parent) : QObject(parent)
{
#if defined(Q_OS_ANDROID)
    {
        QMutexLocker locker(&instanceMutex);
        instance = this;
    }

    m_pingTimer.setSingleShot(true);
    m_pingTimer.setInterval(s_ping_timeout);
    connect(&m_pingTimer, &QTimer::timeout, this, [this]() { setServiceOnline(false); });

    SettingsManager *sm = SettingsManager::getInstance();
    if (sm)
    {
        AndroidService::setServiceEnabled(sm->getSysTray());
        connect(sm, &SettingsManager::systrayChanged, this, &AndroidServiceLink::onServiceEnabledChanged);
    }

    DeviceManager *dm = DeviceManager::getInstance();
    if (dm)
    {
        connect(dm, &DeviceManager::permissionsChanged, this, &AndroidServiceLink::onPermissionsChanged);
    }
#endif
}

AndroidServiceLink::~AndroidServiceLink()
{
#if defined(Q_OS_ANDROID)
    AndroidService::unregisterActivityReceiver();

    // Calls already queued by invokeOnInstance() are discarded by ~QObject()
    QMutexLocker locker(&instanceMutex);
    if (instance == this) instance = nullptr;
#endif
}

#if defined(Q_OS_ANDROID)
void AndroidServiceLink::invokeOnInstance(const std::function<void (AndroidServiceLink *)> &fn)
{
    QMutexLocker locker(&instanceMutex);

    AndroidServiceLink *com = instance;
    if (com)
    {
        QMetaObject::invokeMethod(com, [com, fn]() { fn(com); }, Qt::QueuedConnection);
    }
}
#endif

/* ************************************************************************** */

#if defined(Q_OS_ANDROID)
void AndroidServiceLink::onServiceEnabledChanged()
{
    SettingsManager *sm = SettingsManager::getInstance();
    if (!sm) return;

    const bool enabled = sm->getSysTray();

    AndroidService::setServiceEnabled(enabled);

    if (enabled)
    {
        // The service announces itself once started
        AndroidService::service_start();
    }
    else
    {
        AndroidService::service_stop();
        m_pingTimer.stop();
        setServiceOnline(false);
    }
}

void AndroidServiceLink::onPermissionsChanged()
{
    SettingsManager *sm = SettingsManager::getInstance();
    if (!sm || !sm->getSysTray()) return;
    DeviceManager *dm = DeviceManager::getInstance();
    if (!dm || !dm->hasPermissionBluetooth()) return;
    if (m_serviceOnline) return;

    // The service announces itself once started
    AndroidService::service_start();
}
#endif

/* ************************************************************************** */

void AndroidServiceLink::setBackgroundServiceAppState(bool foreground)
{
#if defined(Q_OS_ANDROID)
    m_appForegroundCached = foreground;
    AndroidService::sendAppState(foreground);
#else
    Q_UNUSED(foreground)
#endif
}

void AndroidServiceLink::checkServiceState()
{
#if defined(Q_OS_ANDROID)
    //UtilsLog::getInstance()->pushLog("(app) pinging service", UtilsLog::Info);

    m_pingTimer.start();
    AndroidService::checkServiceState();
#endif
}

void AndroidServiceLink::replyAppState()
{
#if defined(Q_OS_ANDROID)
    AndroidService::sendAppState(m_appForegroundCached);
#endif
}

void AndroidServiceLink::onDataUpdated()
{
    DeviceManager *dm = DeviceManager::getInstance();
    if (dm) dm->reloadDatabaseData();
}

void AndroidServiceLink::setServiceOnline(bool online)
{
#if defined(Q_OS_ANDROID)
    //UtilsLog::getInstance()->pushLog(QString("(app) service reported ") + (online ? "online" : "offline"), UtilsLog::Info);
    if (online) m_pingTimer.stop();
#endif

    if (m_serviceOnline != online)
    {
        m_serviceOnline = online;
        Q_EMIT serviceOnlineChanged();
    }
}

/* ************************************************************************** */

#if defined(Q_OS_ANDROID)

// JNI bridge (app process), called from the ActivityUtils BroadcastReceivers.
// These run on the Android main thread, not on the Qt thread: marshal with a queued invocation.

extern "C" JNIEXPORT void JNICALL
Java_com_emeric_watchflower_ActivityUtils_nativeDataUpdatedReceived(JNIEnv *, jclass)
{
    AndroidServiceLink::invokeOnInstance([](AndroidServiceLink *com) { com->onDataUpdated(); });
}

extern "C" JNIEXPORT void JNICALL
Java_com_emeric_watchflower_ActivityUtils_nativeAppPinged(JNIEnv *, jclass)
{
    AndroidServiceLink::invokeOnInstance([](AndroidServiceLink *com) { com->replyAppState(); });
}

extern "C" JNIEXPORT void JNICALL
Java_com_emeric_watchflower_ActivityUtils_nativeServiceStateReceived(JNIEnv *, jclass)
{
    AndroidServiceLink::invokeOnInstance([](AndroidServiceLink *com) { com->setServiceOnline(true); });
}

#endif // Q_OS_ANDROID

/* ************************************************************************** */

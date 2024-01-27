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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "NotificationManager.h"
#include "SystrayManager.h"

#if defined(Q_OS_ANDROID)
#include "utils_os_android.h"
#include <QJniObject>
#include <QCoreApplication>
#elif defined(Q_OS_IOS)
#include "utils_os_ios.h"
#endif

/* ************************************************************************** */

NotificationManager *NotificationManager::instance = nullptr;

NotificationManager *NotificationManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new NotificationManager();
    }

    return instance;
}

NotificationManager::NotificationManager()
{
    //checkNotificationPermissions();

#if defined(Q_OS_ANDROID)
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateNotificationAndroid()));
#elif defined(Q_OS_IOS)
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateNotificationIOS()));
#else
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateNotificationDesktop()));
#endif
}

NotificationManager::~NotificationManager()
{
    //
}

/* ************************************************************************** */

void NotificationManager::setNotification(const QString &title, const QString &message, int channel)
{
    //if (m_title == title && m_notification == notification) return;

    m_title = title;
    m_message = message;
    m_channel = channel;

    Q_EMIT notificationChanged();
}

void NotificationManager::setNotificationShort(const QString &message)
{
    //if (m_notification == notification) return;

    m_message = message;
    m_title = "";
    m_channel = 0;

    Q_EMIT notificationChanged();
}

/* ************************************************************************** */

void NotificationManager::updateNotificationDesktop()
{
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    SystrayManager *st = SystrayManager::getInstance();
    if (st)
    {
        st->sendNotification(m_message);
    }
#endif
}

void NotificationManager::updateNotificationIOS()
{
#if defined(Q_OS_IOS)
    //m_iosnotifier.notify(m_title, m_message, m_channel);
#endif
}

void NotificationManager::updateNotificationAndroid()
{
#if defined(Q_OS_ANDROID)
    QJniObject javaTitle = QJniObject::fromString(m_title);
    QJniObject javaMessage = QJniObject::fromString(m_message);
    jint javaChannel = m_channel;

    QJniObject::callStaticMethod<void>(
                    "com/emeric/watchflower/WatchFlowerAndroidNotifier",
                    "notify",
                    "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;I)V",
                    QNativeInterface::QAndroidApplication::context(),
                    javaTitle.object<jstring>(),
                    javaMessage.object<jstring>(),
                    javaChannel);
#endif
}

/* ************************************************************************** */

bool NotificationManager::checkNotificationPermissions()
{
    //qDebug() << "NotificationManager::checkNotificationPermissions()";
    bool permOS_was = m_permOS;

#if defined(Q_OS_ANDROID)
    m_permOS = UtilsAndroid::checkPermission_notification();
#elif defined(Q_OS_IOS)
    //m_permOS = UtilsIOS::checkPermission_notification();
#endif

    if (permOS_was != m_permOS)
    {
        Q_EMIT permissionsChanged();
    }

    return m_permOS;
}

bool NotificationManager::requestNotificationPermissions()
{
    //qDebug() << "NotificationManager::requestNotificationPermissions()";
    bool permOS_was = m_permOS;

#if defined(Q_OS_ANDROID)
    m_permOS = UtilsAndroid::getPermission_notification();
#elif defined(Q_OS_IOS)
    //m_permOS = UtilsIOS::getPermission_notification();
#endif

    if (permOS_was != m_permOS)
    {
        Q_EMIT permissionsChanged();
    }

    return m_permOS;
}

/* ************************************************************************** */

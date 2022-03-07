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

#include <QDebug>
#include <QString>

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
#if defined(Q_OS_ANDROID)
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateAndroidNotification()));
#elif defined(Q_OS_IOS)
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateIosNotification()));
#else
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateDesktopNotification()));
#endif
}

NotificationManager::~NotificationManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void NotificationManager::setNotification(const QString &notification)
{
    //if (m_notification == notification)
    //    return;

    m_notification = notification;
    Q_EMIT notificationChanged();
}

QString NotificationManager::notification() const
{
    return m_notification;
}

/* ************************************************************************** */
/* ************************************************************************** */

void NotificationManager::updateDesktopNotification()
{
    SystrayManager *st = SystrayManager::getInstance();
    if (st)
    {
        st->sendNotification(m_notification);
    }
}

void NotificationManager::updateIosNotification()
{
#if defined(Q_OS_IOS)
    //
#endif
}

void NotificationManager::updateAndroidNotification()
{
#if defined(Q_OS_ANDROID)
    //
#endif
}

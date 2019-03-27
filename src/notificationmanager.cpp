/*!
 * This file is part of WatchFlower.
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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "notificationmanager.h"

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QAndroidJniObject>
#endif

/* ************************************************************************** */

NotificationManager::NotificationManager(QObject *parent)
    : QObject(parent)
{
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateAndroidNotification()));
}

/* ************************************************************************** */

void NotificationManager::setNotification(const QString &notification)
{
    if (m_notification == notification)
        return;

    m_notification = notification;
    emit notificationChanged();
}

QString NotificationManager::notification() const
{
    return m_notification;
}

void NotificationManager::updateAndroidNotification()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject javaNotification = QAndroidJniObject::fromString(m_notification);
    QAndroidJniObject::callStaticMethod<void>("org/qtproject/example/notification/NotificationClient",
                                       "notify",
                                       "(Ljava/lang/String;)V",
                                       javaNotification.object<jstring>());
#endif // Q_OS_ANDROID
}

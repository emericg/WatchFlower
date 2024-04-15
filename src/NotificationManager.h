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

#ifndef NOTIFICATION_MANAGER_H
#define NOTIFICATION_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QString>

#if defined(Q_OS_IOS)
#include "utils_os_ios_notif.h"
#endif

/* ************************************************************************** */

/*!
 * \brief The NotificationManager class
 */
class NotificationManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString notification READ getNotification WRITE setNotificationShort NOTIFY notificationChanged)
    Q_PROPERTY(bool permissionOS READ hasPermissionOS NOTIFY permissionsChanged)

    QString m_title;
    QString m_message;
    int m_channel = 0;

    bool m_permOS = false;
    bool hasPermissionOS() const { return m_permOS; }

#if defined(Q_OS_IOS)
    UtilsIOSNotifications m_iosnotifier;
#endif

    // Singleton
    static NotificationManager *instance;
    NotificationManager();
    ~NotificationManager();

private slots:
    void updateNotificationAndroid();
    void updateNotificationIOS();
    void updateNotificationDesktop();

Q_SIGNALS:
    void notificationChanged();
    void permissionsChanged();

public:
    static NotificationManager *getInstance();

    Q_INVOKABLE bool checkNotificationPermissions();
    Q_INVOKABLE bool requestNotificationPermissions();

    QString getNotification() const { return m_message; }
    void setNotification(const QString &title, const QString &message, int channel = 0);
    void setNotificationShort(const QString &message);
};

/* ************************************************************************** */
#endif // NOTIFICATION_MANAGER_H

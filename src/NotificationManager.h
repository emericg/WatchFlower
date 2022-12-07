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

/* ************************************************************************** */

/*!
 * \brief The NotificationManager class
 */
class NotificationManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString notification READ getNotificationShort WRITE setNotificationShort NOTIFY notificationChanged)

    static NotificationManager *instance;

    NotificationManager();
    ~NotificationManager();

public:
    static NotificationManager *getInstance();

    void setNotification(const QString &title, const QString &message, int channel = 0);

    void setNotificationShort(const QString &message);
    QString getNotificationShort() const { return m_message; }

signals:
    void notificationChanged();

private slots:
    void updateNotificationAndroid();
    void updateNotificationIos();
    void updateNotificationDesktop();

private:
    QString m_title;
    QString m_message;
    int m_channel = 0;
};

/* ************************************************************************** */
#endif // NOTIFICATION_MANAGER_H

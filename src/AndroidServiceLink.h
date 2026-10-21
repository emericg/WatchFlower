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

#ifndef ANDROID_SERVICE_LINK_H
#define ANDROID_SERVICE_LINK_H
/* ************************************************************************** */

#include <QtGlobal>
#include <QObject>
#include <QTimer>
#include <QMutex>

#include <functional>

class DeviceManager;

/* ************************************************************************** */

/*!
 * \brief The AndroidServiceLink class
 *
 * App process side of the app <> background service communication,
 * counterpart of AndroidService (service process).
 *
 * Compiled on every platform so QML can bind to it unconditionally,
 * the Android specific parts are gated out.
 */
class AndroidServiceLink: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool serviceOnline READ isServiceOnline NOTIFY serviceOnlineChanged)

#if defined(Q_OS_ANDROID)
    static AndroidServiceLink *instance; //!< Self pointer, routes the JNI callbacks (app process)
    static QMutex instanceMutex;         //!< Guards instance, also read from the Android main thread
    bool m_appForegroundCached = false; //!< Last app state we reported (re-sent when the service pings us)

    static const int s_ping_timeout = 2000; //!< Delay before a ping without answer means the service is offline (in ms)
    QTimer m_pingTimer;
#endif

    DeviceManager *m_deviceManager = nullptr; //!< Back-ref, to reload device data after the service writes new data
    bool m_serviceOnline = false;             //!< True once the background service has answered our ping

Q_SIGNALS:
    void serviceOnlineChanged();

#if defined(Q_OS_ANDROID)
private slots:
    /*!
     * \brief The background service setting changed: persist it, then start or stop the service.
     */
    void onServiceEnabledChanged();

    /*!
     * \brief The app permissions changed: start the service if it was waiting for the Bluetooth permission.
     *
     * Covers a permission granted from the app, or from the system settings (checked when the app resumes).
     */
    void onPermissionsChanged();
#endif

public:
    explicit AndroidServiceLink(DeviceManager *deviceManager, QObject *parent = nullptr);
    ~AndroidServiceLink();

#if defined(Q_OS_ANDROID)
    /*!
     * \brief Queue a call on the live instance, to run in its own thread.
     * \param fn: function to run, receives the instance.
     *
     * Thread safe, used by the JNI callbacks (Android main thread).
     * Does nothing if there is no instance, or once it is being destroyed.
     */
    static void invokeOnInstance(const std::function<void (AndroidServiceLink *)> &fn);
#endif

    //! True once the background service has answered our presence check
    bool isServiceOnline() const { return m_serviceOnline; }

    //! Tell the background service whether the app is in foreground (so it can stand down)
    Q_INVOKABLE void setBackgroundServiceAppState(bool foreground);

    /*!
     * \brief Ask the background service whether it is online.
     *
     * The service answers asynchronously with setServiceOnline(true).
     * Without an answer after s_ping_timeout ms, the service is considered offline.
     */
    Q_INVOKABLE void checkServiceState();

    //! Re-send our last known app state (answer to a service ping)
    void replyAppState();

    //! The service wrote new data: reload the device manager's cached data
    void onDataUpdated();

    //! Record that the background service is online (answer to our ping)
    void setServiceOnline(bool online);
};

/* ************************************************************************** */
#endif // ANDROID_SERVICE_LINK_H

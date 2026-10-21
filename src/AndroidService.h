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

#ifndef ANDROID_SERVICE_H
#define ANDROID_SERVICE_H
/* ************************************************************************** */

#include <QtGlobal>
#include <QObject>
#include <QTimer>
#include <QDateTime>
#include <QMutex>

#include <functional>

#if defined(Q_OS_ANDROID)

class DeviceManager;
class SettingsManager;
class NotificationManager;

/* ************************************************************************** */

/*!
 * \brief The AndroidService class
 *
 * Service process side of the app <> background service communication.
 * Runs a background refresh cycle every s_work_timer minutes, unless the app is in foreground.
 */
class AndroidService: public QObject
{
    Q_OBJECT

    static AndroidService *instance; //!< Self pointer, routes the JNI callbacks (service process)
    static QMutex instanceMutex;     //!< Guards instance, also read from the Android main thread

    static const int s_work_timer = 15;     //!< Interval between two refresh cycles (in minutes)
    static const int s_work_guard = 5;      //!< Minimum time since the last run (in minutes)
    static const int s_work_watchdog = 5;   //!< Maximum duration of a refresh cycle (in minutes)

    static const int s_appForeground_staleness = 90; //!< Validity of the app foreground heartbeat (in seconds)

    QTimer m_workTimer;
    void setWorkTimer(int workInterval_mins = s_work_timer);

    QTimer m_watchdogTimer;

    DeviceManager *m_deviceManager = nullptr;
    SettingsManager *m_settingsManager = nullptr;
    NotificationManager *m_notificationManager = nullptr;

    bool m_appForeground = false; //!< Is the app in foreground? (the service stands down)
    QDateTime m_appForegroundAt;  //!< Last time the app confirmed it was in foreground (heartbeat)

    /*!
     * \brief Is the app in foreground, with a recent heartbeat?
     * \return true if the app reported being in foreground less than s_appForeground_staleness seconds ago.
     *
     * A stale flag means the app was backgrounded or killed without telling us.
     */
    bool isAppForegroundFresh() const;

private slots:
    /*!
     * \brief Start a background refresh cycle.
     *
     * Skipped if the app is in foreground, if the background service is disabled,
     * if the last run is less than s_work_guard minutes old,
     * or if the previous cycle is still running (its DeviceManager is never deleted while busy).
     */
    void gotowork();

    /*!
     * \brief Abort a refresh cycle that is still running after s_work_watchdog minutes.
     */
    void onWatchdogTimeout();

    /*!
     * \brief Notify the app if new data is available, then release the background DeviceManager.
     * \param dataUpdated: true if at least one device wrote new data to the database.
     *
     * Called once discovery and device updates are both idle.
     * The DeviceManager is released with deleteLater(), so pending queued events are flushed first.
     */
    void onBackgroundScanningFinished(bool dataUpdated);

public:
    /*!
     * \brief The app asked if we are online, reply that we are.
     */
    void onServicePinged();

    /*!
     * \brief The app went to foreground or background.
     * \param foreground: true if the app is now in foreground.
     *
     * When the app goes to foreground, a running refresh cycle is stopped right away,
     * so that the two processes never use BLE and write the database at the same time.
     */
    void setAppForeground(bool foreground);

    AndroidService(QObject *parent = nullptr);
    ~AndroidService();

    /*!
     * \brief Queue a call on the live instance, to run in its own thread.
     * \param fn: function to run, receives the instance.
     *
     * Thread safe, used by the JNI callbacks (Android main thread).
     * Does nothing if there is no instance, or once it is being destroyed.
     */
    static void invokeOnInstance(const std::function<void (AndroidService *)> &fn);

    static void service_start();
    static void service_stop();

    /*!
     * \brief Persist the background service enable toggle (Java SharedPreferences).
     * \param enabled: true if the background service is enabled.
     *
     * Used by serviceStart() and the boot receiver, which cannot read the Qt settings.
     */
    static void setServiceEnabled(bool enabled);

    // App <> service communication bridge
    static void registerServiceReceiver();      //!< (Service) process listen for (app) messages
    static void registerActivityReceiver();     //!< (App) process listen for (service) messages
    static void unregisterServiceReceiver();    //!< (Service) process stop listening for (app) messages
    static void unregisterActivityReceiver();   //!< (App) process stop listening for (service) messages

    static void sendAppState(bool foreground);  //!< (App) process tell the (service) the app is fg/bg
    static void checkAppState();                //!< (Service) process ask the (app) if it is online
    static void sendDataUpdated();              //!< (Service) process tell the (app) new data is available

    // Presence check (ping/pong)
    static void checkServiceState();            //!< (App) process ask the (service) if it is online
    static void sendServiceAlive();             //!< (Service) process reply that we are online
};

/* ************************************************************************** */
#endif // Q_OS_ANDROID
#endif // ANDROID_SERVICE_H

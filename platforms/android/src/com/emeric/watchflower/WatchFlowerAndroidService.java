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

package com.emeric.watchflower;

import java.lang.String;
import android.util.Log;
import android.content.Context;
import android.content.Intent;
import android.content.BroadcastReceiver;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.PendingIntent;
import android.os.Build;

import org.qtproject.qt.android.bindings.QtService;

public class WatchFlowerAndroidService extends QtService {

    private static final String TAG = "WatchFlowerAndroidService";

    private static final String CHANNEL_ID = "watchflower_service";
    private static final String CHANNEL_NAME = "Background service";
    private static final int NOTIFICATION_ID = 1;

    // Persisted background service toggle, written by the app (AndroidServiceLink)
    private static final String PREFS_NAME = "WatchFlower";
    private static final String KEY_SERVICE_ENABLED = "service_enabled";

    @Override
    public void onCreate() {
        super.onCreate();
        //Log.i(TAG, ">>>> Creating Service >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

        // Without the foreground state, the system would kill us shortly
        if (!startForegroundCompat()) {
            stopSelf();
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    private Notification buildForegroundNotification() {
        NotificationManager notificationManager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);

        Notification.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_LOW);
            channel.setShowBadge(false);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            notificationManager.createNotificationChannel(channel);
            builder = new Notification.Builder(this, CHANNEL_ID);
        } else {
            builder = new Notification.Builder(this);
        }

        Intent resultIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (resultIntent != null) {
            resultIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            PendingIntent resultPendingIntent = PendingIntent.getActivity(this, 0, resultIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            builder.setContentIntent(resultPendingIntent);
        }

        builder.setSmallIcon(R.drawable.ic_stat_logo);
        builder.setContentTitle("WatchFlower");
        builder.setContentText("Monitoring sensors in the background");
        builder.setOngoing(true);
        builder.setShowWhen(false);
        builder.setOnlyAlertOnce(true);

        return builder.build();
    }

    /*!
     * \brief Promote the service to a foreground service (connectedDevice type).
     * \return true on success.
     *
     * Can fail on API 31+ when started from the background,
     * or on API 34+ without the BLUETOOTH_CONNECT permission.
     */
    private boolean startForegroundCompat() {
        try {
            Notification notification = buildForegroundNotification();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE);
            } else {
                startForeground(NOTIFICATION_ID, notification);
            }
            return true;
        } catch (Exception e) {
            Log.e(TAG, "startForeground() failed, stopping the service", e);
        }
        return false;
    }

    public void onResume() {
        //Log.i(TAG, ">>>> Resuming Service >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }

    public void onPause() {
        //Log.i(TAG, ">>>> Pausing Service >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        //Log.i(TAG, ">>>> Destroying Service >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int ret = super.onStartCommand(intent, flags, startId);

        return START_STICKY;
    }

    ////////////////////////////////////////////////////////////////////////////

    public static void setServiceEnabled(Context context, boolean enabled) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
               .edit().putBoolean(KEY_SERVICE_ENABLED, enabled).apply();
    }

    public static boolean isServiceEnabled(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                      .getBoolean(KEY_SERVICE_ENABLED, false);
    }

    ////////////////////////////////////////////////////////////////////////////

    /*!
     * \brief Has the app the Bluetooth permissions needed by the background service?
     *
     * API 31+: BLUETOOTH_SCAN and BLUETOOTH_CONNECT.
     * BLUETOOTH_CONNECT is also required to start a connectedDevice foreground service on API 34+.
     */
    private static boolean hasBluetoothPermissions(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return context.checkSelfPermission(android.Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED &&
                   context.checkSelfPermission(android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED;
        }
        return true;
    }

    /*!
     * \brief Start the background service.
     *
     * Does nothing if the background service is disabled, or if the Bluetooth permissions are missing.
     * Must be called from the foreground app, or from the boot receiver.
     */
    public static void serviceStart(android.content.Context context) {
        //Log.i(TAG, ">>>> serviceStart() >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

        if (!isServiceEnabled(context)) return;

        if (!hasBluetoothPermissions(context)) {
            Log.w(TAG, "serviceStart() missing Bluetooth permissions, not starting the service");
            return;
        }

        android.content.Intent pQtAndroidService = new android.content.Intent(context, WatchFlowerAndroidService.class);
        try {
            context.startService(pQtAndroidService);
        } catch (Exception e) {
            Log.e(TAG, "serviceStart() failed", e);
        }
    }

    public static void serviceStop(android.content.Context context) {
        //Log.i(TAG, ">>>> serviceStop() >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

        android.content.Intent pQtAndroidService = new android.content.Intent(context, WatchFlowerAndroidService.class);
        context.stopService(pQtAndroidService);
    }
}

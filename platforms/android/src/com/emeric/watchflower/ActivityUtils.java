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

import android.util.Log;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.os.Build;

/*!
 * Bridges the GUI application and the background service, which run in two separate processes.
 * Communication uses package-internal broadcast Intents:
 * each side registers a runtime BroadcastReceiver that forwards incoming
 * messages to native (C++) code, which in turn emits a Qt signal.
 */
public class ActivityUtils {

    private static final String TAG = "ActivityUtils";

    // Package-internal broadcast actions
    public static final String ACTION_APP_STATE = "com.emeric.watchflower.APP_STATE";        // app -> service
    public static final String ACTION_DATA_UPDATED = "com.emeric.watchflower.DATA_UPDATED";  // service -> app
    public static final String ACTION_PING_SERVICE = "com.emeric.watchflower.PING_SERVICE";  // app -> service ("are you online?")
    public static final String ACTION_PING_APP = "com.emeric.watchflower.PING_APP";          // service -> app ("are you online?")
    public static final String ACTION_SERVICE_STATE = "com.emeric.watchflower.SERVICE_STATE";// service -> app (ping reply)
    public static final String EXTRA_FOREGROUND = "foreground";

    private static BroadcastReceiver serviceReceiver = null;  // lives in the service process
    private static BroadcastReceiver activityReceiver = null; // lives in the app process

    // Native callbacks, implemented in C++ (AndroidService.cpp)
    public static native void nativeAppStateReceived(boolean foreground); // service process
    public static native void nativeServicePinged();                      // service process (reply with "alive")
    public static native void nativeDataUpdatedReceived();                // app process
    public static native void nativeAppPinged();                          // app process (reply with current state)
    public static native void nativeServiceStateReceived();               // app process (service is alive)

    ////////////////////////////////////////////////////////////////////////////
    // Service process: receive app foreground/background notifications

    public static void registerServiceBroadcastReceiver(Context context) {
        if (serviceReceiver != null) return;

        serviceReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context c, Intent intent) {
                final String action = intent.getAction();
                try {
                    if (ACTION_APP_STATE.equals(action)) {
                        nativeAppStateReceived(intent.getBooleanExtra(EXTRA_FOREGROUND, false));
                    } else if (ACTION_PING_SERVICE.equals(action)) {
                        nativeServicePinged();
                    }
                } catch (Throwable t) {
                    Log.e(TAG, "serviceReceiver native callback failed", t);
                }
            }
        };

        IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_APP_STATE);
        filter.addAction(ACTION_PING_SERVICE);
        registerReceiverCompat(context, serviceReceiver, filter);
    }

    ////////////////////////////////////////////////////////////////////////////
    // App process: receive "data updated" notifications from the service

    public static void registerActivityBroadcastReceiver(Context context) {
        if (activityReceiver != null) return;

        activityReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context c, Intent intent) {
                final String action = intent.getAction();
                try {
                    if (ACTION_DATA_UPDATED.equals(action)) {
                        nativeDataUpdatedReceived();
                    } else if (ACTION_PING_APP.equals(action)) {
                        nativeAppPinged();
                    } else if (ACTION_SERVICE_STATE.equals(action)) {
                        nativeServiceStateReceived();
                    }
                } catch (Throwable t) {
                    Log.e(TAG, "activityReceiver native callback failed", t);
                }
            }
        };

        IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_DATA_UPDATED);
        filter.addAction(ACTION_PING_APP);
        filter.addAction(ACTION_SERVICE_STATE);
        registerReceiverCompat(context, activityReceiver, filter);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Unregister, once the native side is going away

    public static void unregisterServiceBroadcastReceiver(Context context) {
        if (serviceReceiver == null) return;

        try {
            context.unregisterReceiver(serviceReceiver);
        } catch (IllegalArgumentException e) {
            Log.w(TAG, "serviceReceiver was not registered", e);
        }
        serviceReceiver = null;
    }

    public static void unregisterActivityBroadcastReceiver(Context context) {
        if (activityReceiver == null) return;

        try {
            context.unregisterReceiver(activityReceiver);
        } catch (IllegalArgumentException e) {
            Log.w(TAG, "activityReceiver was not registered", e);
        }
        activityReceiver = null;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Senders

    public static void sendAppState(Context context, boolean foreground) {
        Intent intent = new Intent(ACTION_APP_STATE);
        intent.setPackage(context.getPackageName());
        intent.putExtra(EXTRA_FOREGROUND, foreground);
        context.sendBroadcast(intent);
    }

    public static void sendDataUpdated(Context context) {
        Intent intent = new Intent(ACTION_DATA_UPDATED);
        intent.setPackage(context.getPackageName());
        context.sendBroadcast(intent);
    }

    public static void checkServiceState(Context context) {
        Intent intent = new Intent(ACTION_PING_SERVICE);
        intent.setPackage(context.getPackageName());
        context.sendBroadcast(intent);
    }

    public static void pingApp(Context context) {
        Intent intent = new Intent(ACTION_PING_APP);
        intent.setPackage(context.getPackageName());
        context.sendBroadcast(intent);
    }

    public static void sendServiceAlive(Context context) {
        Intent intent = new Intent(ACTION_SERVICE_STATE);
        intent.setPackage(context.getPackageName());
        context.sendBroadcast(intent);
    }

    ////////////////////////////////////////////////////////////////////////////

    private static void registerReceiverCompat(Context context, BroadcastReceiver receiver, IntentFilter filter) {
        // The broadcasts are internal to our own package (same UID), so the
        // receivers must not be exported to other applications (API 33+).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED);
        } else {
            context.registerReceiver(receiver, filter);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}

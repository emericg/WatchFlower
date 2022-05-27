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

import org.qtproject.qt.android.bindings.QtService;

public class WatchFlowerAndroidService extends QtService {

    private static final String TAG = "WatchFlowerAndroidService";

    @Override
    public void onCreate() {
        super.onCreate();
        //Log.i(TAG, ">>>> Creating Service >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
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

    public static void serviceStart(android.content.Context context) {
        //Log.i(TAG, ">>>> serviceStart() >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

        android.content.Intent pQtAndroidService = new android.content.Intent(context, WatchFlowerAndroidService.class);
        pQtAndroidService.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startService(pQtAndroidService);
    }

    public static void serviceStop(android.content.Context context) {
        //Log.i(TAG, ">>>> serviceStop() >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

        android.content.Intent pQtAndroidService = new android.content.Intent(context, WatchFlowerAndroidService.class);
        context.stopService(pQtAndroidService);
    }
}

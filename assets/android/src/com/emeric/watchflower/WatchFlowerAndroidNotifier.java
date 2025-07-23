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

import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import androidx.core.app.NotificationCompat; 

public class WatchFlowerAndroidNotifier {

    private static String channelId = "watchflower_app";
    private static String channelName = "WatchFlower";
    private static int channelColor = Color.WHITE;
    private static int channelImportance = NotificationManager.IMPORTANCE_DEFAULT;

    public static void notify(final Context context, final String title, final String message, final int channel) {

        if (channel == 0) {
            channelId = "watchflower_app";
            channelName = "app notifications";
            channelColor = Color.WHITE;
            channelImportance = NotificationManager.IMPORTANCE_DEFAULT;
        }
        if (channel == 1) {
            channelId = "watchflower_plant";
            channelName = "plant notifications";
            channelColor = Color.BLUE;
            channelImportance = NotificationManager.IMPORTANCE_DEFAULT;
        }
        if (channel == 2) {
            channelId = "watchflower_thermometer";
            channelName = "thermometer notifications";
            channelColor = Color.GREEN;
            channelImportance = NotificationManager.IMPORTANCE_DEFAULT;
        }
        if (channel == 3) {
            channelId = "watchflower_environmental";
            channelName = "environmental notifications";
            channelColor = Color.YELLOW;
            channelImportance = NotificationManager.IMPORTANCE_HIGH;
        }
        if (channel == 4) {
            channelId = "watchflower_sensors";
            channelName = "sensor related notifications";
            channelColor = Color.WHITE;
            channelImportance = NotificationManager.IMPORTANCE_DEFAULT;
        }

        try {
            String packageName = context.getApplicationContext().getPackageName();
            //Context context = getApplicationContext();

            Intent resultIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
            resultIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);

            PendingIntent resultPendingIntent = PendingIntent.getActivity(context, 0, resultIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
            NotificationCompat.Builder builder;

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                NotificationChannel notificationChannel = new NotificationChannel(channelId, channelName, channelImportance);
                notificationChannel.enableLights(true);
                notificationChannel.setLightColor(channelColor);
                notificationChannel.enableVibration(false);
                //notificationChannel.setVibrationPattern(new long[]{500,500,500,500,500});
                notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

                notificationManager.createNotificationChannel(notificationChannel);
                builder = new NotificationCompat.Builder(context, notificationChannel.getId());
            } else {
                builder = new NotificationCompat.Builder(context);
            }

            builder.setSmallIcon(R.drawable.ic_stat_logo);
            //Bitmap icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_stat_logo);
            //builder.setLargeIcon(icon);
            //builder.setColor(Color.WHITE);
            builder.setContentTitle(title);
            builder.setContentText(message);
            builder.setContentIntent(resultPendingIntent);
            builder.setWhen(System.currentTimeMillis());
            builder.setShowWhen(true);
            builder.setDefaults(Notification.DEFAULT_SOUND);
            builder.setOnlyAlertOnce(true);
            builder.setAutoCancel(true);
            builder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));

            notificationManager.notify(channel, builder.build());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

/*
 * Copyright (c) 2017 Ekkehard Gentz (ekke)
 * Copyright (c) 2022 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package com.emeric.utils;

import org.qtproject.qt.android.QtNative;

import java.lang.String;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.util.List;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;

import android.util.Log;
import android.net.Uri;
import android.os.Parcelable;
import android.os.Build;
import android.database.Cursor;
import android.provider.MediaStore;
import android.content.Intent;
import android.content.Context;
import android.content.ContentResolver;
import android.content.pm.ResolveInfo;
import android.content.pm.PackageManager;
import androidx.core.content.FileProvider;
import androidx.core.app.ShareCompat;

public class QShareUtils
{
    // reference Authority as defined in AndroidManifest.xml
    private static String AUTHORITY="com.emeric.watchflower.fileprovider";

    protected QShareUtils() {
       //Log.d("QShareUtils", "QShareUtils()");
    }

    public static boolean checkMimeTypeView(String mimeType) {
        if (QtNative.activity() == null) return false;

        Intent myIntent = new Intent();
        myIntent.setAction(Intent.ACTION_VIEW);
        // without an URI resolve always fails
        // an empty URI allows to resolve the Activity
        File fileToShare = new File("");
        Uri uri = Uri.fromFile(fileToShare);
        myIntent.setDataAndType(uri, mimeType);

        // Verify that the intent will resolve to an activity
        if (myIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            Log.d("QShareUtils", " checkMime() yes - we can go on and View");
            return true;
        } else {
            Log.d("QShareUtils", " checkMime() sorry - no App available to View");
        }
        return false;
    }

    public static boolean checkMimeTypeEdit(String mimeType) {
        if (QtNative.activity() == null) return false;

        Intent myIntent = new Intent();
        myIntent.setAction(Intent.ACTION_EDIT);
        // without an URI resolve always fails
        // an empty URI allows to resolve the Activity
        File fileToShare = new File("");
        Uri uri = Uri.fromFile(fileToShare);
        myIntent.setDataAndType(uri, mimeType);

        // Verify that the intent will resolve to an activity
        if (myIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            Log.d("QShareUtils", " checkMime() yes - we can go on and Edit");
            return true;
        } else {
            Log.d("QShareUtils", " checkMime() sorry - no App available to Edit");
        }
        return false;
    }

    public static boolean share(String text, String url) {
        if (QtNative.activity() == null) return false;

        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, text + " " + url);
        sendIntent.setType("text/plain");

        // Verify that the intent will resolve to an activity
        if (sendIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            QtNative.activity().startActivity(sendIntent);
            return true;
        } else {
            Log.d("QShareUtils", " share() Intent not resolved");
        }
        return false;
    }

    // thx @oxied and @pooks for the idea: https://stackoverflow.com/a/18835895/135559
    // theIntent is already configured with all needed properties and flags
    // so we only have to add the packageName of targeted app
    public static boolean createCustomChooserAndStartActivity(Intent theIntent, String title, int requestId, Uri uri) {
        final Context context = QtNative.activity();
        final PackageManager packageManager = context.getPackageManager();

        // MATCH_DEFAULT_ONLY: Resolution and querying flag. if set, only filters that support the CATEGORY_DEFAULT will be considered for matching.
        // Check if there is a default app for this type of content.
        ResolveInfo defaultAppInfo = packageManager.resolveActivity(theIntent, PackageManager.MATCH_DEFAULT_ONLY);
        if (defaultAppInfo == null) {
            Log.d("QShareUtils", title + " PackageManager cannot resolve Activity");
            return false;
        }

        // had to remove this check - there can be more Activity names, per ex
        // com.google.android.apps.docs.editors.kix.quickword.QuickWordDocumentOpenerActivityAlias
        // if (!defaultAppInfo.activityInfo.name.endsWith("ResolverActivity") && !defaultAppInfo.activityInfo.name.endsWith("EditActivity")) {
            // Log.d("QShareUtils", title + " defaultAppInfo not Resolver or EditActivity: " + defaultAppInfo.activityInfo.name);
            // return false;
        //}

        // Retrieve all apps for our intent. Check if there are any apps returned
        List<ResolveInfo> appInfoList = packageManager.queryIntentActivities(theIntent, PackageManager.MATCH_DEFAULT_ONLY);
        if (appInfoList.isEmpty()) {
            Log.d("QShareUtils", title + " appInfoList.isEmpty");
            return false;
        }
        Log.d("QShareUtils", title + " appInfoList: " + appInfoList.size());

        // Sort in alphabetical order
        Collections.sort(appInfoList, new Comparator<ResolveInfo>() {
            @Override
            public int compare(ResolveInfo first, ResolveInfo second) {
                String firstName = first.loadLabel(packageManager).toString();
                String secondName = second.loadLabel(packageManager).toString();
                return firstName.compareToIgnoreCase(secondName);
            }
        });

        List<Intent> targetedIntents = new ArrayList<Intent>();
        // Filter itself and create intent with the rest of the apps.
        for (ResolveInfo appInfo : appInfoList) {
            // get the target PackageName
            String targetPackageName = appInfo.activityInfo.packageName;
            // we don't want to share with our own app
            // in fact sharing with own app with resultCode will crash because doesn't work well with launch mode 'singleInstance'
            if (targetPackageName.equals(context.getPackageName())) {
                continue;
            }
            // if you have a blacklist of apps please exclude them here

            // we create the targeted Intent based on our already configured Intent
            Intent targetedIntent = new Intent(theIntent);
            // now add the target packageName so this Intent will only find the one specific App
            targetedIntent.setPackage(targetPackageName);
            // collect all these targetedIntents
            targetedIntents.add(targetedIntent);

            // did some changes to make it run with API 30+ and Android 13 devices.
            // removed KitKat check and added queries to AndroidManifest
            // thx: https://forum.qt.io/topic/127170/android-11-qdir-mkdir-does-not-always-work/11
            context.grantUriPermission(targetPackageName, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        }

        // check if there are apps found for our Intent to avoid that there was only our own removed app before
        if (targetedIntents.isEmpty()) {
            Log.d("QShareUtils", title + " targetedIntents.isEmpty");
            return false;
        }

        // now we can create our Intent with custom Chooser
        // we need all collected targetedIntents as EXTRA_INITIAL_INTENTS
        // we're using the last targetedIntent as initializing Intent, because
        // chooser adds its initializing intent to the end of EXTRA_INITIAL_INTENTS :)
        Intent chooserIntent = Intent.createChooser(targetedIntents.remove(targetedIntents.size() - 1), title);
        if (targetedIntents.isEmpty()) {
            Log.d("QShareUtils", title + " only one Intent left for Chooser");
        } else {
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetedIntents.toArray(new Parcelable[] {}));
        }
        // Verify that the intent will resolve to an activity
        if (chooserIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            if (requestId > 0) {
                QtNative.activity().startActivityForResult(chooserIntent, requestId);
            } else {
                QtNative.activity().startActivity(chooserIntent);
            }
            return true;
        }
        Log.d("QShareUtils", title + " Chooser Intent not resolved. Should never happen");
        return false;
    }

    public static boolean sendFile(String filePath, String title, String mimeType, int requestId) {
        if (QtNative.activity() == null) return false;

        // using v4 support library create the Intent from ShareCompat
        // Intent sendIntent = new Intent();
        Intent sendIntent = ShareCompat.IntentBuilder.from(QtNative.activity()).getIntent();
        sendIntent.setAction(Intent.ACTION_SEND);

        File fileToShare = new File(filePath);

        // Using FileProvider you must get the URI from FileProvider using your AUTHORITY
        // Uri uri = Uri.fromFile(fileToShare);
        Uri uri;
        try {
            uri = FileProvider.getUriForFile(QtNative.activity(), AUTHORITY, fileToShare);
        } catch (IllegalArgumentException e) {
            Log.d("QShareUtils", " cannot be shared: " + filePath + " " + e);
            return false;
        }

        Log.d("QShareUtils", " sendFile " + uri.toString());
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);

        if (mimeType == null || mimeType.isEmpty()) {
            // fallback if mimeType not set
            mimeType = QtNative.activity().getContentResolver().getType(uri);
            Log.d("QShareUtils", " sendFile guessed mimeType: " + mimeType);
        } else {
            Log.d("QShareUtils", " sendFile w mimeType: " + mimeType);
        }

        sendIntent.setType(mimeType);

        sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        sendIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        return createCustomChooserAndStartActivity(sendIntent, title, requestId, uri);
    }

    public static boolean viewFile(String filePath, String title, String mimeType, int requestId) {
        if (QtNative.activity() == null) return false;

        // using v4 support library create the Intent from ShareCompat
        // Intent viewIntent = new Intent();
        Intent viewIntent = ShareCompat.IntentBuilder.from(QtNative.activity()).getIntent();
        viewIntent.setAction(Intent.ACTION_VIEW);

        File fileToShare = new File(filePath);

        // Using FileProvider you must get the URI from FileProvider using your AUTHORITY
        // Uri uri = Uri.fromFile(fileToShare);
        Uri uri;
        try {
            uri = FileProvider.getUriForFile(QtNative.activity(), AUTHORITY, fileToShare);
        } catch (IllegalArgumentException e) {
            Log.d("QShareUtils", " viewFile - cannot be shared: " + filePath);
            return false;
        }
        // now we got a content URI per ex
        // content://org.ekkescorner.examples.sharex.fileprovider/my_shared_files/qt-logo.png
        // from a fileUrl:
        // /data/user/0/org.ekkescorner.examples.sharex/files/share_example_x_files/qt-logo.png
        Log.d("QShareUtils", " viewFile from file path: " + filePath);
        Log.d("QShareUtils", " viewFile to content URI: " + uri.toString());

        if (mimeType == null || mimeType.isEmpty()) {
            // fallback if mimeType not set
            mimeType = QtNative.activity().getContentResolver().getType(uri);
            Log.d("QShareUtils", " viewFile guessed mimeType: " + mimeType);
        } else {
            Log.d("QShareUtils", " viewFile w mimeType: " + mimeType);
        }

        viewIntent.setDataAndType(uri, mimeType);

        viewIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        viewIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        return createCustomChooserAndStartActivity(viewIntent, title, requestId, uri);
    }

    public static boolean editFile(String filePath, String title, String mimeType, int requestId) {
        if (QtNative.activity() == null) return false;

        // using v4 support library create the Intent from ShareCompat
        // Intent editIntent = new Intent();
        Intent editIntent = ShareCompat.IntentBuilder.from(QtNative.activity()).getIntent();
        editIntent.setAction(Intent.ACTION_EDIT);

        File fileToShare = new File(filePath);

        // Using FileProvider you must get the URI from FileProvider using your AUTHORITY
        // Uri uri = Uri.fromFile(fileToShare);
        Uri uri;
        try {
            uri = FileProvider.getUriForFile(QtNative.activity(), AUTHORITY, fileToShare);
        } catch (IllegalArgumentException e) {
            Log.d("QShareUtils", " editFile - cannot be shared: " + filePath);
            return false;
        }
        Log.d("QShareUtils", " editFile " + uri.toString());

        if (mimeType == null || mimeType.isEmpty()) {
            // fallback if mimeType not set
            mimeType = QtNative.activity().getContentResolver().getType(uri);
            Log.d("QShareUtils", " editFile guessed mimeType: " + mimeType);
        } else {
            Log.d("QShareUtils", " editFile w mimeType: " + mimeType);
        }

        editIntent.setDataAndType(uri, mimeType);

        editIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        editIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        return createCustomChooserAndStartActivity(editIntent, title, requestId, uri);
    }

    public static String getContentName(ContentResolver cR, Uri uri) {
        Cursor cursor = cR.query(uri, null, null, null, null);
        cursor.moveToFirst();
        int nameIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME);
        if (nameIndex >= 0) {
            return cursor.getString(nameIndex);
        } else {
            return null;
        }
    }

    public static String createFile(ContentResolver cR, Uri uri, String fileLocation) {
        String filePath = null;
        try {
            InputStream iStream = cR.openInputStream(uri);
            if (iStream != null) {
                String name = getContentName(cR, uri);
                if (name != null) {
                    filePath = fileLocation + "/" + name;
                    Log.d("QShareUtils", " createFile() " + filePath);
                    File f = new File(filePath);
                    FileOutputStream tmp = new FileOutputStream(f);
                    Log.d("QShareUtils", " createFile() new FileOutputStream");

                    byte[] buffer = new byte[1024];
                    while (iStream.read(buffer) > 0) {
                        tmp.write(buffer);
                    }
                    tmp.close();
                    iStream.close();
                    return filePath;
                } // name
            } // iStream
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return filePath;
        } catch (IOException e) {
            e.printStackTrace();
            return filePath;
        } catch (Exception e) {
            e.printStackTrace();
            return filePath;
        }

        return filePath;
    }
}

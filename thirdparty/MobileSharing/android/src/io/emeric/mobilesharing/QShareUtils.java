/*
 * Copyright (c) 2017 Ekkehard Gentz (ekke)
 * Copyright (c) 2026 Emeric Grange
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

package io.emeric.mobilesharing;

import java.lang.String;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Collections;

import android.util.Log;
import android.net.Uri;
import android.database.Cursor;
import android.provider.OpenableColumns;
import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.content.ContentResolver;
import android.content.SharedPreferences;
import android.provider.DocumentsContract;
import android.webkit.MimeTypeMap;
import androidx.core.content.FileProvider;

public class QShareUtils
{
    // store the app main activity
    private static Activity m_activity = null;

    protected QShareUtils() {
       //Log.d("QShareUtils", "QShareUtils()");
    }

    public void setActivity(Activity activity) {
        m_activity = activity;
        if (m_activity == null) {
            Log.d("QShareUtils", "Activity is null");
        }
    }

    // -------------------------------------------------------------------------
    // MimeTypes helpers
    // -------------------------------------------------------------------------

    public static boolean checkMimeTypeView(String mimeType) {
        if (m_activity == null) return false;

        Intent myIntent = new Intent();
        myIntent.setAction(Intent.ACTION_VIEW);
        // without an URI resolve always fails
        // an empty URI allows to resolve the Activity
        File fileToShare = new File("");
        Uri uri = Uri.fromFile(fileToShare);
        myIntent.setDataAndType(uri, mimeType);

        // Verify that the intent will resolve to an activity
        if (myIntent.resolveActivity(m_activity.getPackageManager()) != null) {
            Log.d("QShareUtils", " checkMime() yes - we can go on and View");
            return true;
        } else {
            Log.d("QShareUtils", " checkMime() sorry - no App available to View");
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Outgoing content helpers
    // -------------------------------------------------------------------------

    public static boolean sendText(String text, String subject, String url) {
        if (m_activity == null) return false;

        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        String body = (url == null || url.isEmpty()) ? text : (text + " " + url);
        sendIntent.putExtra(Intent.EXTRA_TEXT, body);
        sendIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        sendIntent.setType("text/plain");

        Intent chooserIntent = Intent.createChooser(sendIntent, "Share to messenger");

        // Launch the chooser directly. Don't gate on resolveActivity(): on Android 11+ it is
        // filtered by package visibility and can falsely return null, while the system chooser
        // is exempt from that filtering anyway. Only a thrown ActivityNotFoundException (no app
        // at all) is a real miss.
        try {
            m_activity.startActivity(chooserIntent);
            return true;
        } catch (android.content.ActivityNotFoundException e) {
            Log.d("QShareUtils", " sendText() no app to handle ACTION_SEND - " + e);
            return false;
        }
    }

    public static boolean sendFile(String filePath, String title, String mimeType, int requestId) {
        if (m_activity == null) return false;
        final Context context = m_activity;
        if (context == null) return false;

        // (v2)
        File file = new File(filePath);
        Uri fileUri;
        try {
            fileUri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", file);
        } catch (IllegalArgumentException e) {
            // path not under a filepaths.xml root (the C++ layer normally prevents this)
            Log.e("QShareUtils", "sendFile: cannot be shared: " + filePath + " - " + e);
            return false;
        }

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setDataAndType(fileUri, mimeType);
        shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        context.startActivity(Intent.createChooser(shareIntent, "Share file using"));

        return true;
    }

    public static boolean sendFiles(String[] filePaths, String title, String mimeType, int requestId) {
        if (m_activity == null) return false;
        final Context context = m_activity;

        ArrayList<Uri> uris = new ArrayList<Uri>();
        for (String path : filePaths) {
            if (path == null || path.isEmpty()) continue;
            try {
                uris.add(FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", new File(path)));
            } catch (IllegalArgumentException e) {
                // path not under a filepaths.xml root (the C++ layer normally prevents this)
                Log.e("QShareUtils", "sendFiles: cannot be shared: " + path + " - " + e);
            }
        }
        if (uris.isEmpty()) {
            Log.e("QShareUtils", "sendFiles: no shareable files");
            return false;
        }

        Intent shareIntent = new Intent(Intent.ACTION_SEND_MULTIPLE);
        shareIntent.setType((mimeType == null || mimeType.isEmpty()) ? "*/*" : mimeType);
        shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        context.startActivity(Intent.createChooser(shareIntent, "Share files using"));

        return true;
    }

    public static boolean viewFile(String filePath, String title, String mimeType, int requestId) {
        if (m_activity == null) return false;
        final Context context = m_activity;
        if (context == null) return false;

        File file = new File(filePath);
        Uri fileUri;
        try {
            fileUri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", file);
        } catch (IllegalArgumentException e) {
            Log.e("QShareUtils", "viewFile: cannot be shared: " + filePath + " - " + e);
            return false;
        }

        Intent shareIntent = new Intent(Intent.ACTION_VIEW);
        shareIntent.setDataAndType(fileUri, mimeType);
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        context.startActivity(Intent.createChooser(shareIntent, "View file using"));

        return true;
    }

    // -------------------------------------------------------------------------
    // Incoming content helpers (used by QShareActivity.processIntent())
    // -------------------------------------------------------------------------

    // Resolve the human-readable display name of a content:// Uri, or null.
    public static String getContentName(ContentResolver cR, Uri uri) {
        Cursor cursor = cR.query(uri, null, null, null, null);
        if (cursor == null) {
            return null;
        }
        try {
            int nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
            if (nameIndex >= 0 && cursor.moveToFirst()) {
                return cursor.getString(nameIndex);
            }
        } finally {
            cursor.close();
        }
        return null;
    }

    // Copy the content behind a file:// or content:// Uri into workingDirPath via an
    // InputStream, so the app always gets a real, readable file it owns.
    // Returns the absolute path of the written file, or null on failure.
    public static String createFile(ContentResolver cR, Uri uri, String workingDirPath) {
        if (workingDirPath == null || workingDirPath.isEmpty()) {
            Log.e("QShareUtils", "createFile: workingDirPath is empty");
            return null;
        }

        // Best display name: ContentResolver (content://), else the Uri's last
        // segment (file://), else a timestamped name keeping the mime extension.
        String name = getContentName(cR, uri);
        if (name == null || name.isEmpty()) {
            name = uri.getLastPathSegment();
        }
        if (name == null || name.isEmpty() || name.contains("/")) {
            String ext = MimeTypeMap.getSingleton().getExtensionFromMimeType(cR.getType(uri));
            name = "shared_" + System.currentTimeMillis() + (ext != null ? "." + ext : "");
        }

        File dir = new File(workingDirPath);
        if (!dir.exists() && !dir.mkdirs()) {
            Log.e("QShareUtils", "createFile: cannot create working dir " + workingDirPath);
            return null;
        }

        File file = new File(dir, name);
        try (InputStream is = cR.openInputStream(uri);
             FileOutputStream os = new FileOutputStream(file)) {
            if (is == null) {
                Log.e("QShareUtils", "createFile: cannot open InputStream for " + uri);
                return null;
            }
            byte[] buffer = new byte[4096];
            int length;
            while ((length = is.read(buffer)) > 0) {
                os.write(buffer, 0, length);
            }
            Log.d("QShareUtils", "createFile: wrote " + file.getAbsolutePath());
            return file.getAbsolutePath();
        } catch (Exception e) {
            Log.e("QShareUtils", "createFile: failed - " + e.getMessage());
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // Outgoing "save file to..." helpers (SAF ACTION_CREATE_DOCUMENT)
    // -------------------------------------------------------------------------

    // Source paths for in-flight saveFile() requests, keyed by request code. The
    // destination is only known later (in QShareActivity.onActivityResult), so we
    // stash the source here between launching the picker and writing the bytes.
    private static final Map<Integer, String> pendingSaves =
            Collections.synchronizedMap(new HashMap<Integer, String>());

    public static boolean isPendingSave(int requestCode) {
        return pendingSaves.containsKey(requestCode);
    }

    // Launch the system "create document" picker. The actual write happens in
    // completeSave() once the user picked a destination. Returns false (so the C++
    // layer can report an error) if there is no QShareActivity to receive the result.
    public static boolean saveFile(String sourcePath, String suggestedName, String mimeType, int requestId) {
        if (m_activity == null) return false;
        if (!(m_activity instanceof QShareActivity)) {
            // Without QShareActivity, onActivityResult() won't reach us and the result is lost.
            Log.e("QShareUtils", "saveFile: requires QShareActivity to receive the result");
            return false;
        }

        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType((mimeType == null || mimeType.isEmpty()) ? "*/*" : mimeType);
        if (suggestedName != null && !suggestedName.isEmpty()) {
            intent.putExtra(Intent.EXTRA_TITLE, suggestedName);
        }

        // Do NOT gate this on resolveActivity(): ACTION_CREATE_DOCUMENT is always handled by
        // the system DocumentsUI, but resolveActivity()/queryIntentActivities() are filtered by
        // Android 11+ package visibility and return null here even though startActivityForResult()
        // succeeds. So launch directly and only treat a thrown ActivityNotFoundException as failure.
        pendingSaves.put(requestId, sourcePath);
        QShareActivity.ownRequestCodes.add(requestId);
        try {
            m_activity.startActivityForResult(intent, requestId);
            return true;
        } catch (android.content.ActivityNotFoundException e) {
            Log.e("QShareUtils", "saveFile: no activity to handle ACTION_CREATE_DOCUMENT - " + e);
            pendingSaves.remove(requestId);
            QShareActivity.ownRequestCodes.remove(requestId);
            return false;
        }
    }

    // Called from QShareActivity.onActivityResult(): write the stashed source file into the
    // user-chosen destination Uri (null means the user cancelled), then notify C++ natively.
    public static void completeSave(ContentResolver cR, int requestCode, Uri destUri) {
        String sourcePath = pendingSaves.remove(requestCode);

        if (destUri == null) {
            QShareActivity.fireSaveResult(requestCode, false, true); // cancelled
            return;
        }
        if (sourcePath == null) {
            Log.e("QShareUtils", "completeSave: no pending source for request " + requestCode);
            QShareActivity.fireSaveResult(requestCode, false, false);
            return;
        }

        boolean ok = writeFileToUri(cR, sourcePath, destUri);
        QShareActivity.fireSaveResult(requestCode, ok, false);
    }

    // Stream a local file into a content:// Uri via the ContentResolver's OutputStream.
    private static boolean writeFileToUri(ContentResolver cR, String sourcePath, Uri destUri) {
        try (InputStream is = new FileInputStream(sourcePath);
             OutputStream os = cR.openOutputStream(destUri)) {
            if (os == null) {
                Log.e("QShareUtils", "writeFileToUri: cannot open OutputStream for " + destUri);
                return false;
            }
            byte[] buffer = new byte[4096];
            int length;
            while ((length = is.read(buffer)) > 0) {
                os.write(buffer, 0, length);
            }
            Log.d("QShareUtils", "writeFileToUri: wrote " + sourcePath + " -> " + destUri);
            return true;
        } catch (Exception e) {
            Log.e("QShareUtils", "writeFileToUri: failed - " + e.getMessage());
            return false;
        }
    }

    // -------------------------------------------------------------------------
    // Directory sharing config (SAF DocumentsProvider) -- see QShareDocumentProvider
    // -------------------------------------------------------------------------

    // SharedPreferences store read by QShareDocumentProvider (keys kept in sync there). The provider
    // may be queried by the system in a bare process before any Qt/QML is up, so its whole state has
    // to live somewhere it can read without us: SharedPreferences.
    public static final String DOC_PROVIDER_PREFS = "MobileSharingDocProvider";

    // Authority of our DocumentsProvider, must match the AndroidManifest <provider> entry
    // (android:authorities="${applicationId}.documents").
    private static String docProviderAuthority(Context context) {
        return context.getPackageName() + ".documents";
    }

    // Enable/disable the DocumentsProvider and point it at an app-owned directory. Persists the
    // config and pokes SAF so any open picker refreshes its list of roots. 'writable' is plumbed
    // for the future read/write wave; the provider currently serves read-only regardless.
    // Returns false if the activity/context is missing or the directory could not be created.
    public static boolean setDocumentProvider(boolean enabled, String rootDirPath, boolean writable, String title) {
        if (m_activity == null) return false;
        final Context context = m_activity;

        if (enabled) {
            if (rootDirPath == null || rootDirPath.isEmpty()) {
                Log.e("QShareUtils", "setDocumentProvider: empty rootDirPath");
                return false;
            }
            File dir = new File(rootDirPath);
            if (!dir.exists() && !dir.mkdirs()) {
                Log.e("QShareUtils", "setDocumentProvider: cannot create " + rootDirPath);
                return false;
            }
        }

        SharedPreferences prefs = context.getSharedPreferences(DOC_PROVIDER_PREFS, Context.MODE_PRIVATE);
        prefs.edit()
             .putBoolean("enabled", enabled)
             .putString("rootDir", rootDirPath != null ? rootDirPath : "")
             .putBoolean("writable", writable)
             .putString("title", (title != null && !title.isEmpty()) ? title : "Shared")
             .apply();

        // Tell SAF our set of roots changed, so the root appears/disappears live in any open picker.
        try {
            Uri rootsUri = DocumentsContract.buildRootsUri(docProviderAuthority(context));
            context.getContentResolver().notifyChange(rootsUri, null);
        } catch (Exception e) {
            Log.w("QShareUtils", "setDocumentProvider: notifyChange failed - " + e.getMessage());
        }

        Log.d("QShareUtils", "setDocumentProvider: enabled=" + enabled + " writable=" + writable + " dir=" + rootDirPath);
        return true;
    }

    // Read the persisted config back.
    // Lets the C++/QML side mirror the live provider state on a fresh launch,
    // (the provider keeps serving from these prefs even when the app UI is not running).
    private static SharedPreferences docProviderPrefs() {
        if (m_activity == null) return null;
        return m_activity.getSharedPreferences(DOC_PROVIDER_PREFS, Context.MODE_PRIVATE);
    }

    public static boolean getDirectorySharingEnabled() {
        SharedPreferences prefs = docProviderPrefs();
        return prefs != null && prefs.getBoolean("enabled", false);
    }

    public static String getSharedDirectory() {
        SharedPreferences prefs = docProviderPrefs();
        return prefs != null ? prefs.getString("rootDir", "") : "";
    }

    public static boolean getSharedDirectoryWritable() {
        SharedPreferences prefs = docProviderPrefs();
        return prefs != null && prefs.getBoolean("writable", false);
    }

    public static String getSharedDirectoryTitle() {
        SharedPreferences prefs = docProviderPrefs();
        return prefs != null ? prefs.getString("title", "") : "";
    }
}

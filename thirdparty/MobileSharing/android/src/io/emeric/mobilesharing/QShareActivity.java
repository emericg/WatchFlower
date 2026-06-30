/*!
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

import org.qtproject.qt.android.QtNative;
import org.qtproject.qt.android.bindings.QtActivity;
import android.os.*;
import android.app.*;
import android.content.*;

import java.io.File;
import java.lang.String;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;
import java.util.Collections;
import android.net.Uri;
import android.util.Log;
import android.content.Intent;
import android.content.ContentResolver;

public class QShareActivity extends QtActivity
{
    // native - must be implemented in Cpp via JNI
    // (registered from C++ via QJniEnvironment::registerNativeMethods, see MobileSharing_android.cpp)
    // an incoming file, already copied into our cache dir:
    public static native void setFileReceived(String filePath);
    // result of a saveFile() flow (ACTION_CREATE_DOCUMENT + ContentResolver write):
    public static native void fireSaveResult(int requestCode, boolean success, boolean canceled);

    public static boolean isIntentPending;
    public static boolean isInitialized;
    public static String workingDirPath;

    // Request codes this module launched via startActivityForResult() (see QShareUtils).
    // onActivityResult() only consumes results for these and lets Qt handle everything
    // else (like its own QFileDialog), so we don't emit spurious share signals.
    public static final Set<Integer> ownRequestCodes = Collections.synchronizedSet(new HashSet<Integer>());

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d("QShareActivity", " onCreate() QShareActivity");
        // now we're checking if the App was started from another Android App via Intent
        Intent theIntent = getIntent();
        if (theIntent != null) {
            String theAction = theIntent.getAction();
            if (theAction != null) {
                Log.d("QShareActivity", " onCreate()" + theAction);
                // QML UI not ready yet, delay processIntent();
                isIntentPending = true;
            }
        }
    }

    @Override
    public void onDestroy() {
        Log.d("QShareActivity", " onDestroy() QShareActivity");
        // NOTE: historically this called System.exit(0) to work around a 2nd
        // onCreate() seen with some file managers under singleInstance. That kills
        // the whole process on any teardown (it was crashing the app right after a
        // share). With launchMode="singleTask" the running instance is reused via
        // onNewIntent(), so we keep the normal Activity lifecycle instead.
        super.onDestroy();
    }

    // Results for activities we launched with startActivityForResult() arrive here. Only
    // saveFile() (ACTION_CREATE_DOCUMENT) uses this now; its result is handed to C++ through
    // the fireSaveResult() JNI callback. Everything else (e.g. Qt's own QFileDialog) was
    // already dispatched to Qt by super.onActivityResult() and must be left untouched.
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("QShareActivity", " onActivityResult() requestCode: " + requestCode);
        super.onActivityResult(requestCode, resultCode, data);

        // Only consume results for requests this module started (tracked in ownRequestCodes);
        // consuming Qt's own dialog results would be wrong.
        if (!ownRequestCodes.remove(requestCode)) {
            return;
        }

        // saveFile() flow (ACTION_CREATE_DOCUMENT): stream our source into the user-chosen
        // destination URI, then report success/cancel back natively via fireSaveResult().
        if (QShareUtils.isPendingSave(requestCode)) {
            Uri destUri = (resultCode == RESULT_OK && data != null) ? data.getData() : null;
            QShareUtils.completeSave(getContentResolver(), requestCode, destUri);
        }
    }

    // if we are opened from other apps:
    @Override
    public void onNewIntent(Intent intent) {
        Log.d("QShareActivity", " onNewIntent()");
        super.onNewIntent(intent);

        setIntent(intent);
        // Intent will be processed, if all is initialized and Qt / QML can handle the event
        if (isInitialized) {
            processIntent();
        } else {
            isIntentPending = true;
        }
    }

    public void checkPendingIntents(String workingDir) {
        isInitialized = true;
        workingDirPath = workingDir;
        Log.d("QShareActivity", workingDirPath);
        if (isIntentPending) {
            isIntentPending = false;
            Log.d("QShareActivity", " checkPendingIntents() true");
            processIntent();
        } else {
            //Log.d("QShareActivity", " checkPendingIntents() nothingPending");
        }
    }

    // EXTRA_STREAM helpers. getParcelable[ArrayList]Extra(String) is deprecated on API 33+,
    // so prefer the typed overload there and isolate the legacy suppression to these helpers.
    private static Uri extraStream(Intent intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri.class);
        }
        return legacyExtraStream(intent);
    }

    @SuppressWarnings("deprecation")
    private static Uri legacyExtraStream(Intent intent) {
        return (Uri) intent.getParcelableExtra(Intent.EXTRA_STREAM);
    }

    private static ArrayList<Uri> extraStreamList(Intent intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri.class);
        }
        return legacyExtraStreamList(intent);
    }

    @SuppressWarnings("deprecation")
    private static ArrayList<Uri> legacyExtraStreamList(Intent intent) {
        return intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
    }

    // Process the incoming Intent: ACTION_VIEW / ACTION_SEND carry a single item,
    // ACTION_SEND_MULTIPLE carries many. Each Uri is copied into our cache and
    // surfaced one-by-one via setFileReceived(), so a multi-file share simply
    // produces several fileReceived() callbacks.
    private void processIntent() {
        Intent intent = getIntent();
        String action = intent.getAction();

        List<Uri> uris = new ArrayList<Uri>();
        if ("android.intent.action.VIEW".equals(action)) {
            uris.add(intent.getData());
        } else if ("android.intent.action.SEND".equals(action)) {
            uris.add(extraStream(intent));
        } else if ("android.intent.action.SEND_MULTIPLE".equals(action)) {
            ArrayList<Uri> list = extraStreamList(intent);
            if (list != null) uris.addAll(list);
        } else {
            Log.d("QShareActivity", " processIntent() Intent unknown action: " + action);
            return;
        }

        // We always copy the incoming content (file:// or content://) into our
        // own cache dir via an InputStream, so the app always gets a real, readable
        // file it owns. ContentResolver.openInputStream() handles both schemes.
        ContentResolver cR = this.getContentResolver();
        int received = 0;
        for (Uri uri : uris) {
            if (uri == null) continue;
            Log.d("QShareActivity", " processIntent() Intent URI: " + uri.toString());
            String filePath = QShareUtils.createFile(cR, uri, workingDirPath);
            if (filePath == null) {
                Log.d("QShareActivity", " processIntent() could not copy incoming file: " + uri);
                continue;
            }
            setFileReceived(filePath);
            received++;
        }
        if (received == 0) {
            Log.d("QShareActivity", " processIntent() no usable incoming file");
        }
    }
}

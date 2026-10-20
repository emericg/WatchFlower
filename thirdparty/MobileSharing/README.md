# MobileSharing

MobileSharing allows Qt / QML mobile applications to easily share, receive, open & save files...

You can see it in action in the [MobileSharing demo](https://github.com/emericg/MobileSharing_demo).

> Supports Qt 6.8+ with CMake.

> Supports iOS 16+. Tested up to iOS 17.7 devices.

> Supports Android 9+ (API 28). Tested up to Android 16 (API 36) devices.

> [!WARNING]
> Still a work in progress at the moment...


## Features

- Handle the Android & iOS specific features for sending & recieving files / links / text between apps!
- Minimal disruption on the host project using it! Build it, link it, use it.

- Send files / texts / links...
- Receive files / texts / links...
- Easily set up an Android DocumentProvider
- Bypass Qt broken open & save functionnalities on Android and iOS


## Quick start

### Build

To get started, simply checkout the MobileSharing repository as a submodule, or copy the
MobileSharing directory into your project, then include the `CMakeLists.txt` CMake project file:

```cmake
add_subdirectory(MobileSharing/)
target_link_libraries(${PROJECT_NAME} PRIVATE MobileSharing MobileSharing_plugin)
```

You might need some hacks so the QML Language Server recognize the MobileSharing module:

```cmake
set(QML_IMPORT_PATH "${CMAKE_BINARY_DIR}/MobileSharing/" CACHE STRING "QML Modules import paths" FORCE)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
```

### Setup

#### Setup on iOS (receiving files)

You'll need to add the file formats that your app can accept in the `Info.plist`:

```xml
<key>CFBundleDocumentTypes</key>
<array>
  <dict>
    <key>CFBundleTypeName</key>
    <string>Multimedia</string>
    <key>CFBundleTypeRole</key>
    <string>Viewer</string>
    <key>LSHandlerRank</key>
    <string>Alternate</string>
    <key>LSItemContentTypes</key>
    <array>
      <string>public.image</string>
      <string>public.audio</string>
      <string>public.movie</string>
    </array>
  </dict>
</array>
```

> plist are using tabs, not spaces, so be careful not to copy/past this snippet as is.

### Setup on Android

The module has its own Android Java sources (`io.emeric.mobilesharing`) and FileProvider (`res/xml/filepaths.xml`) files.
These resources are **copied into your own application android source dir** automatically at configure time.

You can add these copied files to your `.gitignore` (especially the java files, but you may choose to customize the FileProvider paths):

```
# MobileSharing module resources (from MobileSharing/android/)
assets/android/src/io/emeric/mobilesharing/QShareActivity.java
assets/android/src/io/emeric/mobilesharing/QShareUtils.java
```

Like in many Qt / Android app, you only need to:

Enable AndroidX in your `gradle.properties` file:
```
android.useAndroidX=true
```

Add these to the dependencies {} section of your `build.gradle` file:
```
implementation 'androidx.appcompat:appcompat:1.6.1'
implementation 'androidx.core:core:1.6.1'
```


#### Setup on Android (receiving files)

To **receive** content, set your launcher activity to the module's `QShareActivity` and add the incoming intent-filters.

`QShareActivity` is what makes reception work (it handles `onNewIntent`/`onActivityResult` and the JNI callbacks) so receiving will **not** work with the stock `QtActivity`.  
If your app already needs a custom activity, have it **extend `io.emeric.mobilesharing.QShareActivity`** instead of `QtActivity`.  

`singleTask` (or `singleInstance`) is **required** so a share reuses the running instance via `onNewIntent` rather than spawning a second one.

Edit your manifest's activity section:

```xml
<activity android:name="io.emeric.mobilesharing.QShareActivity" android:launchMode="singleTask" ... > <!-- Change name and launchMode-->

    <!-- Handle incoming content shared into this app, single + multiple (adjust mimeType to your own needs) -->
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <action android:name="android.intent.action.SEND_MULTIPLE" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="*/*" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="audio/*" />
        <data android:mimeType="video/*" />
        <data android:mimeType="image/*" />
        <data android:scheme="file" />
        <data android:scheme="content" />
    </intent-filter>

</activity>
```

#### Setup on Android (sending files)

To **send** content, add the FileProvider in your manifest application section:

> the `${applicationId}` placeholder resolves the authority at runtime, so there is no needs to change it

```xml
<manifest ...>
  <application ...>

    <!-- Handle outgoing content -->
    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/filepaths" />
    </provider>

  </application>
</manifest>
```

The module copies its own `/res/xml/filepaths.xml` into your Android directory. It is deliberately minimal.  
The provider can only serve files from the module's own MobileSharing subdir, not the rest of your app's storage:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
  FileProvider path for MobileSharing cache directory.
  These paths reference the app's own sandbox directories only.

  Other paths can be used, for instance:
    <files-path name="files" path="." />
    <cache-path name="cache" path="." />
    <external-files-path name="external_files" path="." />
    <external-cache-path name="external_cache" path="." />
-->
<paths>
  <cache-path name="MobileSharing cache folder" path="MobileSharing/" />
</paths>
```


## Using MobileSharing

MobileSharing is a proper CMake QML module, so it is registered automatically by the QML engine.

`MobileSharing` is the single entry point in your application, for both sending and receiving content.

Place **exactly one** instance:

```qml
import MobileSharing

Window {

    MobileSharing {
        id: mobileSharing

        // Outgoing functions
        //mobileSharing.sendText("Hello", "Subject", "https://github.com/emericg/MobileSharing")
        //mobileSharing.sendFile("/path/to/file.pdf", "My file", "application/pdf", 42)

        // Outgoing status
        onShareFinished: (requestCode) => {
            console.log("MobileSharing::onShareFinished(" + requestCode + ")")
        }
        onShareNoAppAvailable: (requestCode) => {
            console.log("MobileSharing::onShareNoAppAvailable(" + requestCode + ")")
        }
        onShareError: (requestCode, message) => {
            console.log("MobileSharing::onShareError(" + requestCode + ") " + message)
        }

        // Incoming file
        onFileReceived: (path) => {
            console.log("MobileSharing::onFileReceived(" + path + ")")
            appWindow.receivedPath = path
            appWindow.scanCache()
        }
    }
}
```

### Sending files

```qml
sendFile(path, title, mimeType, requestId, move = false)
```

- Accepts **any** path.
- If the file already lives in the module's shared cache area (`<cache>/MobileSharing/`, like a file you received or created there), it is shared in place.
- Otherwise (any other location — your `files/`, external storage, ...) the module first **copies** it into its `outgoing/` dir so Android's `FileProvider` can serve it.
  The provider is scoped to `<cache>/MobileSharing/` only, so it can never expose the rest of your app's storage.
- Pass **`move: true`** for throwaway files you generated only to share: the file is
  *moved* into the outgoing dir and the original deleted — no leftover duplicate.

```qml
mobileSharing.sendFile(whateverExportPath, "My export", "application/pdf", 1, true)
```

Where the shared copy lives, and its lifecycle:

|                       | Android                                               | iOS                                                       |
|-----------------------|-------------------------------------------------------|-----------------------------------------------------------|
| Needs a copy/move?    | Yes if the path isn't in `<cache>/MobileSharing/`     | No (any sandbox file is shareable as-is)                  |
| Copy/move lands in    | `<cache>/MobileSharing/outgoing/<name>`               | N/A (`move` is a no-op; delete the file yourself after `onShareFinished` if needed) |
| Lifecycle             | same cache root as incoming: **wiped on next launch** | — |

`viewFile()` gets the same copy-if-needed safety net (no `move` option).

### Receiving files

When another app shares a file into yours, the OS hands you very different things on Android vs iOS.

The module normalizes both into one contract: **`fileReceived(path)`** always gives you a real, readable file your app owns, living in the module's own cache subdir.

What actually happens, and where the file physically lands:

|                                           | Android                                                                                                       | iOS                                                                                             |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| What the OS gives you                     | A `content://` URI — a temporary read *handle*, not a file                                                    | The OS copies the file into `Documents/Inbox/` and gives you a `file://` URL                    |
| What the module does                      | Copies the bytes (via `InputStream`) into its cache subdir                                                    | Moves the Inbox file into its cache subdir and deletes the Inbox original                       |
| Where `path` points after `fileReceived`  | `<cache>/MobileSharing/incoming/<name>` <br> (`/data/user/0/<applicationId>/cache/MobileSharing/incoming/...`)| `<cache>/MobileSharing/incoming/<name>` <br>(`<App>/Library/Caches/MobileSharing/incoming/…`)   |
| Persistence                               | Cache directory: OS-evictable, **wiped by the module on next launch**                                         | Same                                                                                            |
| Backed up to iCloud/iTunes                | N/A                                                                                                           | no (Caches is excluded)                                                                         |

Lifecycle (identical on both platforms):

- The `<cache>/MobileSharing/` sub directory is **session-scoped**: the module wipes it once at startup, so a file received in one run is gone the next. Copy it out if you need it later.
- To reject a file immediately, call `mobileSharing.discardFileReceived(path)` — it deletes the cached copy (and only touches files inside the module's own subdir).


## Caveats

> ACTION_EDIT support (Android only) has been removed


## Inspirations

This project is based on [ekkesSHAREexample](https://github.com/ekke/ekkesSHAREexample) by ekke:
- https://github.com/ekke/ekkesSHAREexample
- https://www.qt.io/blog/2017/12/01/sharing-files-android-ios-qt-app
- https://www.qt.io/blog/2018/01/16/sharing-files-android-ios-qt-app-part-2
- https://www.qt.io/blog/2018/02/06/sharing-files-android-ios-qt-app-part-3
- https://www.qt.io/blog/2018/11/06/sharing-files-android-ios-qt-app-part-4

Also inspired by:
- http://blog.lasconic.com/share-on-ios-and-android-using-qml/
- https://github.com/lasconic/ShareUtils-QML

Also inspired by:
- https://www.androidcode.ninja/android-share-intent-example/
- https://www.calligra.org/blogs/sharing-with-qt-on-android/
- https://stackoverflow.com/questions/7156932/open-file-in-another-app
- http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
- https://stackoverflow.com/questions/5734678/custom-filtering-of-intent-chooser-based-on-installed-android-package-name


## License

This project is licensed under the [MIT license](LICENSE.md).

> Copyright (c) 2017 Ekkehard Gentz (ekke)

> Copyright (c) 2026 Emeric Grange <emeric.grange@gmail.com>

# MobileSharing

A tool to interact with the "sharing" feature found on Android and iOS. Works with Qt5 and Qt6.

## Quick start

### Build

Copy the MobileSharing directory into your project, then include the library files with
either the `MobileSharing.pro` QMake project file or the `CMakeLists.txt` CMake project file.

```qmake
include(src/thirdparty/MobileSharing/MobileSharing.pri)
```

```cmake
add_subdirectory(src/thirdparty/MobileSharing)
target_link_libraries(${PROJECT_NAME} MobileSharing::MobileSharing)
```

### Setup on iOS

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

### Setup on Android

Sharing files on Android in not trivial. Many steps are needed.

Add this line to the dependencies {} section of `build.gradle` file:
```
implementation 'androidx.appcompat:appcompat:1.3.0'
implementation 'androidx.core:core:1.3.0'
```

And add this line in `gradle.properties` file:
```
android.useAndroidX=true
```

Add these files to your project file:
```
OTHER_FILES += $${PWD}/src/com/emeric/qmlapptemplate/QShareActivity.java
               $${PWD}/src/com/emeric/utils/QShareUtils.java \
               $${PWD}/src/com/emeric/utils/QSharePathResolver.java
```

Edit the code and rename these to match your project name:
```
com/emeric/utils
com.emeric.qmlapptemplate
com_emeric_qmlapptemplate
```

Then edit the manifest to handle incoming and/or outgoing files:
```xml
<!-- Handle incoming urls -->
<intent-filter>
    <action android:name="android.intent.action.SEND"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="*/*"/>
</intent-filter>
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="audio/*"/>
    <data android:mimeType="video/*"/>
    <data android:mimeType="image/*"/>
    <data android:scheme="file"/>
    <data android:scheme="content"/>
</intent-filter>
```

```xml
<!-- Handle outgoing urls -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="com.emeric.qmlapptemplate.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/filepaths"/>
</provider>
```

Then add a `/res/xml/filepaths.xml` in you Android directory:
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path
        name="external"
        path="." />
    <external-files-path
        name="external_files"
        path="." />
    <cache-path
        name="cache"
        path="." />
    <external-cache-path
        name="external_cache"
        path="." />
    <files-path
        name="files"
        path="." />
    <files-path
        name="export"
        path="export/" />
</paths>
```

### Register

Registering the QML type in C++ in your main.cpp file:

```cpp
#include <MobileSharing>

int main(int argc, char *argv[])
{
    SharingApplication app(argc, argv);

    MobileSharing::registerQML();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```

### Usage

> TODO

## License

This project is licensed under the MIT license, see LICENSE file for details.

> Copyright (c) 2017 Ekkehard Gentz (ekke)  

> Copyright (c) 2020 Emeric Grange (emeric.grange@gmail.com)  

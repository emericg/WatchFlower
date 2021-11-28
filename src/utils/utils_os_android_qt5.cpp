/*!
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
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
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2019
 */

#include "utils_os_android.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QtAndroidExtras>
#include <QAndroidJniObject>
#include <QProcess>
#endif
#include <QDebug>

/* ************************************************************************** */

bool android_check_storage_permissions()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    QtAndroid::PermissionResult w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");

    if (r == QtAndroid::PermissionResult::Denied || w == QtAndroid::PermissionResult::Denied)
    {
        status = false;
    }

#endif // Q_OS_ANDROID

    return status;
}

bool android_check_storage_read_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    status = (r == QtAndroid::PermissionResult::Granted);
#endif

    return status;
}

bool android_check_storage_write_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID
    QtAndroid::PermissionResult w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    status = (w == QtAndroid::PermissionResult::Granted);
#endif

    return status;
}

bool android_ask_storage_read_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    if (r == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.READ_EXTERNAL_STORAGE");
        r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
        if (r == QtAndroid::PermissionResult::Denied)
        {
            qDebug() << "STORAGE READ PERMISSION DENIED";
            status = false;
        }
    }

#endif // Q_OS_ANDROID

    return status;
}

bool android_ask_storage_write_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    if (w == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE");
        w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if (w == QtAndroid::PermissionResult::Denied)
        {
            qDebug() << "STORAGE WRITE PERMISSION DENIED";
            status = false;
        }
    }

#endif // Q_OS_ANDROID

    return status;
}

bool android_ask_storage_permissions()
{
    return (android_ask_storage_read_permission() && android_ask_storage_write_permission());
}

/* ************************************************************************** */

bool android_check_location_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");

    if (loc == QtAndroid::PermissionResult::Denied)
    {
        status = false;
    }

#endif // Q_OS_ANDROID

    return status;
}

bool android_ask_location_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    if (loc == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.ACCESS_FINE_LOCATION");
        loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");
        if (loc == QtAndroid::PermissionResult::Denied)
        {
            qDebug() << "LOCATION READ PERMISSION DENIED";
            status = false;
        }
    }

#endif // Q_OS_ANDROID

    return status;
}

/* ************************************************************************** */

bool android_check_camera_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult cam = QtAndroid::checkPermission("android.permission.CAMERA");

    if (cam == QtAndroid::PermissionResult::Denied)
    {
        status = false;
    }

#endif // Q_OS_ANDROID

    return status;
}

bool android_ask_camera_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult cam = QtAndroid::checkPermission("android.permission.CAMERA");
    if (cam == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.CAMERA");
        cam = QtAndroid::checkPermission("android.permission.CAMERA");
        if (cam == QtAndroid::PermissionResult::Denied)
        {
            qDebug() << "CAMERA PERMISSION DENIED";
            status = false;
        }
    }

#endif // Q_OS_ANDROID

    return status;
}

/* ************************************************************************** */

bool android_check_phonestate_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult ps = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
    if (ps == QtAndroid::PermissionResult::Denied)
    {
        status = false;
    }

#endif // Q_OS_ANDROID

    return status;
}

bool android_ask_phonestate_permission()
{
    bool status = true;

#ifdef Q_OS_ANDROID

    QtAndroid::PermissionResult ps = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
    if (ps == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.READ_PHONE_STATE");
        ps = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
        if (ps == QtAndroid::PermissionResult::Denied)
        {
            qDebug() << "READ_PHONE_STATE PERMISSION DENIED";
            status = false;
        }
    }

#endif // Q_OS_ANDROID

    return status;
}

/* ************************************************************************** */

QStringList android_get_storages_by_api()
{
    QStringList storages;

#ifdef Q_OS_ANDROID

    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod(
                                      "org/qtproject/qt5/android/QtNative",
                                      "activity", "()Landroid/app/Activity;");

    QAndroidJniObject dirs = activity.callObjectMethod("getExternalFilesDirs",
                                                       "(Ljava/lang/String;)[Ljava/io/File;",
                                                       NULL);
    if (dirs.isValid())
    {
        QAndroidJniEnvironment env;
        jsize l = env->GetArrayLength(dirs.object<jarray>());
        for (int i = 0; i < l; i++)
        {
            QAndroidJniObject dir = env->GetObjectArrayElement(dirs.object<jobjectArray>(), i);
            QString storage = dir.toString();

            storage.truncate(storage.indexOf("/Android/data"));
            if (!storage.isEmpty())
                storages += storage;
        }
    }

    //qDebug() << "> android_get_storages_by_api()" << storages;

#endif // Q_OS_ANDROID

    return storages;
}

QStringList android_get_storages_by_env()
{
    QStringList storages;

#ifdef Q_OS_ANDROID

    QStringList systemEnvironment = QProcess::systemEnvironment();
    for (auto s: systemEnvironment)
    {
        if (s.contains("EXTERNAL_STORAGE="))
        {
            storages += s.mid(17, -1);
        }

        if (s.contains("SECONDARY_STORAGE="))
        {
            storages += s.mid(17, -1);
        }
    }

    //qDebug() << "> android_get_storages_by_env()" << storages;

#endif // Q_OS_ANDROID

    return storages;
}

QString android_get_external_storage()
{
    QString external_storage;

#ifdef Q_OS_ANDROID

    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment",
                                                                           "getExternalStorageDirectory",
                                                                           "()Ljava/io/File;");
    QAndroidJniObject mediaPath = mediaDir.callObjectMethod("getAbsolutePath", "()Ljava/lang/String;");
    external_storage = mediaPath.toString();

    //qDebug() << "> android_get_external_storage()" << external_storage;

#endif // Q_OS_ANDROID

    return external_storage;
}

/* ************************************************************************** */

QString android_get_device_model()
{
    QString device_model;

#ifdef Q_OS_ANDROID

    QAndroidJniObject manufacturerField = QAndroidJniObject::getStaticObjectField<jstring>("android/os/Build", "MANUFACTURER");
    QAndroidJniObject modelField = QAndroidJniObject::getStaticObjectField<jstring>("android/os/Build", "MODEL");
    device_model = manufacturerField.toString() + " " + modelField.toString();

    //qDebug() << "> android_get_device_model()" << device_model;

#endif // Q_OS_ANDROID

    return device_model;
}

QString android_get_device_serial()
{
    QString device_serial;

#ifdef Q_OS_ANDROID
/*
    // Deprecated method
    QAndroidJniObject serialField = QAndroidJniObject::getStaticObjectField<jstring>("android/os/Build", "SERIAL");
    device_serial = serialField.toString();
*/
    QAndroidJniObject serialField = QAndroidJniObject::callStaticObjectMethod("android/os/Build",
                                                                              "getSerial",
                                                                              "()Ljava/lang/String;");
    device_serial = serialField.toString();

    //qDebug() << "> android_get_device_serial()" << device_serial;

#endif // Q_OS_ANDROID

    return device_serial;
}

/* ************************************************************************** */

void android_screen_keep_on(bool on)
{
#ifdef Q_OS_ANDROID

    //qDebug() << "> android_keep_screen_on(" << on << ")";

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject activity = QtAndroid::androidActivity();
        if (activity.isValid())
        {
            QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
            if (window.isValid())
            {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on)
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                else
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
            }
        }
        QAndroidJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });

#else
    Q_UNUSED(on)
#endif // Q_OS_ANDROID
}

/* ************************************************************************** */
/*
    enum ScreenOrientation_android {
        SCREEN_ORIENTATION_UNSPECIFIED = -1,
        SCREEN_ORIENTATION_LANDSCAPE = 0,
        SCREEN_ORIENTATION_PORTRAIT = 1,
        SCREEN_ORIENTATION_SENSOR_LANDSCAPE = 6,
        SCREEN_ORIENTATION_SENSOR_PORTRAIT = 7,
        SCREEN_ORIENTATION_REVERSE_LANDSCAPE = 8,
        SCREEN_ORIENTATION_REVERSE_PORTRAIT = 9,
    };
*/

void android_screen_lock_orientation(int orientation)
{
#ifdef Q_OS_ANDROID

    //qDebug() << "> android_screen_lock_orientation(" << orientation << ")";

    int value = 1;
    if (orientation != 0) value = 0;

    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }

#else
    Q_UNUSED(orientation)
#endif // Q_OS_ANDROID
}

void android_screen_lock_orientation(int orientation, bool autoRotate)
{
#ifdef Q_OS_ANDROID

    //qDebug() << "> android_screen_lock_orientation(" << orientation << "-" << autoRotate << ")";

    int value = -1;

    if (orientation)
    {
        if (autoRotate)
        {
            if (orientation == 1 || orientation == 2) value = 7;
            else if (orientation == 4 || orientation == 8) value = 6;
        }
        else
        {
            if (orientation == 1) value = 1;
            else if (orientation == 2) value = 9;
            else if (orientation == 4) value = 0;
            else if (orientation == 8) value = 8;
        }
    }

    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }

#else
    Q_UNUSED(orientation)
    Q_UNUSED(autoRotate)
#endif // Q_OS_ANDROID
}

/* ************************************************************************** */

void android_vibrate(int milliseconds)
{
#ifdef Q_OS_ANDROID

    if (milliseconds > 100) milliseconds = 100;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject activity = QtAndroid::androidActivity();
        if (activity.isValid())
        {
            QAndroidJniObject appctx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
            if (appctx.isValid())
            {
                QAndroidJniObject vibroString = QAndroidJniObject::fromString("vibrator");
                QAndroidJniObject vibratorService = appctx.callObjectMethod("getSystemService",
                                                                            "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                            vibroString.object<jstring>());
                if (vibratorService.callMethod<jboolean>("hasVibrator", "()Z"))
                {
                    jlong ms = milliseconds;
                    vibratorService.callMethod<void>("vibrate", "(J)V", ms);
                }
            }
        }
    });

#else
    Q_UNUSED(milliseconds)
#endif // Q_OS_ANDROID
}

/* ************************************************************************** */

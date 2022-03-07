/*!
 * COPYRIGHT (C) 2022 Emeric Grange - All Rights Reserved
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

#if defined(Q_OS_ANDROID)

#include <QtCore/private/qandroidextras_p.h>
#include <QCoreApplication>
#include <QJniEnvironment>
#include <QJniObject>
#include <QDebug>

/* ************************************************************************** */

bool UtilsAndroid::checkPermissions_storage()
{
    QFuture<QtAndroidPrivate::PermissionResult> r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    QFuture<QtAndroidPrivate::PermissionResult> w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");

    r.waitForFinished();
    w.waitForFinished();

    return (r.result() == QtAndroidPrivate::PermissionResult::Authorized && w.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::checkPermission_storage_read()
{
    QFuture<QtAndroidPrivate::PermissionResult> r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    r.waitForFinished();

    return (r.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::checkPermission_storage_write()
{
    QFuture<QtAndroidPrivate::PermissionResult> w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    w.waitForFinished();

    return (w.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermissions_storage()
{
    return (UtilsAndroid::getPermission_storage_read() && UtilsAndroid::getPermission_storage_write());
}

bool UtilsAndroid::getPermission_storage_read()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    r.waitForFinished();

    if (r.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.READ_EXTERNAL_STORAGE");

        r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
        r.waitForFinished();

        if (r.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "STORAGE READ PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::getPermission_storage_write()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    w.waitForFinished();

    if (w.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.WRITE_EXTERNAL_STORAGE");

        w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        w.waitForFinished();

        if (w.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "STORAGE WRITE PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_camera()
{
    QFuture<QtAndroidPrivate::PermissionResult> cam = QtAndroidPrivate::checkPermission("android.permission.CAMERA");
    cam.waitForFinished();
    return (cam.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_camera()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> cam = QtAndroidPrivate::checkPermission("android.permission.CAMERA");
    cam.waitForFinished();
    if (cam.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.CAMERA");
        cam = QtAndroidPrivate::checkPermission("android.permission.CAMERA");
        cam.waitForFinished();
        if (cam.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "CAMERA PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_location()
{
    QFuture<QtAndroidPrivate::PermissionResult> loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    loc.waitForFinished();
    return (loc.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_location()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    loc.waitForFinished();
    if (loc.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.ACCESS_FINE_LOCATION");
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
        loc.waitForFinished();
        if (loc.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "LOCATION READ PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::checkPermission_location_ble()
{
    QFuture<QtAndroidPrivate::PermissionResult> loc;

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    else
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_COARSE_LOCATION");

    return (loc.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_location_ble()
{
    bool status = true;

    if (!UtilsAndroid::checkPermission_location_ble())
    {
        if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
            QtAndroidPrivate::requestPermission("android.permission.ACCESS_FINE_LOCATION");
        else
            QtAndroidPrivate::requestPermission("android.permission.ACCESS_COARSE_LOCATION");

        if (!UtilsAndroid::checkPermission_location_ble())
        {
            qWarning() << "LOCATION READ PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_phonestate()
{
    QFuture<QtAndroidPrivate::PermissionResult> ps = QtAndroidPrivate::checkPermission("android.permission.READ_PHONE_STATE");
    ps.waitForFinished();
    return (ps.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_phonestate()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> ps = QtAndroidPrivate::checkPermission("android.permission.READ_PHONE_STATE");
    ps.waitForFinished();
    if (ps.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.READ_PHONE_STATE");
        ps = QtAndroidPrivate::checkPermission("android.permission.READ_PHONE_STATE");
        ps.waitForFinished();
        if (ps.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "READ_PHONE_STATE PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

QString UtilsAndroid::getAppInternalStorage()
{
    return QString();
}

QString UtilsAndroid::getAppExternalStorage()
{
    QString storage;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject dir = QJniObject::fromString(QString(""));
        QJniObject path = activity.callObjectMethod("getExternalFilesDir",
                                                    "(Ljava/lang/String;)Ljava/io/File;",
                                                    dir.object());
        storage = path.toString();
    }

    return storage;
}

QStringList UtilsAndroid::get_storages_by_api()
{
    return QStringList(); // DEPRECATED
}

QString UtilsAndroid::get_external_storage()
{
    return QString(); // DEPRECATED
}

/* ************************************************************************** */

QString UtilsAndroid::getDeviceModel()
{
    QJniObject manufacturerField = QJniObject::getStaticObjectField<jstring>("android/os/Build", "MANUFACTURER");
    QJniObject modelField = QJniObject::getStaticObjectField<jstring>("android/os/Build", "MODEL");

    QString device_model = manufacturerField.toString() + " " + modelField.toString();
    //qDebug() << "> getDeviceModel()" << device_model;
    return device_model;
}

QString UtilsAndroid::getDeviceSerial()
{
    QString device_serial;

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
    {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        QJniObject appctx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
        QJniObject contentR = appctx.callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");

        QJniObject aidString = QJniObject::fromString("android_id");
        QJniObject aidService = QJniObject::callStaticObjectMethod("android/provider/Settings$Secure","getString",
                                                                   "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;",
                                                                   contentR.object<jobject>(),
                                                                   aidString.object<jstring>());
        device_serial = aidService.toString();
    }
    else
    {
        QJniObject serialField = QJniObject::callStaticObjectMethod("android/os/Build",
                                                                    "getSerial",
                                                                    "()Ljava/lang/String;");
        QString device_serial = serialField.toString();
    }

    //qDebug() << "> getDeviceSerial()" << device_serial;
    return device_serial;
}

/* ************************************************************************** */

void UtilsAndroid::vibrate(int milliseconds)
{
    if (milliseconds > 100) milliseconds = 100;

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            QJniObject appCtx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
            if (appCtx.isValid())
            {
                QJniObject vibratorString = QJniObject::fromString("vibrator");
                QJniObject vibratorService = appCtx.callObjectMethod("getSystemService",
                                                                     "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                     vibratorString.object<jstring>());
                if (vibratorService.callMethod<jboolean>("hasVibrator", "()Z"))
                {
                    jlong ms = milliseconds;
                    vibratorService.callMethod<void>("vibrate", "(J)V", ms);
                }
            }
        }
        QJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });
}

bool UtilsAndroid::isGpsEnabled()
{
    bool status = false;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject appCtx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
        if (appCtx.isValid())
        {
            QJniObject locationString = QJniObject::fromString("location");
            QJniObject locationService = appCtx.callObjectMethod("getSystemService",
                                                                 "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                 locationString.object<jstring>());
            if (locationService.callMethod<jboolean>("isLocationEnabled", "()Z"))
            {
                status = true;
            }
        }
    }

    return status;
}

/* ************************************************************************** */

void UtilsAndroid::screenKeepOn(bool on)
{
    //qDebug() << "> screenKeepOn(" << on << ")";

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
            if (window.isValid())
            {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on)
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                else
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
            }
        }
        QJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });
}

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

void UtilsAndroid::screenLockOrientation(int orientation)
{
    //qDebug() << "> screenLockOrientation(" << orientation << ")";

    int value = 1;
    if (orientation != 0) value = 0;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }
}

void UtilsAndroid::screenLockOrientation(int orientation, bool autoRotate)
{
    //qDebug() << "> screenLockOrientation(" << orientation << "-" << autoRotate << ")";

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

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }
}

/* ************************************************************************** */
#endif // Q_OS_ANDROID

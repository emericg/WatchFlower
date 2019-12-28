/*!
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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

#include "utils_android.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QtAndroidExtras>
#include <QAndroidJniObject>
#include <QProcess>
#endif
#include <QDebug>

/* ************************************************************************** */

bool android_ask_storage_permissions()
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

/* ************************************************************************** */

void android_set_statusbar_color(int color)
{
    Q_UNUSED(color)

#ifdef Q_OS_ANDROID

    QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
/*
    window.callMethod<void>("addFlags", "(I)V", 0x80000000);
    window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
    window.callMethod<void>("setStatusBarColor", "(I)V", color); // Desired statusbar color

    // Note: If you're using white, or some other very bright color as background, the statusbar's text can be made a little darker using the following code:
    QAndroidJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
    decorView.callMethod<void>("setSystemUiVisibility", "(I)V", 0x00002000);

    setWindowFlag(this, WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS, false);
    getWindow().setStatusBarColor(Color.TRANSPARENT);
*/
#endif // Q_OS_ANDROID
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
    device_model =  manufacturerField.toString() + " " + modelField.toString();

    //qDebug() << "> android_get_device_model()" << device_model;

#endif // Q_OS_ANDROID

    return device_model;
}

/* ************************************************************************** */

void android_vibrate()
{
#ifdef Q_OS_ANDROID
/*
    QAndroidJniObject vibvib = QAndroidJniObject::getStaticObjectField("android/os/Vibrator",
                                                                         "vibrate",
                                                                         "(I)V;",
                                                                         1000);
*/

#endif // Q_OS_ANDROID
}

/* ************************************************************************** */

void android_keep_screen_on(bool on)
{
#ifdef Q_OS_ANDROID
/*
    //qDebug() << "> android_keep_screen_on(" << on << ")";

    QtAndroid::runOnAndroidThread([on]{
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
*/
#else
    Q_UNUSED(on)
#endif
}

/* ************************************************************************** */

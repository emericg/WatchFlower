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

#include "utils_app.h"

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
#include "utils_android.h"
#include "utils_ios.h"
#endif

#include <cmath>

#include <QDir>
#include <QSize>

#include <QApplication>
#include <QStandardPaths>
#include <QDesktopServices>

/* ************************************************************************** */

UtilsApp *UtilsApp::instance = nullptr;

UtilsApp *UtilsApp::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsApp();
    }

    return instance;
}

UtilsApp::UtilsApp()
{
    //
}

UtilsApp::~UtilsApp()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

QString UtilsApp::appVersion()
{
    return QString::fromLatin1(APP_VERSION);
}

QString UtilsApp::appBuildDate()
{
    return QString::fromLatin1(__DATE__);
}

QString UtilsApp::appBuildDateTime()
{
    return QString::fromLatin1(__DATE__) + " " + QString::fromLatin1(__TIME__);
}

QString UtilsApp::appBuildMode()
{
#ifdef DEBUG
    return "DEBUG";
#endif

    return "";
}

/* ************************************************************************** */

void UtilsApp::appExit()
{
    QApplication::exit();
}

/* ************************************************************************** */

void UtilsApp::setAppPath(const QString &value)
{
    if (m_appPath != value)
    {
        QDir newpath(value);
        newpath.cdUp();
        m_appPath = newpath.absolutePath();

        // Make sure the path is terminated with a separator.
        if (!m_appPath.endsWith('/')) m_appPath += '/';

        // TODO: use QApplication::applicationDirPath() instead?
    }
}

/* ************************************************************************** */

void UtilsApp::openWith(const QString &path)
{
    QUrl url;

#if defined (Q_OS_ANDROID)
    // Starting from API 24, open will only accept path begining by "content://"

    if (path.startsWith("/"))
    {
        url = "content://" + path;
    }
    else if (path.startsWith("file://"))
    {
        QString  newpath = path;
        newpath = newpath.replace("file://", "content://");
        url = newpath;
    }
    else if (path.startsWith("content://"))
    {
        url = path;
    }

#elif defined (Q_OS_IOS)

    url = QUrl::fromLocalFile(path);

#else // defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)

    url = QUrl::fromLocalFile(path);

#endif

    //qDebug() << "url:" << url;
    QDesktopServices::openUrl(url);
}

/* ************************************************************************** */
/* ************************************************************************** */

QUrl UtilsApp::getStandardPath(const QString &type)
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    android_ask_storage_permissions();
#endif

    QUrl path;
    QStringList paths;

    if (type == "audio")
        paths = QStandardPaths::standardLocations(QStandardPaths::MusicLocation);
    else if (type == "video")
        paths = QStandardPaths::standardLocations(QStandardPaths::MoviesLocation);
    else if (type == "photo")
        paths = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    else
    {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        paths = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
#else
        paths = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
#endif
    }

    if (!paths.isEmpty())
        path = QUrl::fromLocalFile(paths.at(0));

    return path;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool UtilsApp::checkMobileStoragePermissions()
{
#if defined (Q_OS_ANDROID)
    return android_check_storage_permissions();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobileStoragePermissions()
{
#if defined (Q_OS_ANDROID)
    return android_ask_storage_permissions();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::checkMobilePhoneStatePermission()
{
#if defined (Q_OS_ANDROID)
    return android_check_phonestate_permission();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobilePhoneStatePermission()
{
#if defined (Q_OS_ANDROID)
    return android_ask_phonestate_permission();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

/* ************************************************************************** */

QString UtilsApp::getMobileDeviceModel()
{
#if defined (Q_OS_ANDROID)
    return android_get_device_model();
#elif defined(Q_OS_IOS)
    return QString();
#else
    return QString();
#endif
}

QString UtilsApp::getMobileDeviceSerial()
{
#if defined (Q_OS_ANDROID)
    return android_get_device_serial();
#elif defined(Q_OS_IOS)
    return QString();
#else
    return QString();
#endif
}

/* ************************************************************************** */

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)

int UtilsApp::getMobileStorageCount()
{
    QStringList storages = android_get_storages_by_api();
    return storages.size();
}

QString UtilsApp::getMobileStorageInternal()
{
    QString internal;
    QStringList storages = android_get_storages_by_api();

    if (storages.size() > 0)
        internal = storages.at(0);

    return internal;
}

QString UtilsApp::getMobileStorageExternal(int index)
{
    QStringList storages = android_get_storages_by_api();

    if (storages.size() > index)
        return storages.at(1 + index);

    return QString();
}

QStringList UtilsApp::getMobileStorageExternals()
{
    QStringList storages = android_get_storages_by_api();

    if (storages.size() > 0)
        storages.removeFirst();

    return storages;
}

#endif // defined(Q_OS_ANDROID) || defined(Q_OS_IOS)

/* ************************************************************************** */

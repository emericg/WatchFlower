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

#ifndef UTILS_ANDROID_H
#define UTILS_ANDROID_H
/* ************************************************************************** */

#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief android_ask_storage_permissions
 * \return True if R/W permissions on main storage have been obtained.
 */
bool android_ask_storage_permissions();

/* ************************************************************************** */

/*!
 * \brief android_set_statusbar_color
 * \param color: 32b RGBA color.
 *
 * \note: WIP, only make the app segfault right now.
 */
void android_set_statusbar_color(int color);

/* ************************************************************************** */

/*!
 * \brief android_get_storages_by_api
 * \return The path to the external storage.
 *
 * Search for storage devices using native API, using:
 * - https://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String)
 */
QStringList android_get_storages_by_api();

/*!
 * \brief android_get_storages_by_env
 * \return The path to the external storage.
 *
 * Search for storage devices in the Android specific environment variables.
 */
QStringList android_get_storages_by_env();

/*!
 * \brief android_get_external_storage
 * \return The path to the external storage.
 *
 * Search for storage devices using native API, using:
 * - https://developer.android.com/reference/android/os/Environment#getExternalStorageDirectory()
 *
 * It might get complicated:
 * - https://source.android.com/devices/storage/
 */
QString android_get_external_storage();

/* ************************************************************************** */

/*!
 * \brief android_get_device_model
 * \return The device manufacturer + model.
 *
 * - https://developer.android.com/reference/android/os/Build.html
 */
QString android_get_device_model();

/* ************************************************************************** */

/*!
 * \brief android_keep_screen_on
 */
void android_keep_screen_on(bool on);

/* ************************************************************************** */

/*!
 * \brief android_vibrate
 */
void android_vibrate();

/* ************************************************************************** */
#endif // UTILS_ANDROID_H

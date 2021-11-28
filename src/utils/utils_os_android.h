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

#ifndef UTILS_OS_ANDROID_H
#define UTILS_OS_ANDROID_H
/* ************************************************************************** */

#include <QtGlobal>
#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief android_check_storage_permissions
 * \return True if R/W permissions on main storage have been previously obtained.
 */
bool android_check_storage_permissions();
bool android_check_storage_read_permission();
bool android_check_storage_write_permission();

/*!
 * \brief android_ask_storage_permissions
 * \return True if R/W permissions on main storage have been explicitly obtained.
 */
bool android_ask_storage_permissions();
bool android_ask_storage_read_permission();
bool android_ask_storage_write_permission();

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
 * \brief android_ask_phonestate_permission
 * \return True if READ_PHONE_STATE permission has been previously obtained.
 */
bool android_check_phonestate_permission();

/*!
 * \brief android_ask_phonestate_permission
 * \return True if READ_PHONE_STATE permission has been explicitly obtained.
 */
bool android_ask_phonestate_permission();

/*!
 * \brief android_get_device_model
 * \return The device manufacturer + model.
 *
 * - https://developer.android.com/reference/android/os/Build.html
 */
QString android_get_device_model();

/*!
 * \brief android_get_device_serial
 * \return The device serial number.
 *
 * Need READ_PHONE_STATE permission.
 * Only work before Android 10 (API < 29).
 *
 * - https://developer.android.com/reference/android/os/Build#getSerial()
 */
QString android_get_device_serial();

/* ************************************************************************** */

/*!
 * \brief android_check_location_permission
 * \return True if ACCESS_FINE_LOCATION permission has been previously obtained.
 */
bool android_check_location_permission();

/*!
 * \brief android_ask_location_permission
 * \return True if ACCESS_FINE_LOCATION permission has been explicitly obtained.
 */
bool android_ask_location_permission();

/* ************************************************************************** */

/*!
 * \brief android_check_camera_permission
 * \return True if CAMERA permission has been previously obtained.
 */
bool android_check_camera_permission();

/*!
 * \brief android_ask_camera_permission
 * \return True if CAMERA permission has been explicitly obtained.
 */
bool android_ask_camera_permission();

/* ************************************************************************** */

/*!
 * \brief android_screen_keep_on
 * \param on: screen on or off.
 */
void android_screen_keep_on(bool on);

/* ************************************************************************** */

/*!
 * \brief android_screen_lock_orientation
 * \param orientation: 0 is for landscape, 1 for portrait.
 *
 * Lock screen orientation, using:
 * - https://developer.android.com/reference/android/app/Activity.html#setRequestedOrientation(int)
 *
 * You can achieve similar functionality through application manifest:
 * - https://developer.android.com/guide/topics/manifest/activity-element.html#screen
 */
void android_screen_lock_orientation(int orientation);

/*!
 * \brief android_screen_lock_orientation
 * \param orientation: see ScreenOrientation enum.
 * \param autoRotate: false to disable auto-rotation completely, true to let some degree of auto-rotation.
 */
void android_screen_lock_orientation(int orientation, bool autoRotate);

/* ************************************************************************** */

/*!
 * \brief android_vibrate
 * \param milliseconds: vibration duration.
 *
 * Need VIBRATE permission.
 *
 * - 25 is a small 'keyboard like' vibration
 * - 100 is a regular 'notification' vibration
 */
void android_vibrate(int milliseconds);

/* ************************************************************************** */
#endif // UTILS_OS_ANDROID_H

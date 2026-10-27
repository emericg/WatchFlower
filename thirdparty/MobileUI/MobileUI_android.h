/*!
 * Copyright (c) 2016 J-P Nurmi
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

#ifndef MOBILEUI_ANDROID_H
#define MOBILEUI_ANDROID_H
/* ************************************************************************** */

#include "MobileUI_private.h"

#include <QJniObject>


/* ************************************************************************** */

/*!
 * \brief Android backend for MobileUI (JNI to the activity Window, WindowInsets and system services).
 *
 * Implements the PlatformMobileUI interface. Most calls are dispatched to the Android main thread,
 * and reads deliver their result asynchronously through signals.
 * The Qt thread never waits for the Android main thread, as it may itself be waiting on the Qt thread.
 */
class AndroidMobileUI : public PlatformMobileUI
{
    Q_OBJECT

    QJniObject m_vibrator;          //!< Cached Vibrator service, resolved on first use.
    QJniObject m_cameraManager;     //!< Cached CameraManager service, resolved on first torch use.
    QJniObject m_torchCameraId;     //!< Cached id of the camera driving the torch, resolved on first torch use.

public:
    explicit AndroidMobileUI(QObject *parent = nullptr);

    void refreshDeviceTheme() override;

    bool getSystemBarColorsSupported() const override;

    void setColor_statusbar(const QColor &color) override;
    void setTheme_statusbar(const MobileUI::Theme theme) override;

    void setColor_navbar(const QColor &color) override;
    void setTheme_navbar(const MobileUI::Theme theme) override;

    void refreshSafeAreaMetrics() override;
    void refreshKeyboardHeight() override;

    void refreshScreenBrightness() override;
    void setScreenBrightness(const int value) override;

    void setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation) override;

    void setScreenAlwaysOn(const bool on) override;

    void setScreenSecure(const bool on) override;

    void setScreenHighRefreshRate(const bool value) override;

    void triggerHapticFeedback(const MobileUI::HapticFeedback type) override;

    bool setTorch(const bool on) override;

    void backToHomeScreen() override;
};

/* ************************************************************************** */
#endif // MOBILEUI_ANDROID_H

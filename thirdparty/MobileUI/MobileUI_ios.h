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

#ifndef MOBILEUI_IOS_H
#define MOBILEUI_IOS_H
/* ************************************************************************** */

#include "MobileUI_private.h"

/* ************************************************************************** */

/*!
 * \brief iOS backend for MobileUI (UIKit / AVFoundation).
 *
 * Implements the PlatformMobileUI interface, every call runs synchronously on the main thread.
 * iOS has no separate status bar background color, only the icon style (light/dark content)
 * can be controlled, through setTheme_statusbar(). It has no navigation bar either,
 * so the system bar colors and the navigation bar theme are left to the base class no-ops.
 */
class IosMobileUI : public PlatformMobileUI
{
    Q_OBJECT

    double m_brightnessApp = -1.0;      //!< Brightness set by the application (0.0 to 1.0), or -1 when unset.
    double m_brightnessSystem = -1.0;   //!< System brightness saved before the application changed it, or -1.

    /*!
     * \brief Restore the system brightness while the application is not active, and re-apply its own once active again.
     * \param state: the new application state.
     *
     * iOS brightness is system wide, and an application change outlives the application until the device is locked.
     */
    void applyBrightnessForState(Qt::ApplicationState state);

public:
    explicit IosMobileUI(QObject *parent = nullptr);

    void refreshDeviceTheme() override;

    void setTheme_statusbar(const MobileUI::Theme theme) override;

    void refreshSafeAreaMetrics() override;

    void refreshScreenBrightness() override;
    void setScreenBrightness(const int value) override;

    void setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation) override;

    void setScreenAlwaysOn(const bool on) override;

    void setScreenSecure(const bool on) override;

    void setScreenHighRefreshRate(const bool value) override;

    void triggerHapticFeedback(const MobileUI::HapticFeedback type) override;

    int getTorch() const override;
    bool setTorch(const bool on) override;
};

/* ************************************************************************** */
#endif // MOBILEUI_IOS_H

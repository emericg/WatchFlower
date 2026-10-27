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

#ifndef MOBILEUI_PRIVATE_H
#define MOBILEUI_PRIVATE_H
/* ************************************************************************** */

#include "MobileUI.h"

#include <QObject>
#include <QColor>
#include <QPointer>
#include <QWindow>
#include <QGuiApplication>
#include <QStyleHints>

/* ************************************************************************** */

/*!
 * \brief Internal platform backend behind MobileUI.
 *
 * This is the module's private interface: the base class provides a dummy
 * default implementation, used as is on desktop platforms.
 */
class PlatformMobileUI : public QObject
{
    Q_OBJECT

Q_SIGNALS:
    /*!
     * \brief Result of a refreshSafeAreaMetrics() request.
     * \param metrics: the system bar sizes and safe area insets.
     *
     * May be emitted from a native thread, the connection to MobileUI is then queued.
     */
    void safeAreaMetricsUpdated(const MobileUI::SafeAreaMetrics &metrics);

    /*!
     * \brief Result of a refreshKeyboardHeight() request.
     * \param height: the keyboard height (in device-independent pixels), or -1 if the backend can't read it.
     *
     * May be emitted from a native thread, the connection to MobileUI is then queued.
     */
    void keyboardHeightUpdated(int height);

    /*!
     * \brief Result of a refreshDeviceTheme() request.
     * \param theme: MobileUI::Light or MobileUI::Dark.
     *
     * May be emitted from a native thread, the connection to MobileUI is then queued.
     */
    void deviceThemeUpdated(MobileUI::Theme theme);

    /*!
     * \brief Result of a refreshScreenBrightness() request.
     * \param value: the OS wide screen brightness, from 0 to 100.
     *
     * May be emitted from a native thread, the connection to MobileUI is then queued.
     */
    void screenBrightnessUpdated(int value);

public:
    explicit PlatformMobileUI(QObject *parent = nullptr) : QObject(parent) { }
    ~PlatformMobileUI() override = default;

    //! Set the application window MobileUI is tracking (see MobileUI::refreshWindow()).
    void setWindow(QWindow *window) { m_window = window; }

    //! Get the application window MobileUI is tracking, or nullptr.
    QWindow *getWindow() const { return m_window; }

    /*!
     * \brief Read the device theme.
     *
     * The result is delivered through deviceThemeUpdated(),
     * which is not emitted when the theme could not be read (MobileUI keeps its previous value).
     * Same threading rules as refreshSafeAreaMetrics().
     *
     * The default implementation reads the color scheme reported by Qt (QStyleHints::colorScheme()).
     * It reflects any application override set through QStyleHints::setColorScheme().
     */
    virtual void refreshDeviceTheme()
    {
        const QStyleHints *hints = QGuiApplication::styleHints();
        if (!hints) return;

        switch (hints->colorScheme())
        {
        case Qt::ColorScheme::Dark: Q_EMIT deviceThemeUpdated(MobileUI::Dark); break;
        case Qt::ColorScheme::Light: Q_EMIT deviceThemeUpdated(MobileUI::Light); break;
        default: break;
        }
    }

    //! Tell whether the system bar background colors can be set (see MobileUI::getSystemBarColorsSupported()).
    virtual bool getSystemBarColorsSupported() const { return false; }

    virtual void setColor_statusbar(const QColor &color) { Q_UNUSED(color) }
    virtual void setTheme_statusbar(const MobileUI::Theme theme) { Q_UNUSED(theme) }

    virtual void setColor_navbar(const QColor &color) { Q_UNUSED(color) }
    virtual void setTheme_navbar(const MobileUI::Theme theme) { Q_UNUSED(theme) }

    /*!
     * \brief Read all system bar sizes and safe area insets in a single pass.
     *
     * The result is delivered through safeAreaMetricsUpdated(),
     * which is not emitted when the metrics could not be read (MobileUI keeps its previous values).
     *
     * A single pass means a single backend round-trip,
     * which matters for the Android backend and its Android main thread usage.
     * The Android backend never waits for the Android main thread, as it may itself be waiting
     * on the Qt thread (ex: an input method query), the signal is then emitted asynchronously.
     */
    virtual void refreshSafeAreaMetrics() { Q_EMIT safeAreaMetricsUpdated(MobileUI::SafeAreaMetrics()); }

    /*!
     * \brief Read the on-screen keyboard height.
     *
     * The result is delivered through keyboardHeightUpdated().
     * Same threading rules as refreshSafeAreaMetrics().
     */
    virtual void refreshKeyboardHeight() { Q_EMIT keyboardHeightUpdated(-1); }

    /*!
     * \brief Read the OS wide screen brightness (ignoring any brightness set by the application).
     *
     * The result is delivered through screenBrightnessUpdated(),
     * which is not emitted when the brightness could not be read (MobileUI keeps its previous value).
     * Same threading rules as refreshSafeAreaMetrics().
     */
    virtual void refreshScreenBrightness() { }

    //! Set the screen brightness, from 0 to 100, or -1 to release the override (the value is sanitized by MobileUI).
    virtual void setScreenBrightness(const int value) { Q_UNUSED(value) }

    virtual void setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation) { Q_UNUSED(orientation) }

    virtual void setScreenAlwaysOn(const bool on) { Q_UNUSED(on) }

    virtual void setScreenSecure(const bool on) { Q_UNUSED(on) }

    virtual void setScreenHighRefreshRate(const bool value) { Q_UNUSED(value) }

    virtual void triggerHapticFeedback(const MobileUI::HapticFeedback type) { Q_UNUSED(type) }

    /*!
     * \brief Read the torch state.
     * \return 1 if the torch is on, 0 if it is off, or -1 when it can't be read.
     */
    virtual int getTorch() const { return -1; }
    virtual bool setTorch(const bool on) { Q_UNUSED(on) return false; }

    virtual void backToHomeScreen() { }

protected:
    /*!
     * \brief The application window MobileUI is tracking.
     *
     * Only accessed from the GUI thread.
     * Backends must read what they need from it before dispatching work to a native thread.
     */
    QPointer<QWindow> m_window;
};

/* ************************************************************************** */
#endif // MOBILEUI_PRIVATE_H

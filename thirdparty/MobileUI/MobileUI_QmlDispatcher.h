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

#ifndef MOBILEUI_QML_DISPATCHER_H
#define MOBILEUI_QML_DISPATCHER_H
/* ************************************************************************** */

#include "MobileUI.h"

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QColor>

/* ************************************************************************** */

/*!
 * \brief Instantiable QML helper element forwarding writable settings to the MobileUI singleton.
 *
 * MobileUI is a QML singleton, so its settings are normally applied imperatively
 * (MobileUI.statusbarColor = ...) or through Binding elements. This element lets
 * you instead declare and bind your system bar / screen settings in one place,
 * mimicking the pre-singleton API:
 *
 * \code
 * MobileUI_dispatcher {
 *     statusbarColor: "white"
 *     statusbarTheme: MobileUI.Light
 *     navbarColor: "white"
 *     navbarTheme: MobileUI.Light
 * }
 * \endcode
 *
 * It is a thin proxy: every property reads from and writes to the shared MobileUI
 * singleton and holds no state of its own. It only exposes the writable settings
 * (read-only values like safe areas or the device theme stay on the singleton).
 *
 * Declare a single instance, or face troubles (the last instance will win)...
 */
class MobileUI_QmlDispatcher : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MobileUI_dispatcher)

    Q_PROPERTY(QColor statusbarColor READ statusbarColor WRITE setStatusbarColor NOTIFY statusbarColorChanged)
    Q_PROPERTY(QColor statusbarContentColor READ statusbarContentColor WRITE setStatusbarContentColor NOTIFY statusbarContentColorChanged)
    Q_PROPERTY(MobileUI::Theme statusbarTheme READ statusbarTheme WRITE setStatusbarTheme NOTIFY statusbarThemeChanged)

    Q_PROPERTY(QColor navbarColor READ navbarColor WRITE setNavbarColor NOTIFY navbarColorChanged)
    Q_PROPERTY(QColor navbarContentColor READ navbarContentColor WRITE setNavbarContentColor NOTIFY navbarContentColorChanged)
    Q_PROPERTY(MobileUI::Theme navbarTheme READ navbarTheme WRITE setNavbarTheme NOTIFY navbarThemeChanged)

    Q_PROPERTY(MobileUI::ScreenLockOrientation screenLockOrientation READ screenLockOrientation WRITE setScreenLockOrientation NOTIFY screenLockOrientationChanged)
    Q_PROPERTY(int screenBrightness READ screenBrightness WRITE setScreenBrightness NOTIFY screenBrightnessChanged)
    Q_PROPERTY(bool screenAlwaysOn READ screenAlwaysOn WRITE setScreenAlwaysOn NOTIFY screenAlwaysOnChanged)
    Q_PROPERTY(bool screenSecure READ screenSecure WRITE setScreenSecure NOTIFY screenSecureChanged)
    Q_PROPERTY(bool screenHighRefreshRate READ screenHighRefreshRate WRITE setScreenHighRefreshRate NOTIFY screenHighRefreshRateChanged)

    Q_PROPERTY(bool torchEnabled READ torchEnabled WRITE setTorchEnabled NOTIFY torchEnabledChanged)

    Q_PROPERTY(int iconBadgeNumber READ iconBadgeNumber WRITE setIconBadgeNumber NOTIFY iconBadgeNumberChanged)

public:
    explicit MobileUI_QmlDispatcher(QObject *parent = nullptr);

    QColor statusbarColor() const;
    void setStatusbarColor(const QColor &color);

    QColor statusbarContentColor() const;
    void setStatusbarContentColor(const QColor &color);

    MobileUI::Theme statusbarTheme() const;
    void setStatusbarTheme(const MobileUI::Theme theme);

    QColor navbarColor() const;
    void setNavbarColor(const QColor &color);

    QColor navbarContentColor() const;
    void setNavbarContentColor(const QColor &color);

    MobileUI::Theme navbarTheme() const;
    void setNavbarTheme(const MobileUI::Theme theme);

    MobileUI::ScreenLockOrientation screenLockOrientation() const;
    void setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation);

    int screenBrightness() const;
    void setScreenBrightness(const int value);

    bool screenAlwaysOn() const;
    void setScreenAlwaysOn(const bool on);

    bool screenSecure() const;
    void setScreenSecure(const bool on);

    bool screenHighRefreshRate() const;
    void setScreenHighRefreshRate(const bool on);

    bool torchEnabled() const;
    void setTorchEnabled(const bool on);

    int iconBadgeNumber() const;
    void setIconBadgeNumber(const int number);

Q_SIGNALS:
    void statusbarColorChanged();
    void statusbarContentColorChanged();
    void statusbarThemeChanged();
    void navbarColorChanged();
    void navbarContentColorChanged();
    void navbarThemeChanged();
    void screenLockOrientationChanged();
    void screenBrightnessChanged();
    void screenAlwaysOnChanged();
    void screenSecureChanged();
    void screenHighRefreshRateChanged();
    void torchEnabledChanged();
    void iconBadgeNumberChanged();
};

/* ************************************************************************** */
#endif // MOBILEUI_QML_DISPATCHER_H

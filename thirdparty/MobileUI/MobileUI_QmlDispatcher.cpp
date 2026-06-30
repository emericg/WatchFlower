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

#include "MobileUI_QmlDispatcher.h"

/* ************************************************************************** */

MobileUI_QmlDispatcher::MobileUI_QmlDispatcher(QObject *parent) : QObject(parent)
{
    MobileUI *mui = MobileUI::getInstance();

    connect(mui, &MobileUI::statusbarUpdated, this, [this]() {
        Q_EMIT statusbarColorChanged();
        Q_EMIT statusbarContentColorChanged();
        Q_EMIT statusbarThemeChanged();
    });
    connect(mui, &MobileUI::navbarUpdated, this, [this]() {
        Q_EMIT navbarColorChanged();
        Q_EMIT navbarContentColorChanged();
        Q_EMIT navbarThemeChanged();
    });
    connect(mui, &MobileUI::screenUpdated, this, [this]() {
        Q_EMIT screenLockOrientationChanged();
        Q_EMIT screenBrightnessChanged();
        Q_EMIT screenAlwaysOnChanged();
        Q_EMIT screenSecureChanged();
        Q_EMIT screenHighRefreshRateChanged();
    });
    connect(mui, &MobileUI::torchUpdated, this, [this]() {
        Q_EMIT torchEnabledChanged();
    });
    connect(mui, &MobileUI::iconBadgeUpdated, this, [this]() {
        Q_EMIT iconBadgeNumberChanged();
    });
}

/* ************************************************************************** */

QColor MobileUI_QmlDispatcher::statusbarColor() const
{
    return MobileUI::getInstance()->getStatusbarColor();
}

void MobileUI_QmlDispatcher::setStatusbarColor(const QColor &color)
{
    MobileUI::getInstance()->setStatusbarColor(color);
}

MobileUI::Theme MobileUI_QmlDispatcher::statusbarTheme() const
{
    return MobileUI::getInstance()->getStatusbarTheme();
}

void MobileUI_QmlDispatcher::setStatusbarTheme(const MobileUI::Theme theme)
{
    MobileUI::getInstance()->setStatusbarTheme(theme);
}

QColor MobileUI_QmlDispatcher::statusbarContentColor() const
{
    return MobileUI::getInstance()->getStatusbarContentColor();
}

void MobileUI_QmlDispatcher::setStatusbarContentColor(const QColor &color)
{
    MobileUI::getInstance()->setStatusbarContentColor(color);
}

/* ************************************************************************** */

QColor MobileUI_QmlDispatcher::navbarColor() const
{
    return MobileUI::getInstance()->getNavbarColor();
}

void MobileUI_QmlDispatcher::setNavbarColor(const QColor &color)
{
    MobileUI::getInstance()->setNavbarColor(color);
}

MobileUI::Theme MobileUI_QmlDispatcher::navbarTheme() const
{
    return MobileUI::getInstance()->getNavbarTheme();
}

void MobileUI_QmlDispatcher::setNavbarTheme(const MobileUI::Theme theme)
{
    MobileUI::getInstance()->setNavbarTheme(theme);
}

QColor MobileUI_QmlDispatcher::navbarContentColor() const
{
    return MobileUI::getInstance()->getNavbarContentColor();
}

void MobileUI_QmlDispatcher::setNavbarContentColor(const QColor &color)
{
    MobileUI::getInstance()->setNavbarContentColor(color);
}

/* ************************************************************************** */

bool MobileUI_QmlDispatcher::screenAlwaysOn() const
{
    return MobileUI::getInstance()->getScreenAlwaysOn();
}

void MobileUI_QmlDispatcher::setScreenAlwaysOn(const bool on)
{
    MobileUI::getInstance()->setScreenAlwaysOn(on);
}

MobileUI::ScreenLockOrientation MobileUI_QmlDispatcher::screenLockOrientation() const
{
    return MobileUI::getInstance()->getScreenLockOrientation();
}

void MobileUI_QmlDispatcher::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
{
    MobileUI::getInstance()->setScreenLockOrientation(orientation);
}

int MobileUI_QmlDispatcher::screenBrightness() const
{
    return MobileUI::getInstance()->getScreenBrightness();
}

void MobileUI_QmlDispatcher::setScreenBrightness(const int value)
{
    MobileUI::getInstance()->setScreenBrightness(value);
}

bool MobileUI_QmlDispatcher::screenSecure() const
{
    return MobileUI::getInstance()->getScreenSecure();
}

void MobileUI_QmlDispatcher::setScreenSecure(const bool on)
{
    MobileUI::getInstance()->setScreenSecure(on);
}

bool MobileUI_QmlDispatcher::screenHighRefreshRate() const
{
    return MobileUI::getInstance()->getHighRefreshRate();
}

void MobileUI_QmlDispatcher::setScreenHighRefreshRate(const bool on)
{
    MobileUI::getInstance()->setHighRefreshRate(on);
}

/* ************************************************************************** */

bool MobileUI_QmlDispatcher::torchEnabled() const
{
    return MobileUI::getInstance()->getTorchEnabled();
}

void MobileUI_QmlDispatcher::setTorchEnabled(const bool on)
{
    MobileUI::getInstance()->setTorchEnabled(on);
}

/* ************************************************************************** */

int MobileUI_QmlDispatcher::iconBadgeNumber() const
{
    return MobileUI::getInstance()->getIconBadgeNumber();
}

void MobileUI_QmlDispatcher::setIconBadgeNumber(const int number)
{
    MobileUI::getInstance()->setIconBadgeNumber(number);
}

/* ************************************************************************** */

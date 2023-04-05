/*!
 * Copyright (c) 2016 J-P Nurmi
 * Copyright (c) 2022 Emeric Grange
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

#include "MobileUI.h"
#include "MobileUI_private.h"

#include <QQmlEngine>

/* ************************************************************************** */

bool MobileUIPrivate::areIosSlotsConnected = false;

MobileUI::Theme MobileUIPrivate::deviceTheme = MobileUI::Light;

QColor MobileUIPrivate::statusbarColor;
MobileUI::Theme MobileUIPrivate::statusbarTheme = MobileUI::Light;

QColor MobileUIPrivate::navbarColor;
MobileUI::Theme MobileUIPrivate::navbarTheme = MobileUI::Light;

/* ************************************************************************** */

void MobileUI::registerQML()
{
    qRegisterMetaType<MobileUI::Theme>("MobileUI::Theme");

    qmlRegisterType<MobileUI>("MobileUI", 1, 0, "MobileUI");
}

bool MobileUI::isAvailable()
{
    return MobileUIPrivate::isAvailable_sys();
}

/* ************************************************************************** */

MobileUI::Theme MobileUI::getDeviceTheme()
{
    return static_cast<MobileUI::Theme>(MobileUIPrivate::getDeviceTheme_sys());
}

/* ************************************************************************** */

QColor MobileUI::getStatusbarColor()
{
    return MobileUIPrivate::statusbarColor;
}

void MobileUI::setStatusbarColor(const QColor &color)
{
    MobileUIPrivate::statusbarColor = color;
    MobileUIPrivate::setColor_statusbar(color);
}

MobileUI::Theme MobileUI::getStatusbarTheme()
{
    return MobileUIPrivate::statusbarTheme;
}

void MobileUI::setStatusbarTheme(Theme theme)
{
    MobileUIPrivate::statusbarTheme = theme;
    MobileUIPrivate::setTheme_statusbar(theme);
}

/* ************************************************************************** */

QColor MobileUI::getNavbarColor()
{
    return MobileUIPrivate::navbarColor;
}

void MobileUI::setNavbarColor(const QColor &color)
{
    MobileUIPrivate::navbarColor = color;
    MobileUIPrivate::setColor_navbar(color);
}

MobileUI::Theme MobileUI::getNavbarTheme()
{
    return MobileUIPrivate::navbarTheme;
}

void MobileUI::setNavbarTheme(Theme theme)
{
    MobileUIPrivate::navbarTheme = theme;
    MobileUIPrivate::setTheme_navbar(theme);
}

/* ************************************************************************** */

void MobileUI::keepScreenOn(bool on)
{
    MobileUIPrivate::keepScreenOn(on);
}

/* ************************************************************************** */

/*
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

#ifndef MOBILEUI_PRIVATE_H
#define MOBILEUI_PRIVATE_H
/* ************************************************************************** */

#include "MobileUI.h"

/* ************************************************************************** */

class MobileUIPrivate
{
public:
    static bool isAvailable_sys();

    static int getDeviceTheme_sys();

    static void setColor_statusbar(const QColor &color);
    static void setTheme_statusbar(MobileUI::Theme theme);

    static void setColor_navbar(const QColor &color);
    static void setTheme_navbar(MobileUI::Theme theme);

    static bool areIosSlotsConnected;

    static MobileUI::Theme deviceTheme;

    static QColor statusbarColor;
    static MobileUI::Theme statusbarTheme;

    static QColor navbarColor;
    static MobileUI::Theme navbarTheme;

    static void keepScreenOn(bool on);
};

/* ************************************************************************** */
#endif // MOBILEUI_PRIVATE_H

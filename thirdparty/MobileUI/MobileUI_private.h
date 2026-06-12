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

/* ************************************************************************** */

class MobileUIPrivate
{
public:
    MobileUIPrivate() = default;
    ~MobileUIPrivate() = default;

    int getDeviceTheme();

    void setColor_statusbar(const QColor &color);
    void setTheme_statusbar(const MobileUI::Theme theme);

    void setColor_navbar(const QColor &color);
    void setTheme_navbar(const MobileUI::Theme theme);

    int getStatusbarHeight();
    int getNavbarHeight();

    int getSafeAreaTop();
    int getSafeAreaLeft();
    int getSafeAreaRight();
    int getSafeAreaBottom();

    void setScreenAlwaysOn(const bool on);

    void setScreenOrientation(const MobileUI::ScreenOrientation orientation);

    int getScreenBrightness();
    void setScreenBrightness(const int value);

    void vibrate();

    void backToHomeScreen();
};

/* ************************************************************************** */
#endif // MOBILEUI_PRIVATE_H

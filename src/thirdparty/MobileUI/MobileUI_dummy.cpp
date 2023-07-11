/*!
 * Copyright (c) 2016 J-P Nurmi
 * Copyright (c) 2023 Emeric Grange
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

#include "MobileUI_private.h"

/* ************************************************************************** */

int MobileUIPrivate::getDeviceTheme()
{
    return MobileUI::Theme::Light;
}

void MobileUIPrivate::setColor_statusbar(const QColor &color)
{
    Q_UNUSED(color)
}

void MobileUIPrivate::setTheme_statusbar(const MobileUI::Theme theme)
{
    Q_UNUSED(theme)
}

void MobileUIPrivate::setColor_navbar(const QColor &color)
{
    Q_UNUSED(color)
}

void MobileUIPrivate::setTheme_navbar(const MobileUI::Theme theme)
{
    Q_UNUSED(theme)
}

int MobileUIPrivate::getStatusbarHeight()
{
    return 0;
}

int MobileUIPrivate::getNavbarHeight()
{
    return 0;
}

int MobileUIPrivate::getSafeAreaTop()
{
    return 0;
}

int MobileUIPrivate::getSafeAreaLeft()
{
    return 0;
}

int MobileUIPrivate::getSafeAreaRight()
{
    return 0;
}

int MobileUIPrivate::getSafeAreaBottom()
{
    return 0;
}

void MobileUIPrivate::setScreenAlwaysOn(const bool on)
{
    Q_UNUSED(on)
}

void MobileUIPrivate::setScreenOrientation(const MobileUI::ScreenOrientation orientation)
{
    Q_UNUSED(orientation)
}

void MobileUIPrivate::vibrate()
{
    return;
}

/* ************************************************************************** */

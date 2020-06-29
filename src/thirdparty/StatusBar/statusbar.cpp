/*
 * Copyright (c) 2016 J-P Nurmi
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

#include "statusbar.h"
#include "statusbar_p.h"

QColor StatusBarPrivate::sbColor;
StatusBar::Theme StatusBarPrivate::sbTheme = StatusBar::Light;
QColor StatusBarPrivate::navColor;
StatusBar::Theme StatusBarPrivate::navTheme = StatusBar::Light;

StatusBar::StatusBar(QObject *parent) : QObject(parent)
{
    //
}

bool StatusBar::isAvailable()
{
    return StatusBarPrivate::isAvailable_sys();
}

QColor StatusBar::sbColor()
{
    return StatusBarPrivate::sbColor;
}

void StatusBar::setSbColor(const QColor &color)
{
    StatusBarPrivate::sbColor = color;
    StatusBarPrivate::setColor_sb(color);
}

StatusBar::Theme StatusBar::sbTheme()
{
    return StatusBarPrivate::sbTheme;
}

void StatusBar::setSbTheme(Theme theme)
{
    StatusBarPrivate::sbTheme = theme;
    StatusBarPrivate::setTheme_sb(theme);
}

QColor StatusBar::navColor()
{
    return StatusBarPrivate::navColor;
}

void StatusBar::setNavColor(const QColor &color)
{
    StatusBarPrivate::navColor = color;
    StatusBarPrivate::setColor_nav(color);
}

StatusBar::Theme StatusBar::navTheme()
{
    return StatusBarPrivate::navTheme;
}

void StatusBar::setNavTheme(Theme theme)
{
    StatusBarPrivate::navTheme = theme;
    StatusBarPrivate::setTheme_nav(theme);
}

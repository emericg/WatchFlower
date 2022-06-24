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

#ifndef MOBILEUI_H
#define MOBILEUI_H
/* ************************************************************************** */

#include <QObject>
#include <QColor>

/* ************************************************************************** */

class MobileUI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ isAvailable CONSTANT)

    Q_PROPERTY(Theme deviceTheme READ getDeviceTheme NOTIFY devicethemeUpdated)

    Q_PROPERTY(QColor statusbarColor READ getStatusbarColor WRITE setStatusbarColor NOTIFY statusbarUpdated)
    Q_PROPERTY(Theme statusbarTheme READ getStatusbarTheme WRITE setStatusbarTheme NOTIFY statusbarUpdated)

    Q_PROPERTY(QColor navbarColor READ getNavbarColor WRITE setNavbarColor NOTIFY navbarUpdated)
    Q_PROPERTY(Theme navbarTheme READ getNavbarTheme WRITE setNavbarTheme NOTIFY navbarUpdated)

Q_SIGNALS:
    void devicethemeUpdated();
    void statusbarUpdated();
    void navbarUpdated();

public:
    explicit MobileUI(QObject *parent = nullptr) : QObject(parent) {}

    static void registerQML();

    static bool isAvailable();

    enum Theme {
        Light,  //!< Light application theme, usually light background and dark texts.
        Dark    //!< Dark application theme, usually dark background and light texts.
    };
    Q_ENUM(Theme)

    static Theme getDeviceTheme();

    // Status bar
    static QColor getStatusbarColor();
    static void setStatusbarColor(const QColor &color);

    static Theme getStatusbarTheme();
    static void setStatusbarTheme(Theme theme);

    // Navigation bar
    static QColor getNavbarColor();
    static void setNavbarColor(const QColor &color);

    static Theme getNavbarTheme();
    static void setNavbarTheme(Theme theme);

    // Screen helpers
    Q_INVOKABLE static void keepScreenOn(bool on);
};

/* ************************************************************************** */
#endif // MOBILEUI_H

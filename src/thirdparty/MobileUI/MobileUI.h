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

    Q_PROPERTY(QColor statusbarColor READ statusbarColor WRITE setStatusbarColor NOTIFY statusbarUpdated)
    Q_PROPERTY(Theme statusbarTheme READ statusbarTheme WRITE setStatusbarTheme NOTIFY statusbarUpdated)

    Q_PROPERTY(QColor navbarColor READ navbarColor WRITE setNavbarColor NOTIFY navbarUpdated)
    Q_PROPERTY(Theme navbarTheme READ navbarTheme WRITE setNavbarTheme NOTIFY navbarUpdated)

Q_SIGNALS:
    void statusbarUpdated();
    void navbarUpdated();

public:
    explicit MobileUI(QObject *parent = nullptr) : QObject(parent) {}

    static bool isAvailable();
    static void registerQML();

    enum Theme {
        Light,  //!< DARK TEXT (assumes LIGHT application theme/background)
        Dark    //!< LIGHT TEXT (assumes DARK application theme/background)
    };
    Q_ENUM(Theme)

    // Status bar
    static QColor statusbarColor();
    static void setStatusbarColor(const QColor &color);

    static Theme statusbarTheme();
    static void setStatusbarTheme(Theme theme);

    // Navigation bar
    static QColor navbarColor();
    static void setNavbarColor(const QColor &color);

    static Theme navbarTheme();
    static void setNavbarTheme(Theme theme);

    // Screen helpers
    enum Orientation {
        SCREEN_ORIENTATION_UNSET,
        SCREEN_ORIENTATION_UNSPECIFIED,
        SCREEN_ORIENTATION_LANDSCAPE,
        SCREEN_ORIENTATION_PORTRAIT,
        SCREEN_ORIENTATION_USER,
        SCREEN_ORIENTATION_BEHIND,
        SCREEN_ORIENTATION_SENSOR,
        SCREEN_ORIENTATION_NOSENSOR,
        SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
        SCREEN_ORIENTATION_SENSOR_PORTRAIT,
        SCREEN_ORIENTATION_REVERSE_LANDSCAPE,
        SCREEN_ORIENTATION_REVERSE_PORTRAIT,
        SCREEN_ORIENTATION_FULL_SENSOR,
        SCREEN_ORIENTATION_USER_LANDSCAPE,
        SCREEN_ORIENTATION_USER_PORTRAIT,
        SCREEN_ORIENTATION_FULL_USER,
        SCREEN_ORIENTATION_LOCKED
    };
    Q_ENUM(Orientation)

    //void screen_keepOn(bool on);
    //void screen_lockOrientation(Orientation orientation);
};

/* ************************************************************************** */
#endif // MOBILEUI_H

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

#include <QGuiApplication>
#include <QScreen>
#include <QWindow>
#include <QTimer>

#include <QtAndroid>
#include <QAndroidJniEnvironment>

/* ************************************************************************** */

// WindowManager.LayoutParams
#define FLAG_KEEP_SCREEN_ON                     0x00000080
#define FLAG_TRANSLUCENT_STATUS                 0x04000000
#define FLAG_TRANSLUCENT_NAVIGATION             0x08000000
#define FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS       0x80000000

// View
#define SYSTEM_UI_FLAG_LAYOUT_STABLE            0x00000100
#define SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION   0x00000200
#define SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN        0x00000400
#define SYSTEM_UI_FLAG_LIGHT_STATUS_BAR         0x00002000
#define SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR     0x00000010

// UI modes
#define UI_MODE_NIGHT_UNDEFINED                 0x00000000
#define UI_MODE_NIGHT_NO                        0x00000010
#define UI_MODE_NIGHT_YES                       0x00000020
#define UI_MODE_NIGHT_MASK                      0x00000030

// WindowInsetsController
#define APPEARANCE_OPAQUE_STATUS_BARS           0x00000001
#define APPEARANCE_OPAQUE_NAVIGATION_BARS       0x00000002
#define APPEARANCE_LOW_PROFILE_BARS             0x00000004
#define APPEARANCE_LIGHT_STATUS_BARS            0x00000008
#define APPEARANCE_LIGHT_NAVIGATION_BARS        0x00000010
#define APPEARANCE_SEMI_TRANSPARENT_STATUS_BARS 0x00000020
#define APPEARANCE_SEMI_TRANSPARENT_NAVIGATION_BARS 0x0030

#define BEHAVIOR_SHOW_BARS_BY_TOUCH             0x00000000
#define BEHAVIOR_SHOW_BARS_BY_SWIPE             0x00000001
#define BEHAVIOR_DEFAULT                        0x00000001
#define BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE   0x00000002

// VibrationEffect
#define DEFAULT_AMPLITUDE                       0xffffffff
#define EFFECT_CLICK                            0x00000000
#define EFFECT_DOUBLE_CLICK                     0x00000001
#define EFFECT_HEAVY_CLICK                      0x00000005
#define EFFECT_TICK                             0x00000002

/* ************************************************************************** */

static bool isQColorLight(const QColor color)
{
    double darkness = 1.0 - (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255.0;
    return (darkness < 0.2);
}

static QAndroidJniObject getAndroidWindow()
{
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

    return window;
}

static QAndroidJniObject getAndroidDecorView()
{
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
    QAndroidJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");

    return view;
}

static QAndroidJniObject getDisplayCutout()
{
    if (QtAndroid::androidSdkVersion() >= 28)
    {
        // DisplayCutout has been added in API level 28
        QAndroidJniObject activity = QtAndroid::androidActivity();
        QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
        QAndroidJniObject decorview = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        QAndroidJniObject insets = decorview.callObjectMethod("getRootWindowInsets", "()Landroid/view/WindowInsets;");
        QAndroidJniObject cutout = insets.callObjectMethod("getDisplayCutout", "()Landroid/view/DisplayCutout;");

        return cutout;
    }

    return QAndroidJniObject();
}

/* ************************************************************************** */

int MobileUIPrivate::getDeviceTheme()
{
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject rsc = activity.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
    QAndroidJniObject conf = rsc.callObjectMethod("getConfiguration", "()Landroid/content/res/Configuration;");

    int uiMode = (conf.getField<int>("uiMode") & UI_MODE_NIGHT_MASK);

    return (uiMode == UI_MODE_NIGHT_YES) ? MobileUI::Theme::Dark : MobileUI::Theme::Light;
}

void MobileUIPrivate::refreshUI_async()
{
    MobileUIPrivate::setTheme_statusbar(MobileUIPrivate::statusbarTheme);
    MobileUIPrivate::setTheme_navbar(MobileUIPrivate::navbarTheme);
}

/* ************************************************************************** */

void MobileUIPrivate::setColor_statusbar(const QColor &color)
{
    QtAndroid::runOnAndroidThread([=]() {
        // set color
        QAndroidJniObject window = getAndroidWindow();
        window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
        window.callMethod<void>("setStatusBarColor", "(I)V", color.rgba());

        // derive the theme from the color
        MobileUIPrivate::statusbarTheme = static_cast<MobileUI::Theme>(!isQColorLight(color));
        setTheme_statusbar(MobileUIPrivate::statusbarTheme);
    });
}

void MobileUIPrivate::setTheme_statusbar(const MobileUI::Theme theme)
{
    if (QtAndroid::androidSdkVersion() < 23) return;

    QtAndroid::runOnAndroidThread([=]() {
        if (QtAndroid::androidSdkVersion() < 30)
        {
            // Added in API level 23 // Deprecated in API level 30

            QAndroidJniObject view = getAndroidDecorView();

            int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
            if (theme == MobileUI::Theme::Light)
                visibility |= SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            else
                visibility &= ~SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;

            view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
        }
        else if (QtAndroid::androidSdkVersion() >= 30)
        {
            // Added in API level 30

            QAndroidJniObject window = getAndroidWindow();
            QAndroidJniObject inset = window.callObjectMethod("getInsetsController",
                                                              "()Landroid/view/WindowInsetsController;");

            int visibility = inset.callMethod<int>("getSystemBarsAppearance", "()I");
            if (theme == MobileUI::Theme::Light)
                visibility |= APPEARANCE_LIGHT_STATUS_BARS;
            else
                visibility &= ~APPEARANCE_LIGHT_STATUS_BARS;

            inset.callMethod<void>("setSystemBarsAppearance", "(II)V",
                                   visibility, APPEARANCE_LIGHT_STATUS_BARS);

            if (!MobileUIPrivate::areRefreshSlotsConnected)
            {
                QScreen *screen = qApp->primaryScreen();
                if (screen)
                {
                    QObject::connect(screen, &QScreen::orientationChanged,
                                     qApp, [](Qt::ScreenOrientation) { refreshUI_async(); });
                }

                QWindowList windows =  qApp->allWindows();
                if (windows.size() && windows.at(0))
                {
                    QWindow *window_qt = windows.at(0);
                    QObject::connect(window_qt, &QWindow::visibilityChanged,
                                     qApp, [](QWindow::Visibility) { refreshUI_async(); });
                }

                MobileUIPrivate::areRefreshSlotsConnected = true;
            }
        }
    });
}

/* ************************************************************************** */

void MobileUIPrivate::setColor_navbar(const QColor &color)
{
    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window_android = getAndroidWindow();
        QWindow *window_qt = (qApp->allWindows().size() && qApp->allWindows().at(0)) ? qApp->allWindows().at(0) : nullptr;

        // set color
        QAndroidJniObject window = getAndroidWindow();
        window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
        window.callMethod<void>("setNavigationBarColor", "(I)V", color.rgba());

        if (window_qt && window_qt->flags() & Qt::MaximizeUsingFullscreenGeometryHint)
        {
            // if we try to set the FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS flag while in fullscreen mode, it will mess everything up
            window_android.callMethod<void>("addFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
            window_android.callMethod<void>("addFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
        }
        else
        {
            // set color
            window_android.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window_android.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
            window_android.callMethod<void>("setNavigationBarColor", "(I)V", color.rgba());
        }

        // derive the theme from the color
        MobileUIPrivate::navbarTheme = static_cast<MobileUI::Theme>(!isQColorLight(color));
        setTheme_navbar(MobileUIPrivate::navbarTheme);
    });
}

void MobileUIPrivate::setTheme_navbar(const MobileUI::Theme theme)
{
    if (QtAndroid::androidSdkVersion() < 23) return;

    QtAndroid::runOnAndroidThread([=]() {
        if (QtAndroid::androidSdkVersion() < 30)
        {
            // Added in API level 23 // Deprecated in API level 30

            QAndroidJniObject view = getAndroidDecorView();

            int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
            if (theme == MobileUI::Theme::Light)
                visibility |= SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            else
                visibility &= ~SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;

            view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
        }
        else if (QtAndroid::androidSdkVersion() >= 30)
        {
            // Added in API level 30

            QAndroidJniObject window = getAndroidWindow();
            QAndroidJniObject inset = window.callObjectMethod("getInsetsController",
                                                              "()Landroid/view/WindowInsetsController;");

            int visibility = inset.callMethod<int>("getSystemBarsAppearance", "()I");
            if (theme == MobileUI::Theme::Light)
                visibility |= APPEARANCE_LIGHT_NAVIGATION_BARS;
            else
                visibility &= ~APPEARANCE_LIGHT_NAVIGATION_BARS;

            inset.callMethod<void>("setSystemBarsAppearance", "(II)V",
                                   visibility, APPEARANCE_LIGHT_NAVIGATION_BARS);

            if (!MobileUIPrivate::areRefreshSlotsConnected)
            {
                QScreen *screen = qApp->primaryScreen();
                if (screen)
                {
                    QObject::connect(screen, &QScreen::orientationChanged,
                                     qApp, [](Qt::ScreenOrientation) { refreshUI_async(); });
                }

                QWindowList windows =  qApp->allWindows();
                if (windows.size() && windows.at(0))
                {
                    QWindow *window_qt = windows.at(0);
                    QObject::connect(window_qt, &QWindow::visibilityChanged,
                                     qApp, [](QWindow::Visibility) { refreshUI_async(); });
                }

                MobileUIPrivate::areRefreshSlotsConnected = true;
            }
        }
    });
}

/* ************************************************************************** */

int MobileUIPrivate::getStatusbarHeight()
{
    return 24; // TODO
}

int MobileUIPrivate::getNavbarHeight()
{
    return 48; // TODO
}

int MobileUIPrivate::getSafeAreaTop()
{
    QAndroidJniObject cutout = getDisplayCutout();
    if (cutout.isValid())
    {
        return cutout.callMethod<int>("getSafeInsetTop", "()I") / qApp->devicePixelRatio();
    }

    return 0;
}

int MobileUIPrivate::getSafeAreaLeft()
{
    QAndroidJniObject cutout = getDisplayCutout();
    if (cutout.isValid())
    {
        return cutout.callMethod<int>("getSafeInsetLeft", "()I") / qApp->devicePixelRatio();
    }

    return 0;
}

int MobileUIPrivate::getSafeAreaRight()
{
    QAndroidJniObject cutout = getDisplayCutout();
    if (cutout.isValid())
    {
        return cutout.callMethod<int>("getSafeInsetRight", "()I") / qApp->devicePixelRatio();
    }

    return 0;
}

int MobileUIPrivate::getSafeAreaBottom()
{
    QAndroidJniObject cutout = getDisplayCutout();
    if (cutout.isValid())
    {
        return cutout.callMethod<int>("getSafeInsetBottom", "()I") / qApp->devicePixelRatio();
    }

    return 0;
}

/* ************************************************************************** */

void MobileUIPrivate::setScreenAlwaysOn(const bool on)
{
    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();

        if (on)
            window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
        else
            window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
    });
}

void MobileUIPrivate::setScreenOrientation(const MobileUI::ScreenOrientation orientation)
{
    int value = -1; // SCREEN_ORIENTATION_UNSPECIFIED

    if (orientation == MobileUI::Portrait) value = 1; // SCREEN_ORIENTATION_PORTRAIT
    else if (orientation == MobileUI::Portrait_upsidedown) value = 9; // SCREEN_ORIENTATION_REVERSE_PORTRAIT
    else if (orientation == MobileUI::Portrait_sensor) value = 7; // SCREEN_ORIENTATION_SENSOR_PORTRAIT
    else if (orientation == MobileUI::Landscape_left) value = 0; // SCREEN_ORIENTATION_LANDSCAPE
    else if (orientation == MobileUI::Landscape_right) value = 8; // SCREEN_ORIENTATION_REVERSE_LANDSCAPE
    else if (orientation == MobileUI::Landscape_sensor) value = 6; // SCREEN_ORIENTATION_SENSOR_LANDSCAPE

    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }
}

/* ************************************************************************** */

void MobileUIPrivate::vibrate()
{
    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject activity = QtAndroid::androidActivity();
        if (activity.isValid())
        {
            QAndroidJniObject vibratorString = QAndroidJniObject::fromString("vibrator");
            QAndroidJniObject vibratorService = activity.callObjectMethod("getSystemService",
                                                                          "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                          vibratorString.object<jstring>());
            if (vibratorService.callMethod<jboolean>("hasVibrator", "()Z"))
            {
                if (QtAndroid::androidSdkVersion() >= 26)
                {
                    // vibrate(VibrationEffect vibe) // Added in API level 26

                    jint effect = EFFECT_TICK;
                    QAndroidJniObject vibrationEffect = QAndroidJniObject::callStaticObjectMethod("android/os/VibrationEffect",
                                                                                                  "createPredefined",
                                                                                                  "(I)Landroid/os/VibrationEffect;",
                                                                                                  effect);

                    vibratorService.callMethod<void>("vibrate",
                                                     "(Landroid/os/VibrationEffect;)V",
                                                     vibrationEffect.object<jobject>());
                }
                else
                {
                    // vibrate(long milliseconds) // Deprecated in API level 26

                    jlong ms = 25;
                    vibratorService.callMethod<void>("vibrate", "(J)V", ms);
                }
            }
        }
        QAndroidJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });
}

/* ************************************************************************** */

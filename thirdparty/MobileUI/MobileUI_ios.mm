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

#include <objc/objc.h>
#include <objc/message.h>
#include <UIKit/UIKit.h>

/* ************************************************************************** */

@interface QIOSViewController : UIViewController
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;
@end

static bool isQColorLight(const QColor color)
{
    double darkness = 1.0 - (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255.0;
    return (darkness < 0.2);
}

UIStatusBarStyle statusBarStyle(const MobileUI::Theme theme)
{
    if (theme == MobileUI::Dark) return UIStatusBarStyleLightContent;
    else if (@available(iOS 13.0, *)) return UIStatusBarStyleDarkContent;
    else return UIStatusBarStyleDefault;
}

static void setPreferredStatusBarStyle(UIWindow *window, UIStatusBarStyle style)
{
    QIOSViewController *viewController = static_cast<QIOSViewController *>([window rootViewController]);
    if (!viewController || viewController.preferredStatusBarStyle == style) return;

    viewController.preferredStatusBarStyle = style;
    [viewController setNeedsStatusBarAppearanceUpdate];
}

void updatePreferredStatusBarStyle()
{
    UIStatusBarStyle style = statusBarStyle(MobileUIPrivate::statusbarTheme);
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (keyWindow) setPreferredStatusBarStyle(keyWindow, style);
}

/* ************************************************************************** */

int MobileUIPrivate::getDeviceTheme()
{
    if (@available(iOS 13.0, *))
    {

        if ([[[[[UIApplication sharedApplication] keyWindow] rootViewController] traitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark)
        {
            return MobileUI::Theme::Dark;
        }
        else
        {
            return MobileUI::Theme::Light;
        }
    }

    return 0;
}

void MobileUIPrivate::refreshUI_async()
{
    QTimer::singleShot(  0, []() { updatePreferredStatusBarStyle(); }); // now
    QTimer::singleShot( 20, []() { updatePreferredStatusBarStyle(); }); // after a frame
    QTimer::singleShot(200, []() { updatePreferredStatusBarStyle(); }); // after rotation animation?
}

/* ************************************************************************** */

void MobileUIPrivate::setColor_statusbar(const QColor &color)
{
    // derive the theme from the color
    MobileUIPrivate::statusbarTheme = static_cast<MobileUI::Theme>(!isQColorLight(color));
    setTheme_statusbar(MobileUIPrivate::statusbarTheme);
}

void MobileUIPrivate::setTheme_statusbar(const MobileUI::Theme theme)
{
    Q_UNUSED(theme)

    updatePreferredStatusBarStyle();

    if (!MobileUIPrivate::areRefreshSlotsConnected)
    {
        QObject::connect(qApp, &QGuiApplication::applicationStateChanged,
                         qApp, [](Qt::ApplicationState state) { if (state == Qt::ApplicationActive) updatePreferredStatusBarStyle(); });

        QScreen *screen = qApp->primaryScreen();
        if (screen)
        {
            QObject::connect(screen, &QScreen::orientationChanged,
                             qApp, [](Qt::ScreenOrientation) { refreshUI_async(); });
        }

        QWindowList windows =  qApp->allWindows();
        if (windows.size() && windows.at(0))
        {
            QWindow *window = windows.at(0);
            QObject::connect(window, &QWindow::visibilityChanged,
                             qApp, [](QWindow::Visibility) { refreshUI_async(); });
        }

        MobileUIPrivate::areRefreshSlotsConnected = true;
    }
}

/* ************************************************************************** */

void MobileUIPrivate::setColor_navbar(const QColor &color)
{
    Q_UNUSED(color)
}

void MobileUIPrivate::setTheme_navbar(const MobileUI::Theme theme)
{
    Q_UNUSED(theme)
}

/* ************************************************************************** */

int MobileUIPrivate::getStatusbarHeight()
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

int MobileUIPrivate::getNavbarHeight()
{
    return 0;
}

int MobileUIPrivate::getSafeAreaTop()
{
    if (@available(iOS 11.0, *))
    {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (keyWindow) return keyWindow.safeAreaInsets.top;
    }

    return 0;
}

int MobileUIPrivate::getSafeAreaLeft()
{
    if (@available(iOS 11.0, *))
    {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (keyWindow) return keyWindow.safeAreaInsets.left;
    }

    return 0;
}

int MobileUIPrivate::getSafeAreaRight()
{
    if (@available(iOS 11.0, *))
    {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (keyWindow) return keyWindow.safeAreaInsets.right;
    }

    return 0;
}

int MobileUIPrivate::getSafeAreaBottom()
{
    if (@available(iOS 11.0, *))
    {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (keyWindow) return keyWindow.safeAreaInsets.bottom;
    }

    return 0;
}

/* ************************************************************************** */

void MobileUIPrivate::setScreenAlwaysOn(const bool on)
{
    if (on)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    }
    else
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    }
}

void MobileUIPrivate::setScreenOrientation(const MobileUI::ScreenOrientation orientation)
{
    if (@available(iOS 16.0, *))
    {
        // For reference, the values from iOS:
        // UIInterfaceOrientationMaskAll,               // The view controller supports all interface orientations.
        // UIInterfaceOrientationMaskAllButUpsideDown,  // The view controller supports all but the upside-down portrait interface orientation.
        // UIInterfaceOrientationMaskPortrait,          // The view controller supports a portrait interface orientation.
        // UIInterfaceOrientationMaskPortraitUpsideDown,// The view controller supports an upside-down portrait interface orientation.
        // UIInterfaceOrientationMaskLandscape,         // The view controller supports both landscape-left and landscape-right interface orientation.
        // UIInterfaceOrientationMaskLandscapeLeft,     // The view controller supports a landscape-left interface orientation.
        // UIInterfaceOrientationMaskLandscapeRight,    // The view controller supports a landscape-right interface orientation.

        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (!keyWindow) return;
        UIWindowScene *windowScene = keyWindow.windowScene;
        if (!windowScene) return;

        UIWindowSceneGeometryPreferences *value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskAll];

        if (orientation == MobileUI::Portrait) value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
        else if (orientation == MobileUI::Portrait_upsidedown) value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskPortraitUpsideDown];
        else if (orientation == MobileUI::Landscape_left) value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscapeLeft];
        else if (orientation == MobileUI::Landscape_right) value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscapeRight];
        else if (orientation == MobileUI::Landscape_sensor) value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
        // these aren't supported, so we default to regular mode
        else if (orientation == MobileUI::Portrait_sensor) value = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskPortrait];

        [windowScene requestGeometryUpdateWithPreferences:value errorHandler:^(NSError * _Nonnull error) {
            qDebug() << "Cannot requestGeometryUpdate: unsupported?";
        }];
    }
    else
    {
        // For reference, the enum values from iOS:
        // UIInterfaceOrientationUnknown = 0,          // The orientation of the device is unknown.
        // UIInterfaceOrientationPortrait,             // The device is in portrait mode, with the device upright and the Home button on the bottom.
        // UIInterfaceOrientationPortraitUpsideDown,   // The device is in portrait mode but is upside down, with the device upright and the Home button at the top.
        // UIInterfaceOrientationLandscapeLeft,        // The device is in landscape mode, with the device upright and the Home button on the left.
        // UIInterfaceOrientationLandscapeRight,       // The device is in landscape mode, with the device upright and the Home button on the right.

        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

        if (orientation == MobileUI::Portrait) value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        else if (orientation == MobileUI::Portrait_upsidedown) value = [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown];
        else if (orientation == MobileUI::Landscape_left) value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        else if (orientation == MobileUI::Landscape_right) value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        // these aren't supported, so we default to regular mode
        else if (orientation == MobileUI::Portrait_sensor) value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        else if (orientation == MobileUI::Landscape_sensor) value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];

        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}

/* ************************************************************************** */

int MobileUIPrivate::getScreenBrightness()
{
    Class uiScreenClass = (Class)objc_getClass("UIScreen");
    SEL mainScreenSelector = sel_registerName("mainScreen");
    id mainScreen = ((id(*)(Class, SEL))objc_msgSend)(uiScreenClass, mainScreenSelector);

    SEL brightnessSelector = sel_registerName("brightness");
    CGFloat brightness = ((CGFloat(*)(id, SEL))objc_msgSend)(mainScreen, brightnessSelector);

    return brightness * 100;
}

void MobileUIPrivate::setScreenBrightness(const int value)
{
    Class uiScreenClass = (Class)objc_getClass("UIScreen");
    SEL mainScreenSelector = sel_registerName("mainScreen");
    id mainScreen = ((id(*)(Class, SEL))objc_msgSend)(uiScreenClass, mainScreenSelector);

    float brightness = value / 100.f; // brightness is 0.0 to 1.0
    if (brightness < 0.0f) brightness = 0.0f;
    if (brightness > 1.0f) brightness = 1.0f;

    SEL setBrightnessSelector = sel_registerName("setBrightness:");
    ((void(*)(id, SEL, CGFloat))objc_msgSend)(mainScreen, setBrightnessSelector, brightness);
}

/* ************************************************************************** */

void MobileUIPrivate::vibrate()
{
    // available impacts: light, medium, heavy, soft, rigid
    // available notifications: error, success, warning

    // "impact" feedback
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleMedium)];
    //[generator prepare];
    [generator impactOccurred];
    generator = nil;
}

/* ************************************************************************** */

void MobileUIPrivate::backToHomeScreen()
{
    return;
}

/* ************************************************************************** */

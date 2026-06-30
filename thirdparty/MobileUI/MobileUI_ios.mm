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

#include "MobileUI_private.h"

#include <QGuiApplication>
#include <QScreen>
#include <QWindow>
#include <QTimer>

#include <cmath>

#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

/* ************************************************************************** */

#if !__has_feature(objc_arc)
#error "MobileUI_ios.mm must be compiled with ARC (-fobjc-arc) !!!"
#endif

/* ************************************************************************** */

@interface QIOSViewController : UIViewController
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;
@end

/* ************************************************************************** */

// Returns the app's foreground-active window scene, or the first available one.
static UIWindowScene *activeWindowScene()
{
    UIWindowScene *fallback = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes)
    {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        if (windowScene.activationState == UISceneActivationStateForegroundActive) return windowScene;
        if (!fallback) fallback = windowScene;
    }
    return fallback;
}

// Returns the key window of the active scene.
static UIWindow *activeKeyWindow()
{
    return activeWindowScene().keyWindow;
}

/* ************************************************************************** */

UIStatusBarStyle statusBarStyle(const MobileUI::Theme theme)
{
    if (theme == MobileUI::Dark) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDarkContent;
}

static void setPreferredStatusBarStyle(UIWindow *window, UIStatusBarStyle style)
{
    QIOSViewController *viewController = static_cast<QIOSViewController *>([window rootViewController]);
    if (!viewController || viewController.preferredStatusBarStyle == style) return;

    viewController.preferredStatusBarStyle = style;
    [viewController setNeedsStatusBarAppearanceUpdate];
}

void updatePreferredStatusBarStyle(const MobileUI::Theme theme)
{
    UIStatusBarStyle style = statusBarStyle(theme);
    UIWindow *keyWindow = activeKeyWindow();
    if (keyWindow) setPreferredStatusBarStyle(keyWindow, style);
}

/* ************************************************************************** */

int MobileUIPrivate::getDeviceTheme()
{
    UIWindow *keyWindow = activeKeyWindow();
    if (keyWindow.rootViewController.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
    {
        return MobileUI::Theme::Dark;
    }

    return MobileUI::Theme::Light;
}

void MobileUIPrivate::setColor_statusbar(const QColor &color)
{
    // iOS has no separate status bar background color; only the icon style
    // (light/dark content) can be controlled, through setTheme_statusbar().
    Q_UNUSED(color)
}

void MobileUIPrivate::setTheme_statusbar(const MobileUI::Theme theme)
{
    updatePreferredStatusBarStyle(theme);
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

void MobileUIPrivate::getSafeAreaMetrics(int &statusbarHeight, int &navbarHeight,
                                         int &top, int &left, int &right, int &bottom)
{
    statusbarHeight = navbarHeight = 0;

    UIWindowScene *windowScene = activeWindowScene();
    if (windowScene)
    {
        CGSize statusBarSize = windowScene.statusBarManager.statusBarFrame.size;
        statusbarHeight = static_cast<int>(std::lround(MIN(statusBarSize.width, statusBarSize.height)));
    }

    top = left = right = bottom = 0;

    UIWindow *keyWindow = windowScene.keyWindow;
    if (keyWindow)
    {
        UIEdgeInsets insets = keyWindow.safeAreaInsets;
        top = static_cast<int>(std::lround(insets.top));
        left = static_cast<int>(std::lround(insets.left));
        right = static_cast<int>(std::lround(insets.right));
        bottom = static_cast<int>(std::lround(insets.bottom));
    }
}

/* ************************************************************************** */

int MobileUIPrivate::getKeyboardHeight()
{
    return -1;
}

int MobileUIPrivate::getScreenBrightness()
{
    return static_cast<int>(std::lround([UIScreen mainScreen].brightness * 100.f));
}

/* ************************************************************************** */

void MobileUIPrivate::setScreenBrightness(const int value)
{
    // iOS brightness is system-wide with no per-app override to release,
    // so a negative value is a no-op (there is nothing to hand back).
    if (value < 0) return;

    float brightness = value / 100.f; // brightness is 0.0 to 1.0
    if (brightness < 0.0f) brightness = 0.0f;
    if (brightness > 1.0f) brightness = 1.0f;

    [UIScreen mainScreen].brightness = brightness;
}

/* ************************************************************************** */

void MobileUIPrivate::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
{
    // For reference, the values from iOS:
    // UIInterfaceOrientationMaskAll,               // The view controller supports all interface orientations.
    // UIInterfaceOrientationMaskAllButUpsideDown,  // The view controller supports all but the upside-down portrait interface orientation.
    // UIInterfaceOrientationMaskPortrait,          // The view controller supports a portrait interface orientation.
    // UIInterfaceOrientationMaskPortraitUpsideDown,// The view controller supports an upside-down portrait interface orientation.
    // UIInterfaceOrientationMaskLandscape,         // The view controller supports both landscape-left and landscape-right interface orientation.
    // UIInterfaceOrientationMaskLandscapeLeft,     // The view controller supports a landscape-left interface orientation.
    // UIInterfaceOrientationMaskLandscapeRight,    // The view controller supports a landscape-right interface orientation.

    UIWindowScene *windowScene = activeWindowScene();
    if (windowScene)
    {
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

void MobileUIPrivate::setHighRefreshRate(const bool value)
{
    qDebug() << "iOS has no runtime refresh-rate switch. Use the application Info.plist instead.";
    Q_UNUSED(value)
}

void MobileUIPrivate::setScreenSecure(const bool on)
{
    qWarning() << "iOS has no FLAG_SECURE implementation.";
    Q_UNUSED(on)
}

/* ************************************************************************** */

void MobileUIPrivate::triggerHapticFeedback(const MobileUI::HapticFeedback type)
{
    switch (type)
    {
        case MobileUI::HapticSelection:
        {
            UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
            [generator selectionChanged];
            generator = nil;
        } break;

        case MobileUI::HapticLight:
        case MobileUI::HapticMedium:
        case MobileUI::HapticHeavy:
        {
            UIImpactFeedbackStyle style = UIImpactFeedbackStyleMedium;
            if (type == MobileUI::HapticLight) style = UIImpactFeedbackStyleLight;
            else if (type == MobileUI::HapticHeavy) style = UIImpactFeedbackStyleHeavy;

            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
            [generator impactOccurred];
            generator = nil;
        } break;

        case MobileUI::HapticSuccess:
        case MobileUI::HapticWarning:
        case MobileUI::HapticError:
        {
            UINotificationFeedbackType notif = UINotificationFeedbackTypeSuccess;
            if (type == MobileUI::HapticWarning) notif = UINotificationFeedbackTypeWarning;
            else if (type == MobileUI::HapticError) notif = UINotificationFeedbackTypeError;

            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator notificationOccurred:notif];
            generator = nil;
        } break;
    }
}

/* ************************************************************************** */

bool MobileUIPrivate::setTorch(const bool on)
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device || !device.hasTorch || !device.isTorchAvailable) return false;

    NSError *error = nil;
    if (![device lockForConfiguration:&error]) return false;

    device.torchMode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    [device unlockForConfiguration];

    return on;
}

/* ************************************************************************** */

void MobileUIPrivate::setIconBadgeNumber(const int number)
{
    // UIApplication must be touched on the main thread.
    // Showing the badge requires the badge notification authorization to have been granted.
    // Note: applicationIconBadgeNumber is deprecated since iOS 17.
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = (number > 0) ? number : 0;
    });
}

/* ************************************************************************** */

void MobileUIPrivate::backToHomeScreen()
{
    return;
}

/* ************************************************************************** */

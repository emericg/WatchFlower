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

#include <objc/runtime.h>
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

static UIStatusBarStyle statusBarStyle(const MobileUI::Theme theme)
{
    if (theme == MobileUI::Dark) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDarkContent;
}

static void setPreferredStatusBarStyle(UIWindow *window, UIStatusBarStyle style)
{
    UIViewController *rootVC = [window rootViewController];
    if (![rootVC respondsToSelector:@selector(setPreferredStatusBarStyle:)]) return;

    QIOSViewController *viewController = static_cast<QIOSViewController *>(rootVC);
    if (viewController.preferredStatusBarStyle == style) return;

    viewController.preferredStatusBarStyle = style;
    [viewController setNeedsStatusBarAppearanceUpdate];
}

static void updatePreferredStatusBarStyle(const MobileUI::Theme theme)
{
    UIStatusBarStyle style = statusBarStyle(theme);
    UIWindow *keyWindow = activeKeyWindow();
    if (keyWindow) setPreferredStatusBarStyle(keyWindow, style);
}

/* ************************************************************************** */

int MobileUIPrivate::getDeviceTheme() const
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
                                         int &top, int &left, int &right, int &bottom) const
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

int MobileUIPrivate::getKeyboardHeight() const
{
    return -1;
}

int MobileUIPrivate::getScreenBrightness() const
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

//! Orientation mask reported by the root view controller, or 0 when unlocked.
static UIInterfaceOrientationMask s_lockedOrientationMask = 0;

//! supportedInterfaceOrientations implementation the root view controller class had before our hook.
static IMP s_originalSupportedOrientations = nullptr;

/*!
 * \brief Hook supportedInterfaceOrientations on the root view controller class.
 * \param viewController: the root view controller of the Qt window.
 *
 * QIOSViewController doesn't implement supportedInterfaceOrientations, so it inherits the UIKit default
 * (all orientations but upside-down on iPhone) and a geometry update request alone won't keep the orientation locked.
 * The hook reports s_lockedOrientationMask while a lock is active, and defers to the original implementation otherwise.
 * It is installed once, on the view controller class only.
 */
static void installOrientationHook(UIViewController *viewController)
{
    if (s_originalSupportedOrientations) return;

    Class cls = [viewController class];
    SEL sel = @selector(supportedInterfaceOrientations);
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) return;

    s_originalSupportedOrientations = method_getImplementation(method);

    IMP hook = imp_implementationWithBlock(^UIInterfaceOrientationMask(UIViewController *self_) {
        if (s_lockedOrientationMask) return s_lockedOrientationMask;

        using SupportedOrientationsFn = UIInterfaceOrientationMask (*)(id, SEL);
        return reinterpret_cast<SupportedOrientationsFn>(s_originalSupportedOrientations)(self_, sel);
    });

    // Adds an override on this class if it only inherits the method, replaces it otherwise.
    class_replaceMethod(cls, sel, hook, method_getTypeEncoding(method));
}

void MobileUIPrivate::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
{
    UIWindowScene *windowScene = activeWindowScene();
    UIViewController *rootVC = windowScene.keyWindow.rootViewController;
    if (!windowScene || !rootVC) return;

    // For reference, the values from iOS:
    // UIInterfaceOrientationMaskAll,               // The view controller supports all interface orientations.
    // UIInterfaceOrientationMaskAllButUpsideDown,  // The view controller supports all but the upside-down portrait interface orientation.
    // UIInterfaceOrientationMaskPortrait,          // The view controller supports a portrait interface orientation.
    // UIInterfaceOrientationMaskPortraitUpsideDown,// The view controller supports an upside-down portrait interface orientation.
    // UIInterfaceOrientationMaskLandscape,         // The view controller supports both landscape-left and landscape-right interface orientation.
    // UIInterfaceOrientationMaskLandscapeLeft,     // The view controller supports a landscape-left interface orientation.
    // UIInterfaceOrientationMaskLandscapeRight,    // The view controller supports a landscape-right interface orientation.

    UIInterfaceOrientationMask mask = 0; // unlocked

    switch (orientation)
    {
    case MobileUI::Unlocked: mask = 0; break;
    case MobileUI::Locked:
        // UIInterfaceOrientationMask values are defined as (1 << UIInterfaceOrientation)
        if (windowScene.interfaceOrientation != UIInterfaceOrientationUnknown) mask = (1 << windowScene.interfaceOrientation);
        break;
    case MobileUI::Portrait: mask = UIInterfaceOrientationMaskPortrait; break;
    case MobileUI::Portrait_upsidedown: mask = UIInterfaceOrientationMaskPortraitUpsideDown; break;
    case MobileUI::Portrait_sensor: mask = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown; break;
    case MobileUI::Landscape_left: mask = UIInterfaceOrientationMaskLandscapeLeft; break;
    case MobileUI::Landscape_right: mask = UIInterfaceOrientationMaskLandscapeRight; break;
    case MobileUI::Landscape_sensor: mask = UIInterfaceOrientationMaskLandscape; break;
    }

    installOrientationHook(rootVC);
    s_lockedOrientationMask = mask;

    // Have UIKit re-query supportedInterfaceOrientations, so the lock holds against physical rotation
    [rootVC setNeedsUpdateOfSupportedInterfaceOrientations];

    // Then rotate right away to a locked orientation, if we are not already in one
    if (mask)
    {
        UIWindowSceneGeometryPreferencesIOS *prefs = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask];
        [windowScene requestGeometryUpdateWithPreferences:prefs errorHandler:^(NSError * _Nonnull error) {
            qWarning() << "MobileUI::setScreenLockOrientation() geometry update refused:"
                       << QString::fromNSString(error.localizedDescription);
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

void MobileUIPrivate::setScreenHighRefreshRate(const bool value)
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

    return true;
}

/* ************************************************************************** */

void MobileUIPrivate::backToHomeScreen()
{
    return;
}

/* ************************************************************************** */

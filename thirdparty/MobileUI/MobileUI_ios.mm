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

#include "MobileUI_ios.h"

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

// Returns the screen of the active scene (replaces the deprecated [UIScreen mainScreen]).
static UIScreen *activeScreen()
{
    return activeWindowScene().screen;
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

IosMobileUI::IosMobileUI(QObject *parent) : PlatformMobileUI(parent)
{
    connect(qApp, &QGuiApplication::applicationStateChanged, this, &IosMobileUI::applyBrightnessForState);
}

/* ************************************************************************** */

void IosMobileUI::refreshDeviceTheme()
{
    // The window scene traits follow the system appearance (unlike a window or view controller,
    // they are not affected by an overrideUserInterfaceStyle), and exist before any key window.
    UIWindowScene *windowScene = activeWindowScene();
    if (!windowScene) return;

    switch (windowScene.traitCollection.userInterfaceStyle)
    {
    case UIUserInterfaceStyleDark: Q_EMIT deviceThemeUpdated(MobileUI::Theme::Dark); break;
    case UIUserInterfaceStyleLight: Q_EMIT deviceThemeUpdated(MobileUI::Theme::Light); break;
    default: break;
    }
}

void IosMobileUI::setTheme_statusbar(const MobileUI::Theme theme)
{
    updatePreferredStatusBarStyle(theme);
}

/* ************************************************************************** */

void IosMobileUI::refreshSafeAreaMetrics()
{
    MobileUI::SafeAreaMetrics metrics;

    // iOS without "maximized geometry" has no available safe areas
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
    const bool maximizedHint = (m_window && (m_window->flags() & Qt::ExpandedClientAreaHint));
#else
    const bool maximizedHint = (m_window && (m_window->flags() & Qt::MaximizeUsingFullscreenGeometryHint));
#endif

    if (!maximizedHint)
    {
        Q_EMIT safeAreaMetricsUpdated(metrics);
        return;
    }

    UIWindowScene *windowScene = activeWindowScene();
    if (windowScene)
    {
        CGSize statusBarSize = windowScene.statusBarManager.statusBarFrame.size;
        metrics.statusbarHeight = static_cast<int>(std::lround(MIN(statusBarSize.width, statusBarSize.height)));
    }

    UIWindow *keyWindow = windowScene.keyWindow;
    if (keyWindow)
    {
        UIEdgeInsets insets = keyWindow.safeAreaInsets;
        metrics.top = static_cast<int>(std::lround(insets.top));
        metrics.left = static_cast<int>(std::lround(insets.left));
        metrics.right = static_cast<int>(std::lround(insets.right));
        metrics.bottom = static_cast<int>(std::lround(insets.bottom));
    }

    Q_EMIT safeAreaMetricsUpdated(metrics);
}

/* ************************************************************************** */

void IosMobileUI::refreshScreenBrightness()
{
    // While the application brightness is applied, the system brightness is the one saved before
    double brightness = m_brightnessSystem;
    if (brightness < 0.0)
    {
        UIScreen *screen = activeScreen();
        if (!screen) return;
        brightness = screen.brightness;
    }

    Q_EMIT screenBrightnessUpdated(static_cast<int>(std::lround(brightness * 100.0)));
}

/* ************************************************************************** */

void IosMobileUI::setScreenBrightness(const int value)
{
    // iOS brightness is system-wide with no per-app override to release,
    // so a negative value restores the system brightness saved before the first change.
    UIScreen *screen = activeScreen();

    if (value < 0)
    {
        if (screen && m_brightnessApp >= 0.0 && m_brightnessSystem >= 0.0)
        {
            screen.brightness = m_brightnessSystem;
        }
        m_brightnessApp = -1.0;
        m_brightnessSystem = -1.0;
        return;
    }

    const float brightness = value / 100.f; // brightness is 0.0 to 1.0

    // Without a screen yet, the system brightness is saved when the application becomes active
    if (screen && m_brightnessSystem < 0.0) m_brightnessSystem = screen.brightness;
    m_brightnessApp = brightness;

    // While not active, the brightness is applied when the application becomes active again
    if (screen && QGuiApplication::applicationState() == Qt::ApplicationActive)
    {
        screen.brightness = brightness;
    }
}

void IosMobileUI::applyBrightnessForState(Qt::ApplicationState state)
{
    if (m_brightnessApp < 0.0) return;

    UIScreen *screen = activeScreen();
    if (!screen) return;

    if (state == Qt::ApplicationActive)
    {
        // The user may have changed the system brightness meanwhile
        m_brightnessSystem = screen.brightness;
        screen.brightness = m_brightnessApp;
    }
    else if (m_brightnessSystem >= 0.0)
    {
        screen.brightness = m_brightnessSystem;
    }
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

void IosMobileUI::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
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

void IosMobileUI::setScreenAlwaysOn(const bool on)
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:(on ? YES : NO)];
}

void IosMobileUI::setScreenHighRefreshRate(const bool value)
{
    qDebug() << "iOS has no runtime refresh-rate switch. Use the application Info.plist instead.";
    Q_UNUSED(value)
}

void IosMobileUI::setScreenSecure(const bool on)
{
    qWarning() << "iOS has no FLAG_SECURE implementation.";
    Q_UNUSED(on)
}

/* ************************************************************************** */

void IosMobileUI::triggerHapticFeedback(const MobileUI::HapticFeedback type)
{
    switch (type)
    {
        case MobileUI::HapticSelection:
        {
            UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
            [generator selectionChanged];
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
        } break;
    }
}

/* ************************************************************************** */

int IosMobileUI::getTorch() const
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device || !device.hasTorch) return 0;

    return device.torchActive ? 1 : 0;
}

bool IosMobileUI::setTorch(const bool on)
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

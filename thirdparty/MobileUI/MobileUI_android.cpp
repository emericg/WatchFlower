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

#include "MobileUI_android.h"

#include <QGuiApplication>
#include <QWindow>
#include <QFuture>
#include <QPointer>

#include <QJniObject>
#include <QJniEnvironment>

#include <cmath>

/* ************************************************************************** */

// WindowManager.LayoutParams
#define FLAG_KEEP_SCREEN_ON                     0x00000080
#define FLAG_SECURE                             0x00002000
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
#define APPEARANCE_SEMI_TRANSPARENT_NAVIGATION_BARS 0x0040

#define BEHAVIOR_SHOW_BARS_BY_TOUCH             0x00000000
#define BEHAVIOR_SHOW_BARS_BY_SWIPE             0x00000001
#define BEHAVIOR_DEFAULT                        0x00000001
#define BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE   0x00000002

// VibrationEffect
#define DEFAULT_AMPLITUDE                       0xffffffff
#define EFFECT_CLICK                            0x00000000
#define EFFECT_DOUBLE_CLICK                     0x00000001
#define EFFECT_TICK                             0x00000002
#define EFFECT_HEAVY_CLICK                      0x00000005

// HapticFeedbackConstants
#define HAPTIC_LONG_PRESS                       0
#define HAPTIC_VIRTUAL_KEY                      1
#define HAPTIC_CLOCK_TICK                       4
#define HAPTIC_CONTEXT_CLICK                    6
#define HAPTIC_CONFIRM                          16  // Added in API level 30
#define HAPTIC_REJECT                           17  // Added in API level 30
#define HAPTIC_SEGMENT_TICK                     26  // Added in API level 34

// Screen orientation
#define SCREEN_ORIENTATION_UNSPECIFIED         -1
#define SCREEN_ORIENTATION_LANDSCAPE            0
#define SCREEN_ORIENTATION_PORTRAIT             1
#define SCREEN_ORIENTATION_SENSOR_LANDSCAPE     6
#define SCREEN_ORIENTATION_SENSOR_PORTRAIT      7
#define SCREEN_ORIENTATION_REVERSE_LANDSCAPE    8
#define SCREEN_ORIENTATION_REVERSE_PORTRAIT     9
#define SCREEN_ORIENTATION_USER_LANDSCAPE      11
#define SCREEN_ORIENTATION_USER_PORTRAIT       12
#define SCREEN_ORIENTATION_LOCKED              14

// Screen brightness
#define BRIGHTNESS_OVERRIDE_NONE               -1

/* ************************************************************************** */

/*!
 * \brief Get the device pixel ratio of the tracked window, or the application one.
 * \note Must be called from the Qt thread, then passed to the Android main thread code.
 */
static qreal devicePixelRatio(const QWindow *window)
{
    return window ? window->devicePixelRatio() : qApp->devicePixelRatio();
}

/* ************************************************************************** */

static QJniObject getAndroidWindow()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) return QJniObject();

    return activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
}

static QJniObject getAndroidDecorView()
{
    QJniObject window = getAndroidWindow();
    if (!window.isValid()) return QJniObject();

    return window.callObjectMethod("getDecorView", "()Landroid/view/View;");
}

static QJniObject getInsetsController()
{
    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
    {
        // getInsetsController // Added in API level 30

        QJniObject window = getAndroidWindow();
        if (!window.isValid()) return QJniObject();

        return window.callObjectMethod("getInsetsController", "()Landroid/view/WindowInsetsController;");
    }

    return QJniObject();
}

static QJniObject getAndroidRootWindowInsets()
{
    // getRootWindowInsets // Added in API level 28

    QJniObject view = getAndroidDecorView();
    if (!view.isValid()) return QJniObject();

    return view.callObjectMethod("getRootWindowInsets", "()Landroid/view/WindowInsets;");
}

//! Get the application Resources, or an invalid object if there is no context.
static QJniObject getAndroidResources()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) return QJniObject();

    return activity.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
}

static QJniObject getAndroidDisplay()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) return QJniObject();

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
    {
        // Context.getDisplay() // Added in API level 30
        return activity.callObjectMethod("getDisplay", "()Landroid/view/Display;");
    }

    // WindowManager.getDefaultDisplay() // Deprecated in API level 30
    QJniObject wm = activity.callObjectMethod("getWindowManager", "()Landroid/view/WindowManager;");
    if (!wm.isValid()) return QJniObject();

    return wm.callObjectMethod("getDefaultDisplay", "()Landroid/view/Display;");
}

/*!
 * \brief Tell whether the activity theme opts out of the edge-to-edge enforcement.
 * \param activity: the application activity.
 * \return true if the windowOptOutEdgeToEdgeEnforcement theme attribute is set.
 */
static bool hasEdgeToEdgeOptOut(const QJniObject &activity)
{
    // R.attr.windowOptOutEdgeToEdgeEnforcement // Added in API level 35 // Deprecated in API level 36

    const jint attr = QJniObject::getStaticField<jint>("android/R$attr", "windowOptOutEdgeToEdgeEnforcement");
    if (attr == 0) return false;

    QJniObject theme = activity.callObjectMethod("getTheme", "()Landroid/content/res/Resources$Theme;");
    if (!theme.isValid()) return false;

    QJniEnvironment env;
    jintArray attrs = env->NewIntArray(1);
    if (!attrs) return false;
    env->SetIntArrayRegion(attrs, 0, 1, &attr);

    QJniObject values = theme.callObjectMethod("obtainStyledAttributes", "([I)Landroid/content/res/TypedArray;", attrs);
    env->DeleteLocalRef(attrs);
    if (!values.isValid()) return false;

    const bool optOut = values.callMethod<jboolean>("getBoolean", "(IZ)Z", static_cast<jint>(0), static_cast<jboolean>(false));
    values.callMethod<void>("recycle", "()V");

    return optOut;
}

/*!
 * \brief Tell whether Android enforces edge-to-edge, ignoring the system bar colors.
 * \return true if edge to edge is enforced.
 *
 * Will return true on Android 15+ (API level 35) for applications targeting API level 35 or higher,
 * unless opted out through the windowOptOutEdgeToEdgeEnforcement theme attribute (honored only
 * for applications targeting API level 35).
 */
static bool isEdgeToEdgeEnforced()
{
    static const bool enforced = []() {
        if (QNativeInterface::QAndroidApplication::sdkVersion() < 35) return false;

        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (!activity.isValid()) return true;

        QJniObject info = activity.callObjectMethod("getApplicationInfo", "()Landroid/content/pm/ApplicationInfo;");
        if (!info.isValid()) return true;

        const jint targetSdk = info.getField<jint>("targetSdkVersion");
        if (targetSdk < 35) return false;
        if (targetSdk < 36 && hasEdgeToEdgeOptOut(activity)) return false;

        return true;
    }();

    return enforced;
}

/* ************************************************************************** */

static int pxToDip(int px, qreal dpr)
{
    return static_cast<int>(std::lround(px / dpr));
}

static int insetField(const QJniObject &insets, const char *insetType, const char *side)
{
    if (QNativeInterface::QAndroidApplication::sdkVersion() < 30) return 0;
    if (!insets.isValid()) return 0;

    // Modern system bar height, via WindowInsets.Type // Call from Android thread!
    // WindowInsets.Type // Added in API level 30

    jint type = QJniObject::callStaticMethod<jint>("android/view/WindowInsets$Type", insetType, "()I");
    QJniObject inset = insets.callObjectMethod("getInsets", "(I)Landroid/graphics/Insets;", type);

    if (!inset.isValid()) return 0;

    return inset.getField<jint>(side);
}

static int dimenHeight(const char *name, int fallbackValue, qreal dpr)
{
    //if (QNativeInterface::QAndroidApplication::sdkVersion() < 28) return fallbackValue;

    // Legacy system bar height fallback, via the platform dimension resource // Call from Android thread!

    QJniObject resources = getAndroidResources();
    if (!resources.isValid()) return fallbackValue;

    QJniObject jname = QJniObject::fromString(name);
    QJniObject jtype = QJniObject::fromString("dimen");
    QJniObject jpackage = QJniObject::fromString("android");

    int identifier = resources.callMethod<int>("getIdentifier", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I",
                                               jname.object<jstring>(), jtype.object<jstring>(), jpackage.object<jstring>());

    if (identifier > 0)
    {
        return pxToDip(resources.callMethod<int>("getDimensionPixelSize", "(I)I", identifier), dpr);
    }

    return fallbackValue;
}

/* ************************************************************************** */

AndroidMobileUI::AndroidMobileUI(QObject *parent) : PlatformMobileUI(parent)
{
    //
}

/* ************************************************************************** */

void AndroidMobileUI::refreshDeviceTheme()
{
    // Never wait for the Android main thread here, the signal is emitted from the Android main thread instead.
    const QPointer<AndroidMobileUI> self(this);

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([self]() {
        QJniObject resources = getAndroidResources();
        if (!resources.isValid()) return;

        QJniObject conf = resources.callObjectMethod("getConfiguration", "()Landroid/content/res/Configuration;");
        if (!conf.isValid()) return;

        int uiMode = (conf.getField<int>("uiMode") & UI_MODE_NIGHT_MASK);

        const MobileUI::Theme theme = (uiMode == UI_MODE_NIGHT_YES) ? MobileUI::Theme::Dark
                                                                    : MobileUI::Theme::Light;

        if (self) Q_EMIT self->deviceThemeUpdated(theme);
    });
}

/* ************************************************************************** */

bool AndroidMobileUI::getSystemBarColorsSupported() const
{
    return !isEdgeToEdgeEnforced();
}

void AndroidMobileUI::setColor_statusbar(const QColor &color)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        if (!isEdgeToEdgeEnforced())
        {
            // setStatusBarColor // Added in API level 21 // Deprecated in API level 35

            QJniObject window = getAndroidWindow();
            if (!window.isValid()) return;

            window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
            window.callMethod<void>("setStatusBarColor", "(I)V", color.rgba());
        }
    });
}

void AndroidMobileUI::setTheme_statusbar(const MobileUI::Theme theme)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
        {
            // setSystemBarsAppearance // Added in API level 30

            QJniObject inset = getInsetsController();
            if (inset.isValid())
            {
                const int appearance = (theme == MobileUI::Theme::Light) ? APPEARANCE_LIGHT_STATUS_BARS : 0;

                inset.callMethod<void>("setSystemBarsAppearance", "(II)V",
                                       appearance, APPEARANCE_LIGHT_STATUS_BARS);
            }
        }
        else // if (QNativeInterface::QAndroidApplication::sdkVersion() >= 23)
        {
            // setSystemUiVisibility // Added in API level 23 // Deprecated in API level 30

            QJniObject view = getAndroidDecorView();
            if (!view.isValid()) return;

            int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
            if (theme == MobileUI::Theme::Light)
                visibility |= SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            else
                visibility &= ~SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;

            view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
        }
    });
}

/* ************************************************************************** */

void AndroidMobileUI::setColor_navbar(const QColor &color)
{
    const bool fullscreenMode = (m_window && m_window->visibility() == QWindow::FullScreen);

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([color, fullscreenMode]() {
        if (!isEdgeToEdgeEnforced())
        {
            // setNavigationBarColor // Deprecated in API level 35

            QJniObject window_android = getAndroidWindow();
            if (!window_android.isValid()) return;

            // Way more complicated than setColor_statusbar()...

            if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
            {
                // Unlike the status bar, navigation-bar contrast enforcement defaults to ON
                window_android.callMethod<void>("setNavigationBarContrastEnforced", "(Z)V", false);
            }
            if (fullscreenMode)
            {
                // When the navbar is hidden, don't force the system bar backgrounds, it disturbs the fullscreen layout
                window_android.callMethod<void>("clearFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            }
            else
            {
                window_android.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            }
            window_android.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
            window_android.callMethod<void>("setNavigationBarColor", "(I)V", color.rgba());
        }
    });
}

void AndroidMobileUI::setTheme_navbar(const MobileUI::Theme theme)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
        {
            // setSystemBarsAppearance // Added in API level 30

            QJniObject inset = getInsetsController();
            if (inset.isValid())
            {
                const int appearance = (theme == MobileUI::Theme::Light) ? APPEARANCE_LIGHT_NAVIGATION_BARS : 0;

                inset.callMethod<void>("setSystemBarsAppearance", "(II)V",
                                       appearance, APPEARANCE_LIGHT_NAVIGATION_BARS);
            }
        }
        else // if (QNativeInterface::QAndroidApplication::sdkVersion() >= 23)
        {
            // getSystemUiVisibility // Added in API level 23 // Deprecated in API level 30

            QJniObject view = getAndroidDecorView();
            if (!view.isValid()) return;

            int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
            if (theme == MobileUI::Theme::Light)
                visibility |= SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            else
                visibility &= ~SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;

            view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
        }
    });
}

/* ************************************************************************** */

void AndroidMobileUI::refreshSafeAreaMetrics()
{
    // While the app is not active its surface may be torn down, and the insets are
    // meaningless anyway: they are read again when the app becomes active.
    if (QGuiApplication::applicationState() != Qt::ApplicationActive) return;

    // Never wait for the Android main thread here: it may be blocked on the Qt thread
    // (ex: an input method query), the signal is emitted from the Android main thread instead.
    const QPointer<AndroidMobileUI> self(this);
    const qreal dpr = devicePixelRatio(m_window);

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([self, dpr]() {
        MobileUI::SafeAreaMetrics m;

        QJniObject insets = getAndroidRootWindowInsets(); // called just once
        if (!insets.isValid()) return; // keep the current values

        const int sdk = QNativeInterface::QAndroidApplication::sdkVersion();

        // System bars: the top/bottom inset
        // side-mounted bars in landscape are folded into the left/right safe areas below

        if (sdk >= 30)
        {
            // status/navigation bar is the top/bottom inset; a side-mounted bar in
            // landscape reads 0 here and is folded into the left/right safe areas below.
            m.statusbarHeight = pxToDip(insetField(insets, "statusBars", "top"), dpr);
            m.navbarHeight = pxToDip(insetField(insets, "navigationBars", "bottom"), dpr);
        }
        else
        {
            m.statusbarHeight = dimenHeight("status_bar_height", 24, dpr);
            m.navbarHeight = dimenHeight("navigation_bar_height", 48, dpr);
        }

        // Screen safe areas: the display cutout (if any)

        QJniObject cutout = insets.callObjectMethod("getDisplayCutout", "()Landroid/view/DisplayCutout;");
        if (cutout.isValid())
        {
            m.top = pxToDip(cutout.callMethod<int>("getSafeInsetTop", "()I"), dpr);
            m.left = pxToDip(cutout.callMethod<int>("getSafeInsetLeft", "()I"), dpr);
            m.right = pxToDip(cutout.callMethod<int>("getSafeInsetRight", "()I"), dpr);
            m.bottom = pxToDip(cutout.callMethod<int>("getSafeInsetBottom", "()I"), dpr);
        }

        // Widened by any side-mounted system bar in landscape on the left/right edges,
        // with or without a display cutout

        int barLeft = 0, barRight = 0;
        if (sdk >= 30)
        {
            barLeft = pxToDip(insetField(insets, "systemBars", "left"), dpr);
            barRight = pxToDip(insetField(insets, "systemBars", "right"), dpr);
        }
        else
        {
            // getSystemWindowInsetLeft/Right // Deprecated in API level 30
            barLeft = pxToDip(insets.callMethod<jint>("getSystemWindowInsetLeft", "()I"), dpr);
            barRight = pxToDip(insets.callMethod<jint>("getSystemWindowInsetRight", "()I"), dpr);
        }
        if (barLeft > m.left) m.left = barLeft;
        if (barRight > m.right) m.right = barRight;

        if (self) Q_EMIT self->safeAreaMetricsUpdated(m);
    });
}

/* ************************************************************************** */

void AndroidMobileUI::refreshKeyboardHeight()
{
    // WindowInsets.Type.ime() // Added in API level 30
    if (QNativeInterface::QAndroidApplication::sdkVersion() < 30)
    {
        Q_EMIT keyboardHeightUpdated(-1);
        return;
    }

    // Never wait for the Android main thread here: this is called from the input method signals,
    // while the Android main thread may be blocked on the Qt thread for an input method query.
    const QPointer<AndroidMobileUI> self(this);
    const qreal dpr = devicePixelRatio(m_window);

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([self, dpr]() {
        int height = -1;

        QJniObject insets = getAndroidRootWindowInsets();
        if (insets.isValid()) height = pxToDip(insetField(insets, "ime", "bottom"), dpr);

        if (self) Q_EMIT self->keyboardHeightUpdated(height);
    });
}

/* ************************************************************************** */

void AndroidMobileUI::refreshScreenBrightness()
{
    // Never wait for the Android main thread here, the signal is emitted from the Android main thread instead.
    const QPointer<AndroidMobileUI> self(this);

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([self]() {
        // The OS-wide brightness (the application override is tracked by MobileUI itself)
        // Settings.System.SCREEN_BRIGHTNESS is an integer in [0, 255].
        constexpr jint brightnessUnavailable = BRIGHTNESS_OVERRIDE_NONE;
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (!activity.isValid()) return;

        QJniObject contentResolver = activity.callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");
        QJniObject SCREEN_BRIGHTNESS = QJniObject::getStaticObjectField("android/provider/Settings$System",
                                                                        "SCREEN_BRIGHTNESS", "Ljava/lang/String;");
        if (!contentResolver.isValid() || !SCREEN_BRIGHTNESS.isValid()) return;

        jint brightnessOS = QJniObject::callStaticMethod<jint>("android/provider/Settings$System", "getInt",
                                                               "(Landroid/content/ContentResolver;Ljava/lang/String;I)I",
                                                               contentResolver.object(), SCREEN_BRIGHTNESS.object<jstring>(),
                                                               brightnessUnavailable);

        if (brightnessOS < 0) return; // unavailable

        constexpr float brightnessMax = 255.f;
        const int brightness = static_cast<int>(std::lround((brightnessOS / brightnessMax) * 100.f));

        if (self) Q_EMIT self->screenBrightnessUpdated(brightness);
    });
}

/* ************************************************************************** */

void AndroidMobileUI::setScreenBrightness(const int value)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject window = getAndroidWindow();
        if (!window.isValid()) return;

        QJniObject layoutParams = window.callObjectMethod("getAttributes", "()Landroid/view/WindowManager$LayoutParams;");
        if (!layoutParams.isValid()) return;

        // A negative value releases the app override and hands brightness back to the system.
        float brightness = BRIGHTNESS_OVERRIDE_NONE;
        if (value >= 0)
        {
            brightness = value / 100.f; // screenBrightness is 0.0 to 1.0
        }

        layoutParams.setField("screenBrightness", brightness);
        window.callMethod<void>("setAttributes", "(Landroid/view/WindowManager$LayoutParams;)V", layoutParams.object());
    });
}

/* ************************************************************************** */

void AndroidMobileUI::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
{
    int value = SCREEN_ORIENTATION_UNSPECIFIED;

    if (orientation == MobileUI::Locked) value = SCREEN_ORIENTATION_LOCKED;
    else if (orientation == MobileUI::Portrait) value = SCREEN_ORIENTATION_PORTRAIT;
    else if (orientation == MobileUI::Portrait_upsidedown) value = SCREEN_ORIENTATION_REVERSE_PORTRAIT;
    else if (orientation == MobileUI::Portrait_sensor) value = SCREEN_ORIENTATION_SENSOR_PORTRAIT;
    else if (orientation == MobileUI::Landscape_left) value = SCREEN_ORIENTATION_LANDSCAPE;
    else if (orientation == MobileUI::Landscape_right) value = SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
    else if (orientation == MobileUI::Landscape_sensor) value = SCREEN_ORIENTATION_SENSOR_LANDSCAPE;

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([value]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
        }
    });
}

void AndroidMobileUI::setScreenAlwaysOn(const bool on)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject window = getAndroidWindow();
        if (!window.isValid()) return;

        if (on)
            window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
        else
            window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
    });
}

void AndroidMobileUI::setScreenSecure(const bool on)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject window = getAndroidWindow();
        if (!window.isValid()) return;

        // FLAG_SECURE blocks screenshots/recording, hides the recent-apps thumbnail,
        // and prevents mirroring to non-secure external displays.
        if (on)
            window.callMethod<void>("addFlags", "(I)V", FLAG_SECURE);
        else
            window.callMethod<void>("clearFlags", "(I)V", FLAG_SECURE);
    });
}

void AndroidMobileUI::setScreenHighRefreshRate(const bool value)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject window = getAndroidWindow();
        if (!window.isValid()) return;

        QJniObject layoutParams = window.callObjectMethod("getAttributes", "()Landroid/view/WindowManager$LayoutParams;");
        if (!layoutParams.isValid()) return;

        int modeId = 0; // 0 = no preference, the system picks the default mode

        if (value)
        {
            QJniObject display = getAndroidDisplay();
            QJniObject current = display.isValid() ? display.callObjectMethod("getMode", "()Landroid/view/Display$Mode;") : QJniObject();
            QJniObject modes = display.isValid() ? display.callObjectMethod("getSupportedModes", "()[Landroid/view/Display$Mode;") : QJniObject();

            if (current.isValid() && modes.isValid())
            {
                // Keep the current resolution, only look for a higher refresh rate
                // (switching resolution would be a visible, unwanted change).
                const int curW = current.callMethod<jint>("getPhysicalWidth", "()I");
                const int curH = current.callMethod<jint>("getPhysicalHeight", "()I");
                float bestRate = current.callMethod<jfloat>("getRefreshRate", "()F");
                modeId = current.callMethod<jint>("getModeId", "()I");

                QJniEnvironment env;
                jobjectArray modeArray = modes.object<jobjectArray>();
                const jsize count = env->GetArrayLength(modeArray);
                for (jsize i = 0; i < count; ++i)
                {
                    QJniObject mode = QJniObject::fromLocalRef(env->GetObjectArrayElement(modeArray, i));
                    if (!mode.isValid()) continue;

                    if (mode.callMethod<jint>("getPhysicalWidth", "()I") != curW) continue;
                    if (mode.callMethod<jint>("getPhysicalHeight", "()I") != curH) continue;

                    const float rate = mode.callMethod<jfloat>("getRefreshRate", "()F");
                    if (rate > bestRate)
                    {
                        bestRate = rate;
                        modeId = mode.callMethod<jint>("getModeId", "()I");
                    }
                }
            }
        }

        // WindowManager.LayoutParams.preferredDisplayModeId // Added in API level 23

        layoutParams.setField("preferredDisplayModeId", modeId);
        window.callMethod<void>("setAttributes", "(Landroid/view/WindowManager$LayoutParams;)V", layoutParams.object());
    });
}

/* ************************************************************************** */

static QJniObject getVibrator()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) return QJniObject();

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 31)
    {
        // vibrator_manager // Added in API level 31

        QJniObject name = QJniObject::fromString("vibrator_manager");
        QJniObject manager = activity.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
                                                       name.object<jstring>());
        if (manager.isValid())
        {
            return manager.callObjectMethod("getDefaultVibrator", "()Landroid/os/Vibrator;");
        }
        return QJniObject();
    }

    QJniObject name = QJniObject::fromString("vibrator");
    return activity.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
                                     name.object<jstring>());
}

static void doVibrate(const QJniObject &vibrator, jint predefinedEffect, jlong oneShotMs)
{
    if (!vibrator.isValid() || !vibrator.callMethod<jboolean>("hasVibrator", "()Z")) return;

    QJniObject effect;
    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
    {
        // createPredefined() // Added in API level 29

        // a nicer, system-tuned effect (EFFECT_TICK/CLICK/HEAVY_CLICK/DOUBLE_CLICK)
        effect = QJniObject::callStaticObjectMethod("android/os/VibrationEffect",
                                                    "createPredefined", "(I)Landroid/os/VibrationEffect;",
                                                    predefinedEffect);
    }
    else
    {
        // createOneShot() // Added in API level 26

        effect = QJniObject::callStaticObjectMethod("android/os/VibrationEffect",
                                                    "createOneShot", "(JI)Landroid/os/VibrationEffect;",
                                                    oneShotMs, static_cast<jint>(DEFAULT_AMPLITUDE));
    }

    if (effect.isValid())
    {
        vibrator.callMethod<void>("vibrate", "(Landroid/os/VibrationEffect;)V", effect.object<jobject>());
    }
}

void AndroidMobileUI::triggerHapticFeedback(const MobileUI::HapticFeedback type)
{
    const int sdk = QNativeInterface::QAndroidApplication::sdkVersion();

    if (sdk >= 30)
    {
        // View.performHapticFeedback() with the CONFIRM/REJECT constants // Added in API level 30
        // System-tuned effects, honoring the user "touch feedback" setting, and no VIBRATE permission needed.

        jint constant = HAPTIC_CONTEXT_CLICK;

        switch (type)
        {
        case MobileUI::HapticSelection:
            constant = (sdk >= 34) ? HAPTIC_SEGMENT_TICK : HAPTIC_CLOCK_TICK;
            break;
        case MobileUI::HapticLight:
            constant = HAPTIC_CONTEXT_CLICK;
            break;
        case MobileUI::HapticMedium:
            constant = HAPTIC_VIRTUAL_KEY;
            break;
        case MobileUI::HapticHeavy:
            constant = HAPTIC_LONG_PRESS;
            break;
        case MobileUI::HapticSuccess:
            constant = HAPTIC_CONFIRM;
            break;
        case MobileUI::HapticWarning:
        case MobileUI::HapticError:
            constant = HAPTIC_REJECT;
            break;
        }

        QNativeInterface::QAndroidApplication::runOnAndroidMainThread([constant]() {
            QJniObject view = getAndroidDecorView();
            if (view.isValid())
            {
                view.callMethod<jboolean>("performHapticFeedback", "(I)Z", constant);
            }
        });
        return;
    }

    // Older devices: map each style to the closest predefined vibration effect (or one-shot duration on API 28).

    jint effect = EFFECT_TICK;
    jlong ms = 20;

    switch (type)
    {
    case MobileUI::HapticSelection:
        effect = EFFECT_TICK;
        ms = 20;
        break;
    case MobileUI::HapticLight:
        effect = EFFECT_TICK;
        ms = 20;
        break;
    case MobileUI::HapticMedium:
        effect = EFFECT_CLICK;
        ms = 30;
        break;
    case MobileUI::HapticHeavy:
        effect = EFFECT_HEAVY_CLICK;
        ms = 40;
        break;
    case MobileUI::HapticSuccess:
        effect = EFFECT_HEAVY_CLICK;
        ms = 30;
        break;
    case MobileUI::HapticWarning:
        effect = EFFECT_DOUBLE_CLICK;
        ms = 40;
        break;
    case MobileUI::HapticError:
        effect = EFFECT_DOUBLE_CLICK;
        ms = 60;
        break;
    }

    if (!m_vibrator.isValid()) m_vibrator = getVibrator();
    doVibrate(m_vibrator, effect, ms);
}

/* ************************************************************************** */

/*!
 * \brief Find the camera driving the torch.
 * \param cameraManager: the CameraManager system service.
 * \return the id of a camera with a flash unit, preferring the back-facing one, or an invalid object if none.
 */
static QJniObject findTorchCameraId(const QJniObject &cameraManager)
{
    QJniObject idList = cameraManager.callObjectMethod("getCameraIdList", "()[Ljava/lang/String;");
    if (!idList.isValid()) return QJniObject();

    // CameraCharacteristics.FLASH_INFO_AVAILABLE (Boolean) and LENS_FACING (Integer)
    QJniObject flashKey = QJniObject::getStaticObjectField("android/hardware/camera2/CameraCharacteristics",
                                                           "FLASH_INFO_AVAILABLE",
                                                           "Landroid/hardware/camera2/CameraCharacteristics$Key;");
    QJniObject facingKey = QJniObject::getStaticObjectField("android/hardware/camera2/CameraCharacteristics",
                                                            "LENS_FACING",
                                                            "Landroid/hardware/camera2/CameraCharacteristics$Key;");
    if (!flashKey.isValid() || !facingKey.isValid()) return QJniObject();

    QJniEnvironment env;
    jobjectArray idArray = idList.object<jobjectArray>();
    const jsize count = env->GetArrayLength(idArray);

    QJniObject torchCameraId;
    for (jsize i = 0; i < count; ++i)
    {
        QJniObject id = QJniObject::fromLocalRef(env->GetObjectArrayElement(idArray, i));
        QJniObject chars = cameraManager.callObjectMethod("getCameraCharacteristics",
                                                          "(Ljava/lang/String;)Landroid/hardware/camera2/CameraCharacteristics;",
                                                          id.object<jstring>());
        if (!chars.isValid()) continue;

        QJniObject hasFlash = chars.callObjectMethod("get", "(Landroid/hardware/camera2/CameraCharacteristics$Key;)Ljava/lang/Object;",
                                                     flashKey.object());
        if (!hasFlash.isValid() || !hasFlash.callMethod<jboolean>("booleanValue", "()Z")) continue;

        torchCameraId = id;

        // LENS_FACING_BACK == 1
        QJniObject facing = chars.callObjectMethod("get", "(Landroid/hardware/camera2/CameraCharacteristics$Key;)Ljava/lang/Object;",
                                                   facingKey.object());

        if (facing.isValid() && facing.callMethod<jint>("intValue", "()I") == 1) break;
    }

    return torchCameraId;
}

bool AndroidMobileUI::setTorch(const bool on)
{
    if (!m_cameraManager.isValid())
    {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (!activity.isValid()) return false;

        QJniObject serviceName = QJniObject::fromString("camera");
        m_cameraManager = activity.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
                                                    serviceName.object<jstring>());
        if (!m_cameraManager.isValid()) return false;
    }

    if (!m_torchCameraId.isValid())
    {
        m_torchCameraId = findTorchCameraId(m_cameraManager);
        if (!m_torchCameraId.isValid()) return false;
    }

    // void setTorchMode() doesn't returns operation status, but may throw CameraAccessException, which we treat that as a failure.
    // we call it through raw JNI, because QJniObject::callMethod() clears any pending exception internally before we can inspect it.

    QJniEnvironment env;
    jmethodID setTorchMode = env.findMethod(m_cameraManager.objectClass(), "setTorchMode", "(Ljava/lang/String;Z)V");
    if (!setTorchMode) return false;

    env->CallVoidMethod(m_cameraManager.object(), setTorchMode, m_torchCameraId.object<jstring>(), static_cast<jboolean>(on));
    if (env.checkAndClearExceptions())
    {
        // The camera may be busy (CameraAccessException) or gone (IllegalArgumentException),
        // so resolve the camera again on the next call.
        m_torchCameraId = QJniObject();
        return false;
    }

    return true;
}

/* ************************************************************************** */

void AndroidMobileUI::backToHomeScreen()
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            // Sends the application to the background
            activity.callMethod<jboolean>("moveTaskToBack", "(Z)Z", true);
        }
    });
}

/* ************************************************************************** */

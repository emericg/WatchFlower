/*!
 * Copyright (c) 2017 Ekkehard Gentz (ekke)
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

#include "MobileSharing_DocumentProvider.h"

#include <QStandardPaths>
#include <QDir>

#if defined(Q_OS_ANDROID)
#include <QDebug>
#include <QCoreApplication>
#include <QJniObject>
#endif

/* ************************************************************************** */

DocumentProvider::DocumentProvider(QObject *parent) : QObject(parent)
{
    // Default exposed directory: a persistent, app-owned folder (NOT the module's session-wiped
    // cache), under the app's own data location.
    m_dir = defaultDirectory();

#if defined(Q_OS_ANDROID)
    // Make sure the Java side knows the Activity (idempotent; AndroidShareUtils also sets it, but
    // this keeps the feature self-sufficient regardless of construction order).
    QJniObject jni("io/emeric/mobilesharing/QShareUtils");
    if (jni.isValid())
    {
        jni.callMethod<void>("setActivity", "(Landroid/app/Activity;)V",
                             QNativeInterface::QAndroidApplication::context().object());
    }

    // The provider keeps serving across app exits/reboots from its own persisted state, so seed our
    // in-memory state from it: otherwise 'enabled' would read false on a fresh launch while the
    // provider is actually still sharing. We only read here (no apply()): the persisted config
    // (in SharedPreferences, read by QShareDocumentProvider) is already the source of truth.
    const QString persistedDir = QJniObject::callStaticMethod<jstring>("io/emeric/mobilesharing/QShareUtils",
                                                                       "getSharedDirectory", "()Ljava/lang/String;").toString();
    const QString persistedTitle = QJniObject::callStaticMethod<jstring>("io/emeric/mobilesharing/QShareUtils",
                                                                         "getSharedDirectoryTitle", "()Ljava/lang/String;").toString();
    if (!persistedDir.isEmpty()) m_dir = persistedDir;
    if (!persistedTitle.isEmpty()) m_title = persistedTitle;
    m_writable = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils",
                                                        "getSharedDirectoryWritable", "()Z");
    m_enabled = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils",
                                                       "getDocumentProviderEnabled", "()Z");
#endif
}

QString DocumentProvider::defaultDirectory()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/MobileSharing/shared";
}

void DocumentProvider::apply()
{
#if defined(Q_OS_ANDROID)
    // Hand the full state to Java, which persists it in SharedPreferences for QShareDocumentProvider
    // and notifies SAF so any open picker refreshes its roots. The read/write decision stays here
    // (m_writable) - currently forced read-only.
    QJniObject jsDir = QJniObject::fromString(m_dir);
    QJniObject jsTitle = QJniObject::fromString(m_title);
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils", "setDocumentProvider",
                                                         "(ZLjava/lang/String;ZLjava/lang/String;)Z",
                                                         m_enabled, jsDir.object<jstring>(), m_writable, jsTitle.object<jstring>());
    if (!ok)
    {
        qWarning() << "DocumentProvider: failed to apply config (enabled=" << m_enabled << "dir=" << m_dir << ")";
    }
#endif
}

bool DocumentProvider::enabled() const
{
    return m_enabled;
}

void DocumentProvider::setEnabled(bool enabled)
{
    if (enabled == m_enabled) return;

    m_enabled = enabled;
    if (enabled)
    {
        // Make sure the exposed directory exists before the provider advertises it.
        QDir().mkpath(m_dir);
    }

    apply();
    Q_EMIT enabledChanged();
}

QString DocumentProvider::title() const
{
    return m_title;
}

void DocumentProvider::setTitle(const QString &title)
{
    if (m_title != title)
    {
        m_title = title;
        if (m_enabled) apply();

        Q_EMIT titleChanged();
    }
}

QString DocumentProvider::sharedDirectory() const
{
    return m_dir;
}

void DocumentProvider::setSharedDirectory(const QString &absolutePath)
{
    const QString newDir = absolutePath.isEmpty() ? defaultDirectory() : absolutePath;

    if (m_dir != newDir)
    {
        m_dir = newDir;
        if (m_enabled)
        {
            QDir().mkpath(m_dir);
            apply();
        }

        Q_EMIT sharedDirectoryChanged();
    }
}

/* ************************************************************************** */

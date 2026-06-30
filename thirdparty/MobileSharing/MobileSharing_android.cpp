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

#include "MobileSharing_android.h"

#include <QUrl>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>

#include <QCoreApplication>
#include <QJniObject>
#include <QJniEnvironment>
#include <jni.h>

/* ************************************************************************** */

AndroidShareUtils *AndroidShareUtils::mInstance = nullptr;

/* ************************************************************************** */

// JNI bridges: implements the 'native' methods declared in QShareActivity.java.
// Registered at runtime via QJniEnvironment::registerNativeMethods() (Qt already owns JNI_OnLoad, so we must not define our own).
// Each call is forwarded to the AndroidShareUtils singleton;
// cross-thread delivery to QML is handled by the queued signal/slot connections in MobileSharing.

extern "C"
{

static void jni_setFileReceived(JNIEnv */*env*/, jobject /*thiz*/, jstring path)
{
    AndroidShareUtils::getInstance()->setFileReceived(QJniObject(path).toString());
}

static void jni_fireSaveResult(JNIEnv */*env*/, jobject /*thiz*/, jint requestCode, jboolean success, jboolean canceled)
{
    AndroidShareUtils::getInstance()->onSaveResult(requestCode, success, canceled);
}

} // extern "C"

static void registerNativeMethods()
{
    const JNINativeMethod methods[] = {
        {"setFileReceived",    "(Ljava/lang/String;)V", reinterpret_cast<void *>(jni_setFileReceived)},
        {"fireSaveResult",     "(IZZ)V",                reinterpret_cast<void *>(jni_fireSaveResult)},
    };

    QJniEnvironment env;
    if (!env.registerNativeMethods("io/emeric/mobilesharing/QShareActivity", methods,
                                   sizeof(methods) / sizeof(methods[0])))
    {
        qWarning() << "MobileSharing: failed to register QShareActivity native methods";
    }
}

/* ************************************************************************** */

AndroidShareUtils::AndroidShareUtils(QObject *parent) : PlatformShareUtils(parent)
{
    // We need the instance for JNI Call
    mInstance = this;

    // Bind the QShareActivity 'native' methods to our JNI bridge (once)
    static bool nativesRegistered = false;
    if (!nativesRegistered)
    {
        registerNativeMethods();
        nativesRegistered = true;
    }

    QJniObject jni = QJniObject("io/emeric/mobilesharing/QShareUtils");

    if (jni.isValid())
    {
        qDebug() << "Init Activity of AndroidShareUtils";
        jni.callMethod<void>("setActivity", "(Landroid/app/Activity;)V",
                             QNativeInterface::QAndroidApplication::context().object());
    }
}

AndroidShareUtils *AndroidShareUtils::getInstance()
{
    // Always created first by MobileSharing's constructor (which wires up the signals)
    Q_ASSERT(mInstance);
    return mInstance;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool AndroidShareUtils::checkMimeTypeView(const QString &mimeType)
{
    QJniObject jsMime = QJniObject::fromString(mimeType);
    jboolean verified = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils",
                                                               "checkMimeTypeView",
                                                               "(Ljava/lang/String;)Z",
                                                               jsMime.object<jstring>());

    //qDebug() << "View VERIFIED: " << mimeType << " - " << verified;
    return verified;
}

bool AndroidShareUtils::isShareablePath(const QString &filePath) const
{
    // FileProvider (res/xml/filepaths.xml) only exposes <cache>/MobileSharing by default,
    // so a path is serviceable if it lives there (our incoming/ and outgoing/ dirs).
    // Anything else should be copied into outgoing/ before sharing.

    const QString abs = QFileInfo(filePath).absoluteFilePath();
    const QString root = cacheRootDir();

    return ((abs == root) || abs.startsWith(root + '/'));
}

QString AndroidShareUtils::ensureShareableFile(const QString &filePath, bool move)
{
    QFileInfo fi(filePath);
    if (!fi.exists() || !fi.isFile())
    {
        qWarning() << "ensureShareableFile: not a file:" << filePath;
        return QString();
    }

    // Already serviceable and the caller keeps ownership -> use it in place.
    if (!move && isShareablePath(fi.absoluteFilePath())) return fi.absoluteFilePath();

    const QString outDir = cacheOutgoingDir();
    QDir().mkpath(outDir);

    QString dest = outDir + '/' + fi.fileName();
    if (QFileInfo::exists(dest))
    {
        // don't clobber another file of the same name this session
        dest = outDir + '/' + QString::number(QDateTime::currentMSecsSinceEpoch()) + '_' + fi.fileName();
    }

    if (move)
    {
        if (QFile::rename(filePath, dest)) return dest; // fast path (same filesystem)
        if (QFile::copy(filePath, dest)) { QFile::remove(filePath); return dest; } // cross-filesystem fallback
    }
    else
    {
        if (QFile::copy(filePath, dest)) return dest;
    }

    qWarning() << "ensureShareableFile: failed to" << (move ? "move" : "copy") << filePath << "->" << dest;
    return QString();
}

/* ************************************************************************** */

void AndroidShareUtils::sendText(const QString &text, const QString &subject, const QUrl &url)
{
    QJniObject jsText = QJniObject::fromString(text);
    QJniObject jsSubject = QJniObject::fromString(subject);
    QJniObject jsUrl = QJniObject::fromString(url.toString());
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils",
                                                         "sendText", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z",
                                                         jsText.object<jstring>(), jsSubject.object<jstring>(), jsUrl.object<jstring>());

    if (!ok)
    {
        qWarning() << "Unable to resolve activity from Java";
        Q_EMIT shareNoAppAvailable(0);
    }
}

/* ************************************************************************** */

/*
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::sendFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, int requestId, bool move)
{
    // Make sure the path is something FileProvider can serve (copy/move into our outgoing dir if needed).
    // 'move' just relocates throwaway files and deletes the original.
    const QString newFilePath = ensureShareableFile(filePath, move);
    if (newFilePath.isEmpty())
    {
        Q_EMIT shareError(requestId, QString("Cannot share file: %1").arg(filePath));
        return;
    }

    qDebug() << __FUNCTION__ << newFilePath;

    QJniObject jsPath = QJniObject::fromString(newFilePath);
    QJniObject jsTitle = QJniObject::fromString(title);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils", "sendFile",
                                                         "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                                         jsPath.object<jstring>(), jsTitle.object<jstring>(),
                                                         jsMimeType.object<jstring>(), requestId);
    if (!ok)
    {
        qWarning() << "Unable to resolve activity from Java";
        Q_EMIT shareNoAppAvailable(requestId);
    }
    return;
}

/* ************************************************************************** */

void AndroidShareUtils::sendFiles(const QStringList &filePaths, const QString &title,
                                  const QString &mimeType, int requestId, bool move)
{
    // Make every path FileProvider-serviceable (copy/move into our outgoing dir if needed);
    // skip the ones that can't be prepared rather than failing the whole batch.
    QStringList shareable;
    for (const QString &p : filePaths)
    {
        const QString sp = ensureShareableFile(p, move);
        if (!sp.isEmpty()) shareable.append(sp);
        else qWarning() << "sendFiles: skipping unshareable file:" << p;
    }
    if (shareable.isEmpty())
    {
        Q_EMIT shareError(requestId, QStringLiteral("Cannot share files: none were shareable"));
        return;
    }

    // Build a Java String[] of the prepared paths for QShareUtils.sendFiles().
    QJniEnvironment env;
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray jpaths = env->NewObjectArray(shareable.size(), stringClass, nullptr);
    for (int i = 0; i < shareable.size(); ++i)
    {
        QJniObject s = QJniObject::fromString(shareable.at(i));
        env->SetObjectArrayElement(jpaths, i, s.object<jstring>());
    }

    QJniObject jsTitle = QJniObject::fromString(title);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils", "sendFiles",
                                                         "([Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                                         jpaths, jsTitle.object<jstring>(),
                                                         jsMimeType.object<jstring>(), requestId);
    env->DeleteLocalRef(jpaths);
    env->DeleteLocalRef(stringClass);

    if (!ok)
    {
        qWarning() << "Unable to resolve activity from Java";
        Q_EMIT shareNoAppAvailable(requestId);
    }
}

/* ************************************************************************** */

/*
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::viewFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, int requestId)
{
    const QString newFilePath = ensureShareableFile(filePath, false);
    if (newFilePath.isEmpty())
    {
        Q_EMIT shareError(requestId, QString("Cannot view file: %1").arg(filePath));
        return;
    }

    QJniObject jsPath = QJniObject::fromString(newFilePath);
    QJniObject jsTitle = QJniObject::fromString(title);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils", "viewFile",
                                                         "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                                         jsPath.object<jstring>(), jsTitle.object<jstring>(),
                                                         jsMimeType.object<jstring>(), requestId);
    if (!ok)
    {
        qWarning() << "Unable to resolve activity from Java";
        Q_EMIT shareNoAppAvailable(requestId);
    }
}

/* ************************************************************************** */

void AndroidShareUtils::saveFile(const QString &filePath, const QString &suggestedName,
                                 const QString &mimeType, int requestId)
{
    // Hand the source path + suggested name to Java, which launches ACTION_CREATE_DOCUMENT
    // and (on result) streams our bytes into the chosen destination via the ContentResolver.
    // The outcome comes back asynchronously through jni_fireSaveResult() -> onSaveResult().
    QJniObject jsPath = QJniObject::fromString(filePath);
    QJniObject jsName = QJniObject::fromString(suggestedName);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);

    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/mobilesharing/QShareUtils", "saveFile",
                                                         "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                                         jsPath.object<jstring>(), jsName.object<jstring>(),
                                                         jsMimeType.object<jstring>(), requestId);
    if (!ok)
    {
        qWarning() << "saveFile: could not start the document creation activity";
        Q_EMIT shareError(requestId, QString("Cannot save file: %1").arg(filePath));
    }
}

/* ************************************************************************** */

void AndroidShareUtils::onSaveResult(int requestCode, bool success, bool canceled)
{
    qDebug() << "onSaveResult requestCode:" << requestCode << "success:" << success << "canceled:" << canceled;

    if (success)
    {
        Q_EMIT fileSaved(requestCode);
    }
    else if (canceled)
    {
        Q_EMIT shareFinished(requestCode);
    }
    else
    {
        Q_EMIT shareError(requestCode, "Save: could not write the file to the chosen location");
    }
}

/* ************************************************************************** */

void AndroidShareUtils::checkPendingIntents(const QString &workingDirPath)
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        // Receiving requires QShareActivity (it overrides onNewIntent/onActivityResult and exposes checkPendingIntents).
        QJniEnvironment env;
        jclass shareActivityClass = env.findClass("io/emeric/mobilesharing/QShareActivity");
        if (shareActivityClass && !env->IsInstanceOf(activity.object(), shareActivityClass))
        {
            //qWarning() << "MobileSharing: the running Activity is not a QShareActivity, incoming files will NOT be received."
            return;
        }

        // create a Java String for the Working Dir Path
        QJniObject jniWorkingDir = QJniObject::fromString(workingDirPath);
        if (!jniWorkingDir.isValid())
        {
            qWarning() << "QJniObject jniWorkingDir not valid.";
            Q_EMIT shareError(0, "WorkingDir not valid");
            return;
        }
        activity.callMethod<void>("checkPendingIntents", "(Ljava/lang/String;)V", jniWorkingDir.object<jstring>());
        qDebug() << "checkPendingIntents: " << workingDirPath;
        return;
    }
    qDebug() << "checkPendingIntents: Activity not valid";
}

/* ************************************************************************** */

void AndroidShareUtils::setFileReceived(const QString &filePath)
{
    if (filePath.isEmpty())
    {
        qWarning() << "setFileReceived: empty path received";
        Q_EMIT shareError(0, "Empty path received");
        return;
    }

    // Java already copied the incoming content into our cache and hands us a plain filesystem path
    // Strip the 'file://' prefix just in case...
    QString path = filePath.startsWith("file://") ? filePath.mid(7) : filePath;

    if (QFileInfo::exists(path))
    {
        qDebug() << "setFileReceived:" << path;
        Q_EMIT fileReceived(path);
    }
    else
    {
        qDebug() << "setFileReceived: file does NOT exist:" << path;
        Q_EMIT shareError(0, QString("File does not exist: %1").arg(path));
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

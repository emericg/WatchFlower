/*
 * Copyright (c) 2017 Ekkehard Gentz (ekke)
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

#include "SharingUtils_android.h"

#include <QUrl>
#include <QFileInfo>
#include <QDateTime>

#include <QCoreApplication>
#include <QtCore/private/qandroidextras_p.h>
#include <QJniObject>

/* ************************************************************************** */

const static int RESULT_OK = -1;
const static int RESULT_CANCELED = 0;

AndroidShareUtils *AndroidShareUtils::mInstance = nullptr;

/* ************************************************************************** */

AndroidShareUtils::AndroidShareUtils(QObject* parent) : PlatformShareUtils(parent)
{
    // we need the instance for JNI Call
    mInstance = this;
}

AndroidShareUtils *AndroidShareUtils::getInstance()
{
    if (!mInstance)
    {
        mInstance = new AndroidShareUtils;
    }

    return mInstance;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool AndroidShareUtils::checkMimeTypeView(const QString &mimeType)
{
    QJniObject jsMime = QJniObject::fromString(mimeType);
    jboolean verified = QJniObject::callStaticMethod<jboolean>(
                            "com/emeric/utils/QShareUtils",
                            "checkMimeTypeView",
                            "(Ljava/lang/String;)Z",
                            jsMime.object<jstring>());

    //qDebug() << "View VERIFIED: " << mimeType << " - " << verified;
    return verified;
}

bool AndroidShareUtils::checkMimeTypeEdit(const QString &mimeType)
{
    QJniObject jsMime = QJniObject::fromString(mimeType);
    jboolean verified = QJniObject::callStaticMethod<jboolean>(
                            "com/emeric/utils/QShareUtils",
                            "checkMimeTypeEdit",
                            "(Ljava/lang/String;)Z",
                            jsMime.object<jstring>());

    //qDebug() << "Edit VERIFIED: " << mimeType << " - " << verified;
    return verified;
}

void AndroidShareUtils::share(const QString &text, const QUrl &url)
{
    QJniObject jsText = QJniObject::fromString(text);
    QJniObject jsUrl = QJniObject::fromString(url.toString());
    jboolean ok = QJniObject::callStaticMethod<jboolean>(
                      "com/emeric/utils/QShareUtils",
                      "share",
                      "(Ljava/lang/String;Ljava/lang/String;)Z",
                      jsText.object<jstring>(), jsUrl.object<jstring>());

    if (!ok)
    {
        qWarning() << "Unable to resolve activity from Java";
        Q_EMIT shareNoAppAvailable(0);
    }
}

/* ************************************************************************** */

/*
 * As default we're going the Java - way with one simple JNI call (recommended)
 * if mAltImpl is true we're going the pure JNI way
 *
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::sendFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, const int &requestId)
{
    mIsEditMode = false;

    if (!mAltImpl)
    {
        QJniObject jsPath = QJniObject::fromString(filePath);
        QJniObject jsTitle = QJniObject::fromString(title);
        QJniObject jsMimeType = QJniObject::fromString(mimeType);
        jboolean ok = QJniObject::callStaticMethod<jboolean>(
                                            "com/emeric/utils/QShareUtils",
                                            "sendFile",
                                            "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                            jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>(), requestId);
        if (!ok)
        {
            qWarning() << "Unable to resolve activity from Java";
            Q_EMIT shareNoAppAvailable(requestId);
        }
        return;
    }

    // THE FILE PATH
    // to get a valid Path we must prefix file://
    // attention file must be inside Users Documents folder !
    // trying to send a file from APP DATA will fail
    QJniObject jniPath = QJniObject::fromString("file://" + filePath);
    if (!jniPath.isValid())
    {
        qWarning() << "QJniObject jniPath not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nFilePath not valid");
        return;
    }
    // next step: convert filePath Java String into Java Uri
    QJniObject jniUri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
    if (!jniUri.isValid())
    {
        qWarning() << "QJniObject jniUri not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nURI not valid");
        return;
    }

    // THE INTENT ACTION
    // create a Java String for the ACTION
    QJniObject jniAction = QJniObject::getStaticObjectField<jstring>("android/content/Intent", "ACTION_SEND");
    if (!jniAction.isValid())
    {
        qWarning() << "QJniObject jniParam not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }
    // then create the Intent Object for this Action
    QJniObject jniIntent("android/content/Intent", "(Ljava/lang/String;)V",jniAction.object<jstring>());
    if (!jniIntent.isValid())
    {
        qWarning() << "QJniObject jniIntent not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    // THE MIME TYPE
    if (mimeType.isEmpty())
    {
        qWarning() << "mime type is empty";
        Q_EMIT shareError(requestId, "Share: an Error occured\nMimeType is empty");
        return;
    }
    // create a Java String for the File Type (Mime Type)
    QJniObject jniMimeType = QJniObject::fromString(mimeType);
    if (!jniMimeType.isValid())
    {
        qWarning() << "QJniObject jniMimeType not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nMimeType not valid");
        return;
    }
    // set Type (MimeType)
    QJniObject jniType = jniIntent.callObjectMethod("setType", "(Ljava/lang/String;)Landroid/content/Intent;", jniMimeType.object<jstring>());
    if (!jniType.isValid())
    {
        qWarning() << "QJniObject jniType not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    // THE EXTRA STREAM
    // create a Java String for the EXTRA
    QJniObject jniExtra = QJniObject::getStaticObjectField<jstring>("android/content/Intent", "EXTRA_STREAM");
    if (!jniExtra.isValid())
    {
        qWarning() << "QJniObject jniExtra not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }
    // put Extra (EXTRA_STREAM and URI)
    //QJniObject jniExtraStreamUri = jniIntent.callObjectMethod("putExtra", "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", jniExtra.object<jstring>(), jniExtra.object<jstring>());
    QJniObject jniExtraStreamUri = jniIntent.callObjectMethod("putExtra", "(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;", jniExtra.object<jstring>(), jniUri.object<jobject>());
    if (!jniExtraStreamUri.isValid())
    {
        qWarning() << "QJniObject jniExtraStreamUri not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    QJniObject packageManager = activity.callObjectMethod("getPackageManager",
                                                          "()Landroid/content/pm/PackageManager;");
    QJniObject componentName = jniIntent.callObjectMethod("resolveActivity",
                                                          "(Landroid/content/pm/PackageManager;)Landroid/content/ComponentName;",
                                                          packageManager.object());
    if (!componentName.isValid())
    {
        qWarning() << "Unable to resolve activity";
        Q_EMIT shareNoAppAvailable(requestId);
        return;
    }

    if (requestId <= 0)
    {
        // we dont need a result if there's no requestId
        QtAndroidPrivate::startActivity(jniIntent, requestId);
    }
    else
    {
        // we have the JNI Object, know the requestId
        // and want the Result back into 'this' handleActivityResult(...)
        // attention: to test JNI with QAndroidActivityResultReceiver you must comment or rename
        // onActivityResult() method in QShareActivity.java - otherwise you'll get wrong request or result codes
        QtAndroidPrivate::startActivity(jniIntent, requestId, this);
    }
}

/* ************************************************************************** */

/*
 * As default we're going the Java - way with one simple JNI call (recommended)
 * if mAltImpl is true we're going the pure JNI way
 *
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::viewFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, const int &requestId)
{
    mIsEditMode = false;

    if (!mAltImpl)
    {
        QJniObject jsPath = QJniObject::fromString(filePath);
        QJniObject jsTitle = QJniObject::fromString(title);
        QJniObject jsMimeType = QJniObject::fromString(mimeType);
        jboolean ok = QJniObject::callStaticMethod<jboolean>("com/emeric/utils/QShareUtils",
                          "viewFile",
                          "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                          jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>(), requestId);
        if (!ok)
        {
            qWarning() << "Unable to resolve activity from Java";
            Q_EMIT shareNoAppAvailable(requestId);
        }
        return;
    }

    // THE FILE PATH
    // to get a valid Path we must prefix file://
    // attention file must be inside Users Documents folder !
    // trying to view or edit a file from APP DATA will fail
    QJniObject jniPath = QJniObject::fromString("file://" + filePath);
    if (!jniPath.isValid())
    {
        qWarning() << "QJniObject jniPath not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nFilePath not valid");
        return;
    }
    // next step: convert filePath Java String into Java Uri
    QJniObject jniUri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
    if (!jniUri.isValid())
    {
        qWarning() << "QJniObject jniUri not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nURI not valid");
        return;
    }

    // THE INTENT ACTION
    // create a Java String for the ACTION
    QJniObject jniParam = QJniObject::getStaticObjectField<jstring>("android/content/Intent", "ACTION_VIEW");
    if (!jniParam.isValid())
    {
        qWarning() << "QJniObject jniParam not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }
    // then create the Intent Object for this Action
    QJniObject jniIntent("android/content/Intent", "(Ljava/lang/String;)V", jniParam.object<jstring>());
    if (!jniIntent.isValid())
    {
        qWarning() << "QJniObject jniIntent not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    // THE FILE TYPE
    if (mimeType.isEmpty())
    {
        qWarning() << "mime type is empty";
        Q_EMIT shareError(requestId, "Share: an Error occured\nMimeType is empty");
        return;
    }
    // create a Java String for the File Type (Mime Type)
    QJniObject jniType = QJniObject::fromString(mimeType);
    if (!jniType.isValid())
    {
        qWarning() << "QJniObject jniType not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nMimeType not valid");
        return;
    }
    // set Data (the URI) and Type (MimeType)
    QJniObject jniResult = jniIntent.callObjectMethod("setDataAndType",
                                                      "(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;",
                                                      jniUri.object<jobject>(), jniType.object<jstring>());
    if (!jniResult.isValid())
    {
        qWarning() << "QJniObject jniResult not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    QJniObject packageManager = activity.callObjectMethod("getPackageManager",
                                                          "()Landroid/content/pm/PackageManager;");
    QJniObject componentName = jniIntent.callObjectMethod("resolveActivity",
                                                          "(Landroid/content/pm/PackageManager;)Landroid/content/ComponentName;",
                                                          packageManager.object());
    if (!componentName.isValid())
    {
        qWarning() << "Unable to resolve activity";
        Q_EMIT shareNoAppAvailable(requestId);
        return;
    }

    if (requestId <= 0)
    {
        // we dont need a result if there's no requestId
        QtAndroidPrivate::startActivity(jniIntent, requestId);
    }
    else
    {
        // we have the JNI Object, know the requestId
        // and want the Result back into 'this' handleActivityResult(...)
        // attention: to test JNI with QAndroidActivityResultReceiver you must comment or rename
        // onActivityResult() method in QShareActivity.java - otherwise you'll get wrong request or result codes
        QtAndroidPrivate::startActivity(jniIntent, requestId, this);
    }
}

/* ************************************************************************** */

/*
 * As default we're going the Java - way with one simple JNI call (recommended)
 * if mAltImpl is true we're going the pure JNI way
 *
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::editFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, const int &requestId)
{
    mIsEditMode = true;
    mCurrentFilePath = filePath;
    QFileInfo fileInfo = QFileInfo(mCurrentFilePath);

    mLastModified = fileInfo.lastModified().toSecsSinceEpoch();
    qDebug() << "LAST MODIFIED: " << mLastModified;

    if (!mAltImpl)
    {
        QJniObject jsPath = QJniObject::fromString(filePath);
        QJniObject jsTitle = QJniObject::fromString(title);
        QJniObject jsMimeType = QJniObject::fromString(mimeType);

        jboolean ok = QJniObject::callStaticMethod<jboolean>("com/emeric/utils/QShareUtils",
                                                             "editFile",
                                                             "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                                             jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>(), requestId);

        if (!ok)
        {
            qWarning() << "Unable to resolve activity from Java";
            Q_EMIT shareNoAppAvailable(requestId);
        }
        return;
    }

    // THE FILE PATH
    // to get a valid Path we must prefix file://
    // attention file must be inside Users Documents folder !
    // trying to view or edit a file from APP DATA will fail
    QJniObject jniPath = QJniObject::fromString("file://" + filePath);
    if (!jniPath.isValid())
    {
        qWarning() << "QJniObject jniPath not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nFilePath not valid");
        return;
    }
    // next step: convert filePath Java String into Java Uri
    QJniObject jniUri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
    if (!jniUri.isValid())
    {
        qWarning() << "QJniObject jniUri not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nURI not valid");
        return;
    }

    // THE INTENT ACTION
    // create a Java String for the ACTION
    QJniObject jniParam = QJniObject::getStaticObjectField<jstring>("android/content/Intent", "ACTION_EDIT");
    if (!jniParam.isValid())
    {
        qWarning() << "QJniObject jniParam not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }
    // then create the Intent Object for this Action
    QJniObject jniIntent("android/content/Intent", "(Ljava/lang/String;)V", jniParam.object<jstring>());
    if (!jniIntent.isValid())
    {
        qWarning() << "QJniObject jniIntent not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    // THE FILE TYPE
    if (mimeType.isEmpty())
    {
        qWarning() << "mime type is empty";
        Q_EMIT shareError(requestId, "Share: an Error occured\nMimeType is empty");
        return;
    }
    // create a Java String for the File Type (Mime Type)
    QJniObject jniType = QJniObject::fromString(mimeType);
    if (!jniType.isValid())
    {
        qWarning() << "QJniObject jniType not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured\nMimeType not valid");
        return;
    }
    // set Data (the URI) and Type (MimeType)
    QJniObject jniResult = jniIntent.callObjectMethod("setDataAndType",
                                                      "(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;",
                                                      jniUri.object<jobject>(),
                                                      jniType.object<jstring>());
    if (!jniResult.isValid())
    {
        qWarning() << "QJniObject jniResult not valid.";
        Q_EMIT shareError(requestId, "Share: an Error occured");
        return;
    }

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    QJniObject packageManager = activity.callObjectMethod("getPackageManager",
                                                          "()Landroid/content/pm/PackageManager;");
    QJniObject componentName = jniIntent.callObjectMethod("resolveActivity",
                                                          "(Landroid/content/pm/PackageManager;)Landroid/content/ComponentName;",
                                                          packageManager.object());
    if (!componentName.isValid())
    {
        qWarning() << "Unable to resolve activity";
        Q_EMIT shareNoAppAvailable(requestId);
        return;
    }

    // now all is ready to start the Activity:
    if (requestId <= 0)
    {
        // we dont need a result if there's no requestId
        QtAndroidPrivate::startActivity(jniIntent, requestId);
    }
    else
    {
        // we have the JNI Object, know the requestId
        // and want the Result back into 'this' handleActivityResult(...)
        // attention: to test JNI with QAndroidActivityResultReceiver you must comment or rename
        // onActivityResult() method in QShareActivity.java - otherwise you'll get wrong request or result codes
        QtAndroidPrivate::startActivity(jniIntent, requestId, this);
    }
}

/* ************************************************************************** */

// used from QAndroidActivityResultReceiver
void AndroidShareUtils::handleActivityResult(int receiverRequestCode, int resultCode, const QJniObject &data)
{
    Q_UNUSED(data)
    qDebug() << "From JNI QAndroidActivityResultReceiver: " << receiverRequestCode << "ResultCode:" << resultCode;
    processActivityResult(receiverRequestCode, resultCode);
}

// used from Activity.java onActivityResult()
void AndroidShareUtils::onActivityResult(int requestCode, int resultCode)
{
    qDebug() << "From Java Activity onActivityResult: " << requestCode << "ResultCode:" << resultCode;
    processActivityResult(requestCode, resultCode);
}

void AndroidShareUtils::processActivityResult(int requestCode, int resultCode)
{
    if (resultCode == RESULT_OK)
    {
        // only if edit is done
        Q_EMIT shareEditDone(requestCode);
    }
    else if (resultCode == RESULT_CANCELED)
    {
        if (mIsEditMode)
        {
            // Attention: not all Apps will give you the correct ResultCode:
            // Google Fotos will send OK if saved and CANCELED if canceled
            // Some Apps always sends CANCELED even if you modified and Saved the File
            // so you should check the modified Timestamp of the File to know if
            // you should Q_EMIT shareEditDone() or shareFinished() !!!
            QFileInfo fileInfo = QFileInfo(mCurrentFilePath);
            qint64 currentModified = fileInfo.lastModified().toSecsSinceEpoch();
            qDebug() << "CURRENT MODIFIED: " << currentModified;
            if (currentModified > mLastModified)
            {
                Q_EMIT shareEditDone(requestCode);
                return;
            }
        }
        Q_EMIT shareFinished(requestCode);
    }
    else
    {
        qDebug() << "wrong result code: " << resultCode << " from request: " << requestCode;
        Q_EMIT shareError(requestCode, "Share: an Error occured");
    }
}

void AndroidShareUtils::checkPendingIntents(const QString workingDirPath)
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        // create a Java String for the Working Dir Path
        QJniObject jniWorkingDir = QJniObject::fromString(workingDirPath);
        if (!jniWorkingDir.isValid())
        {
            qWarning() << "QJniObject jniWorkingDir not valid.";
            Q_EMIT shareError(0, "Share: an Error occured\nWorkingDir not valid");
            return;
        }
        activity.callMethod<void>("checkPendingIntents", "(Ljava/lang/String;)V", jniWorkingDir.object<jstring>());
        qDebug() << "checkPendingIntents: " << workingDirPath;
        return;
    }
    qDebug() << "checkPendingIntents: Activity not valid";
}

void AndroidShareUtils::setFileUrlReceived(const QString &url)
{
    if (url.isEmpty())
    {
        qWarning() << "setFileUrlReceived: we got an empty URL";
        Q_EMIT shareError(0, "Empty URL received");
        return;
    }
    qDebug() << "AndroidShareUtils setFileUrlReceived: we got the File URL from JAVA: " << url;
    QString myUrl;
    if (url.startsWith("file://"))
    {
        myUrl = url.right(url.length() - 7);
        qDebug() << "QFile needs this URL: " << myUrl;
    }
    else
    {
        myUrl = url;
    }

    // check if File exists
    QFileInfo fileInfo = QFileInfo(myUrl);
    if (fileInfo.exists())
    {
        Q_EMIT fileUrlReceived(myUrl);
    }
    else
    {
        qDebug() << "setFileUrlReceived: FILE does NOT exist ";
        Q_EMIT shareError(0, QString("File does not exist: %1").arg(myUrl));
    }
}

void AndroidShareUtils::setFileReceivedAndSaved(const QString &url)
{
    if (url.isEmpty())
    {
        qWarning() << "setFileReceivedAndSaved: we got an empty URL";
        Q_EMIT shareError(0, "Empty URL received");
        return;
    }
    qDebug() << "AndroidShareUtils setFileReceivedAndSaved: we got the File URL from JAVA: " << url;
    QString myUrl;
    if (url.startsWith("file://"))
    {
        myUrl = url.right(url.length() - 7);
        qDebug() << "QFile needs this URL: " << myUrl;
    }
    else
    {
        myUrl = url;
    }

    // check if File exists
    QFileInfo fileInfo = QFileInfo(myUrl);
    if (fileInfo.exists())
    {
        Q_EMIT fileReceivedAndSaved(myUrl);
    }
    else
    {
        qDebug() << "setFileReceivedAndSaved: FILE does NOT exist ";
        Q_EMIT shareError(0, QString("File does not exist: %1").arg(myUrl));
    }
}

// to be safe we check if a File Url from java really exists for Qt
// if not on the Java side we'll try to read the content as Stream
bool AndroidShareUtils::checkFileExits(const QString &url)
{
    if (url.isEmpty())
    {
        qWarning() << "checkFileExits: we got an empty URL";
        Q_EMIT shareError(0, "Empty URL received");
        return false;
    }
    qDebug() << "AndroidShareUtils checkFileExits: we got the File URL from JAVA: " << url;
    QString myUrl;
    if (url.startsWith("file://"))
    {
        myUrl = url.right(url.length()-7);
        qDebug() << "QFile needs this URL: " << myUrl;
    }
    else
    {
        myUrl = url;
    }

    // check if File exists
    QFileInfo fileInfo = QFileInfo(myUrl);
    if (fileInfo.exists())
    {
        qDebug() << "Yep: the File exists for Qt";
        return true;
    }
    else
    {
        qDebug() << "Uuups: FILE does NOT exist ";
        return false;
    }
}

// instead of defining all JNICALL as demonstrated below
// there's another way, making it easier to manage all the methods
// see https://www.kdab.com/qt-android-episode-5/

/* ************************************************************************** */
#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL
  Java_com_emeric_watchflower_QShareActivity_setFileUrlReceived(JNIEnv *env,
                                                             jobject obj,
                                                             jstring url)
{
    const char *urlStr = env->GetStringUTFChars(url, NULL);
    Q_UNUSED(obj)
    AndroidShareUtils::getInstance()->setFileUrlReceived(urlStr);
    env->ReleaseStringUTFChars(url, urlStr);
    return;
}

JNIEXPORT void JNICALL
  Java_com_emeric_watchflower_QShareActivity_setFileReceivedAndSaved(JNIEnv *env,
                                                                  jobject obj,
                                                                  jstring url)
{
    const char *urlStr = env->GetStringUTFChars(url, NULL);
    Q_UNUSED(obj)
    AndroidShareUtils::getInstance()->setFileReceivedAndSaved(urlStr);
    env->ReleaseStringUTFChars(url, urlStr);
    return;
}

JNIEXPORT bool JNICALL
  Java_com_emeric_watchflower_QShareActivity_checkFileExits(JNIEnv *env,
                                                         jobject obj,
                                                         jstring url)
{
    const char *urlStr = env->GetStringUTFChars(url, NULL);
    Q_UNUSED(obj)
    bool exists = AndroidShareUtils::getInstance()->checkFileExits(urlStr);
    env->ReleaseStringUTFChars(url, urlStr);
    return exists;
}

JNIEXPORT void JNICALL
  Java_com_emeric_watchflower_QShareActivity_fireActivityResult(JNIEnv *env,
                                                             jobject obj,
                                                             jint requestCode,
                                                             jint resultCode)
{
    Q_UNUSED(obj)
    Q_UNUSED(env)
    AndroidShareUtils::getInstance()->onActivityResult(requestCode, resultCode);
    return;
}

/* ************************************************************************** */
#ifdef __cplusplus
}
#endif

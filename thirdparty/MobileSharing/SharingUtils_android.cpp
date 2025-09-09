/*!
 * Copyright (c) 2017 Ekkehard Gentz (ekke)
 * Copyright (c) 2020 Emeric Grange
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
#include <QDir>
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

AndroidShareUtils::AndroidShareUtils(QObject *parent) : PlatformShareUtils(parent)
{
    // we need the instance for JNI Call
    mInstance = this;

    QJniObject jni = QJniObject("io/emeric/utils/QShareUtils");

    if (jni.isValid())
    {
        qDebug() << "Init Activity of ShareUtils";
        jni.callMethod<void>("setActivity",
                             "(Landroid/app/Activity;)V",
                             QNativeInterface::QAndroidApplication::context().object());
    }
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
                            "io/emeric/utils/QShareUtils",
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
                            "io/emeric/utils/QShareUtils",
                            "checkMimeTypeEdit",
                            "(Ljava/lang/String;)Z",
                            jsMime.object<jstring>());

    //qDebug() << "Edit VERIFIED: " << mimeType << " - " << verified;
    return verified;
}

QString AndroidShareUtils::getExternalFilesDirPath() const
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject file = activity.callObjectMethod("getExternalFilesDir", "(Ljava/lang/String;)Ljava/io/File;", nullptr);

        if (file.isValid())
        {
            QJniObject path = file.callObjectMethod("getAbsolutePath", "()Ljava/lang/String;");
            return path.toString();
        }
    }

    return QString();
}

/* ************************************************************************** */

void AndroidShareUtils::sendText(const QString &text, const QString &subject, const QUrl &url)
{
    QJniObject jsText = QJniObject::fromString(text);
    QJniObject jsSubject = QJniObject::fromString(subject);
    QJniObject jsUrl = QJniObject::fromString(url.toString());
    jboolean ok = QJniObject::callStaticMethod<jboolean>(
                        "io/emeric/utils/QShareUtils",
                        "sendText",
                        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z",
                        jsText.object<jstring>(), jsSubject.object<jstring>(), jsUrl.object<jstring>());

    if (!ok)
    {
        qWarning() << "Unable to resolve activity from Java";
        emit shareNoAppAvailable(0);
    }
}

/* ************************************************************************** */

/*
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::sendFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, const int &requestId)
{
    mIsEditMode = false;
    QString newFilePath;

    QString externalStorage = getExternalFilesDirPath();
    if (!externalStorage.isEmpty())
    {
        if (!externalStorage.endsWith('/')) externalStorage += '/';

        if (!filePath.contains(externalStorage))
        {
            // copy to external storage directory
            newFilePath = externalStorage + QFileInfo(filePath).baseName();
            QFile::copy(filePath, newFilePath);
        }
    }

    if (newFilePath.isEmpty())
    {
        newFilePath = filePath;
    }

    qDebug() << __FUNCTION__ << newFilePath;

    QJniObject jsPath = QJniObject::fromString(newFilePath);
    QJniObject jsTitle = QJniObject::fromString(title);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/utils/QShareUtils", "sendFile",
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

/*
 * If a requestId was set we want to get the Activity Result back (recommended)
 * We need the Request Id and Result Id to control our workflow
 */
void AndroidShareUtils::viewFile(const QString &filePath, const QString &title,
                                 const QString &mimeType, const int &requestId)
{
    mIsEditMode = false;

    QJniObject jsPath = QJniObject::fromString(filePath);
    QJniObject jsTitle = QJniObject::fromString(title);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);
    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/utils/QShareUtils", "viewFile",
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

/*
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

    QJniObject jsPath = QJniObject::fromString(filePath);
    QJniObject jsTitle = QJniObject::fromString(title);
    QJniObject jsMimeType = QJniObject::fromString(mimeType);

    jboolean ok = QJniObject::callStaticMethod<jboolean>("io/emeric/utils/QShareUtils",
                                                         "editFile",
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
/* ************************************************************************** */

// used from QAndroidActivityResultReceiver
void AndroidShareUtils::handleActivityResult(int receiverRequestCode, int resultCode, const QJniObject &data)
{
    Q_UNUSED(data)
    qDebug() << "From JNI QAndroidActivityResultReceiver: " << receiverRequestCode << "ResultCode:" << resultCode;
    processActivityResult(receiverRequestCode, resultCode);
}

/* ************************************************************************** */

// used from Activity.java onActivityResult()
void AndroidShareUtils::onActivityResult(int requestCode, int resultCode)
{
    qDebug() << "From Java Activity onActivityResult: " << requestCode << "ResultCode:" << resultCode;
    processActivityResult(requestCode, resultCode);
}

/* ************************************************************************** */

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

/* ************************************************************************** */

void AndroidShareUtils::checkPendingIntents(const QString &workingDirPath)
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
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

/* ************************************************************************** */

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

/* ************************************************************************** */

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

/* ************************************************************************** */
/* ************************************************************************** */

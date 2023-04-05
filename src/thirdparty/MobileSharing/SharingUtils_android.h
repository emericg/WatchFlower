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

#ifndef SHARINGUTILS_ANDROID_H
#define SHARINGUTILS_ANDROID_H
/* ************************************************************************** */

#include "SharingUtils.h"

#include <QtGlobal>

#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
#include <QCoreApplication>
#include <QtCore/private/qandroidextras_p.h>
#include <QJniObject>
#else
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QAndroidActivityResultReceiver>
#endif

/* ************************************************************************** */

class AndroidShareUtils : public PlatformShareUtils, public QAndroidActivityResultReceiver
{
    static AndroidShareUtils *mInstance;

    bool mAltImpl = false;
    bool mIsEditMode = false;
    qint64 mLastModified = 0;
    QString mCurrentFilePath;

    void processActivityResult(int requestCode, int resultCode);

public:
    AndroidShareUtils(QObject *parent = nullptr);
    static AndroidShareUtils *getInstance();

    bool checkMimeTypeView(const QString &mimeType) override;
    bool checkMimeTypeEdit(const QString &mimeType) override;
    void share(const QString &text, const QUrl &url) override;
    void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) override;
    void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) override;
    void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) override;

#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
    void handleActivityResult(int receiverRequestCode, int resultCode, const QJniObject &data) override;
#else
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data) override;
#endif
    void onActivityResult(int requestCode, int resultCode);

    void checkPendingIntents(const QString workingDirPath) override;

public slots:
    void setFileUrlReceived(const QString &url);
    void setFileReceivedAndSaved(const QString &url);
    bool checkFileExits(const QString &url);
};

/* ************************************************************************** */
#endif // SHARINGUTILS_ANDROID_H

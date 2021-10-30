/*
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

/*
 * This project is based on ideas from:
 * - https://github.com/ekke/ekkesSHAREexample
 * - https://www.qt.io/blog/2017/12/01/sharing-files-android-ios-qt-app
 * - https://www.qt.io/blog/2018/01/16/sharing-files-android-ios-qt-app-part-2
 * - https://www.qt.io/blog/2018/02/06/sharing-files-android-ios-qt-app-part-3
 * - https://www.qt.io/blog/2018/11/06/sharing-files-android-ios-qt-app-part-4
 * also inspired by:
 * - http://blog.lasconic.com/share-on-ios-and-android-using-qml/
 * - https://github.com/lasconic/ShareUtils-QML
 * also inspired by:
 * - https://www.androidcode.ninja/android-share-intent-example/
 * - https://www.calligra.org/blogs/sharing-with-qt-on-android/
 * - https://stackoverflow.com/questions/7156932/open-file-in-another-app
 * - http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
 * - https://stackoverflow.com/questions/5734678/custom-filtering-of-intent-chooser-based-on-installed-android-package-name
 */

#ifndef SHARINGUTILS_H
#define SHARINGUTILS_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QUrl>
#include <QDebug>

/* ************************************************************************** */

class PlatformShareUtils : public QObject
{
    Q_OBJECT

signals:
    void shareEditDone(int requestCode);
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);
    void fileUrlReceived(QString url);
    void fileReceivedAndSaved(QString url);

public:
    PlatformShareUtils(QObject *parent = nullptr) : QObject(parent) { };
    virtual ~PlatformShareUtils() = default;

    virtual bool checkMimeTypeView(const QString &mimeType) {
        qDebug() << "check view for" << mimeType;
        return true;
    }
    virtual bool checkMimeTypeEdit(const QString &mimeType) {
        qDebug() << "check edit for" << mimeType;
        return true;
    }
    virtual void share(const QString &text, const QUrl &url) {
        qDebug() << text << url.url();
    }
    virtual void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
        qDebug() << filePath << " - " << title << "requestId: " << requestId << " - " << mimeType;
    }
    virtual void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
        qDebug() << filePath << " - " << title << "requestId: " << requestId << " - " << mimeType;
    }
    virtual void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
        qDebug() << filePath << " - " << title << "requestId: " << requestId << " - " << mimeType;
    }

    virtual void checkPendingIntents(const QString workingDirPath) {
        qDebug() << "checkPendingIntents" << workingDirPath;
    }
};

/* ************************************************************************** */

class ShareUtils : public QObject
{
    Q_OBJECT

    PlatformShareUtils *mPlatformShareUtils = nullptr;

signals:
    void shareEditDone(int requestCode);
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);
    void fileUrlReceived(QString url);
    void fileReceivedAndSaved(QString url);

public slots:
    void onShareEditDone(int requestCode);
    void onShareFinished(int requestCode);
    void onShareNoAppAvailable(int requestCode);
    void onShareError(int requestCode, QString message);
    void onFileUrlReceived(QString url);
    void onFileReceivedAndSaved(QString url);

public:
    explicit ShareUtils(QObject *parent = nullptr);
    Q_INVOKABLE bool checkMimeTypeView(const QString &mimeType);
    Q_INVOKABLE bool checkMimeTypeEdit(const QString &mimeType);
    Q_INVOKABLE void share(const QString &text, const QUrl &url);
    Q_INVOKABLE void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void checkPendingIntents(const QString workingDirPath);
};

/* ************************************************************************** */
#endif // SHARINGUTILS_H

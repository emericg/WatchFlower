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

#include "MobileSharing.h"

#if defined(Q_OS_IOS)
#include "MobileSharing_ios.h"
#elif defined(Q_OS_ANDROID)
#include "MobileSharing_android.h"
#endif

#include <QGuiApplication>
#include <QCoreApplication>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>
#include <QQmlEngine>
#include <QJSEngine>

/* ************************************************************************** */

QString PlatformShareUtils::cacheRootDir()
{
    return QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/MobileSharing";
}

QString PlatformShareUtils::cacheIncomingDir()
{
    return cacheRootDir() + "/incoming";
}

QString PlatformShareUtils::cacheOutgoingDir()
{
    return cacheRootDir() + "/outgoing";
}

/* ************************************************************************** */

MobileSharing *MobileSharing::getInstance()
{
    static MobileSharing *instance = new MobileSharing(QCoreApplication::instance());
    return instance;
}

MobileSharing *MobileSharing::create(QQmlEngine *, QJSEngine *)
{
    MobileSharing *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

/* ************************************************************************** */

MobileSharing::MobileSharing(QObject *parent) : QObject(parent)
{
#if defined(Q_OS_IOS)
    mPlatformShareUtils = new IosShareUtils(this);
#elif defined(Q_OS_ANDROID)
    mPlatformShareUtils = new AndroidShareUtils(this);
#else
    mPlatformShareUtils = new PlatformShareUtils(this);
#endif

    // Forward most backend signals straight through to our identically-named public signals.
    connect(mPlatformShareUtils, &PlatformShareUtils::shareFinished, this, &MobileSharing::shareFinished);
    connect(mPlatformShareUtils, &PlatformShareUtils::shareNoAppAvailable, this, &MobileSharing::shareNoAppAvailable);
    connect(mPlatformShareUtils, &PlatformShareUtils::shareError, this, &MobileSharing::shareError);
    connect(mPlatformShareUtils, &PlatformShareUtils::fileSaved, this, &MobileSharing::fileSaved);

    // fileReceived first needs relocating into our cache dir, so it goes through a slot.
    connect(mPlatformShareUtils, &PlatformShareUtils::fileReceived, this, &MobileSharing::onFileReceived);

    // Module-owned temporary cache directory (cache/MobileSharing) with incoming/ and outgoing/ subdirs.
    mWorkingDir = PlatformShareUtils::cacheRootDir();
    mIncomingDir = PlatformShareUtils::cacheIncomingDir();
    mOutgoingDir = PlatformShareUtils::cacheOutgoingDir();

    // Optional Android Storage Access Framework (SAF) DocumentProvider
    mDocumentProvider = new DocumentProvider(this);

    // Session-scoped: wipe the whole directory, at the earliest point before any file can be received or sent
    QDir(mWorkingDir).removeRecursively();

    // Created on demand
    //QDir().mkpath(mIncomingDir);
    //QDir().mkpath(mOutgoingDir);

    // Self-drive incoming-intent processing so the host do not require a custom QGuiApplication subclass:
    // react to app-state changes, and also handle the case where the app is already active
    // by the time this object is created (deferred so QML signal handlers are wired up first).
    connect(qApp, &QGuiApplication::applicationStateChanged, this, &MobileSharing::onApplicationStateChanged);

    if (qApp->applicationState() == Qt::ApplicationActive)
    {
        QMetaObject::invokeMethod(this, "onApplicationStateChanged", Qt::QueuedConnection,
                                  Q_ARG(Qt::ApplicationState, Qt::ApplicationActive));
    }
}

/* ************************************************************************** */

void MobileSharing::onApplicationStateChanged(Qt::ApplicationState state)
{
    if (state == Qt::ApplicationActive && !mPendingIntentsChecked)
    {
        mPendingIntentsChecked = true;
        mPlatformShareUtils->checkPendingIntents(mIncomingDir);
    }
}

/* ************************************************************************** */

void MobileSharing::discardFileReceived(const QString &filePath)
{
    QString canonicalDir = QDir(mWorkingDir).canonicalPath();
    QString canonicalFile = QFileInfo(filePath).canonicalFilePath();

    // Only allow deleting files inside our own cache dir
    if (!canonicalDir.isEmpty() && canonicalFile.startsWith(canonicalDir + '/'))
    {
        if (!QFile::remove(canonicalFile))
        {
            qWarning() << "discardFileReceived() failed to remove" << canonicalFile;
        }
    }
    else
    {
        qWarning() << "discardFileReceived() refusing to delete outside cache dir:" << filePath;
    }
}

/* ************************************************************************** */

bool MobileSharing::checkMimeTypeView(const QString &mimeType)
{
    return mPlatformShareUtils->checkMimeTypeView(mimeType);
}

void MobileSharing::sendText(const QString &text, const QString &subject, const QUrl &url)
{
    mPlatformShareUtils->sendText(text, subject, url);
}

void MobileSharing::sendFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId, bool move)
{
    mPlatformShareUtils->sendFile(filePath, title, mimeType, requestId, move);
}

void MobileSharing::sendFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId, bool move)
{
    mPlatformShareUtils->sendFiles(filePaths, title, mimeType, requestId, move);
}

void MobileSharing::viewFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId)
{
    mPlatformShareUtils->viewFile(filePath, title, mimeType, requestId);
}

void MobileSharing::viewFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId)
{
    mPlatformShareUtils->viewFiles(filePaths, title, mimeType, requestId);
}

void MobileSharing::saveFile(const QString &filePath, const QString &suggestedName, const QString &mimeType, int requestId)
{
    if (!QFileInfo::exists(filePath))
    {
        Q_EMIT shareError(requestId, QStringLiteral("Save: source file does not exist: %1").arg(filePath));
        return;
    }

    mPlatformShareUtils->saveFile(filePath, suggestedName, mimeType, requestId);
}

void MobileSharing::openFile()
{
    mPlatformShareUtils->openFile();
}

QString MobileSharing::getCacheDirectory() const
{
    return mWorkingDir;
}

/* ************************************************************************** */

DocumentProvider *MobileSharing::documentProvider() const
{
    return mDocumentProvider;
}

void MobileSharing::importFile(const QUrl &source)
{
    if (!source.isValid())
    {
        Q_EMIT shareError(0, QStringLiteral("Import: invalid source URL"));
        return;
    }

    // A file picked through Qt's FileDialog is a URL we don't own yet:
    // - a content:// URI on Android (Qt's content file engine lets QFile read these directly)
    // - a file:// path elsewhere (desktop, iOS)
    // Either way we stream it into incoming/ so the app ends up owning a real, readable
    // file, surfaced through the same fileReceived() signal as a received share.
    const QString srcPath = source.isLocalFile() ? source.toLocalFile() : source.toString();

    QFile in(srcPath);
    if (!in.open(QIODevice::ReadOnly))
    {
        Q_EMIT shareError(0, QStringLiteral("Import: cannot read %1").arg(srcPath));
        return;
    }

    // Best-effort display name (Qt's content engine resolves DISPLAY_NAME for content:// URIs).
    QString name = QFileInfo(in).fileName();
    if (name.isEmpty()) name = source.fileName();
    if (name.isEmpty()) name = QStringLiteral("imported_%1").arg(QDateTime::currentMSecsSinceEpoch());

    QDir().mkpath(mIncomingDir);
    QString dest = mIncomingDir + '/' + name;
    if (QFileInfo::exists(dest))
    {
        // Don't clobber a previous file of the same name this session.
        dest = mIncomingDir + '/' + QString::number(QDateTime::currentMSecsSinceEpoch()) + '_' + name;
    }

    QFile out(dest);
    if (!out.open(QIODevice::WriteOnly))
    {
        in.close();
        Q_EMIT shareError(0, QStringLiteral("Import: cannot write %1").arg(dest));
        return;
    }

    // Manual copy // QFile::copy() isn't implemented on content:// URIs
    qint64 n;
    char buffer[8192];
    while ((n = in.read(buffer, sizeof(buffer))) > 0)
    {
        if (out.write(buffer, n) != n)
        {
            in.close();
            out.close();
            QFile::remove(dest);
            Q_EMIT shareError(0, QStringLiteral("Import: write failed for %1").arg(dest));
            return;
        }
    }

    in.close();
    out.close();

    Q_EMIT fileReceived(dest);
}

const QMimeDatabase &MobileSharing::getMimeDatabase() const
{
    return mPlatformShareUtils->getMimeDatabase();
}

/* ************************************************************************** */

void MobileSharing::onFileReceived(const QString &filePath)
{
    // Every received path is a file the application owns inside our cache dir.
    // - Android's platform layer already copied it there, so this is a no-op.
    // - iOS delivers it into Documents/Inbox, so move it into our cache dir.

    QString path = filePath;

    QDir().mkpath(mIncomingDir);
    QDir incomingDir(mIncomingDir);
    const QString canonicalIncoming = incomingDir.canonicalPath();

    if (canonicalIncoming.isEmpty() || !QFileInfo(path).canonicalFilePath().startsWith(canonicalIncoming + '/'))
    {
        QString dest = incomingDir.filePath(QFileInfo(path).fileName());
        if (QFileInfo::exists(dest))
        {
            // Avoid clobbering a previous file of the same name
            dest = incomingDir.filePath(QString::number(QDateTime::currentMSecsSinceEpoch()) + '_' + QFileInfo(path).fileName());
        }

        // Move it in our incoming folder ('deleting' the OS-provided original, e.g. the iOS Inbox copy).
        if (QFile::rename(path, dest))
        {
            path = dest;
        }
        else
        {
            qWarning() << "onFileReceived() failed to move into shared cache dir, emitting original:" << path;
        }
    }

    Q_EMIT fileReceived(path);
}

/* ************************************************************************** */

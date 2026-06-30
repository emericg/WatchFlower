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

#ifndef MOBILESHARING_H
#define MOBILESHARING_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QMimeDatabase>
#include <QUrl>
#include <QDebug>

#include "MobileSharing_private.h"
#include "MobileSharing_DocumentProvider.h"

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief Cross-platform file & text sharing, exposed to QML as the `MobileSharing` type.
 *
 * This is the public entry point of the module. It wraps a per-platform PlatformShareUtils
 * backend and offers a uniform API to:
 *  - send text/URLs (sendText()) and files (sendFile()) to other apps,
 *  - view a file in another app (viewFile()),
 *  - save a file to a user-chosen location (saveFile()) and open one (openFile() / importFile()),
 *  - receive files shared into the app (fileReceived()).
 *
 * Files the module hands out or takes in live in a session-scoped cache directory
 * (see getCacheDirectory()) that is wiped at every startup; copy anything you want to keep
 * into your own storage. Outgoing operations take a caller-chosen \c requestId that is echoed
 * back in the result signals (shareFinished(), shareError(), fileSaved(), ...).
 */
class MobileSharing : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(DocumentProvider *documentProvider READ documentProvider CONSTANT)

Q_SIGNALS:
    /*!
     * \brief Emitted when an outgoing share/view/save flow ended without error.
     * \param requestCode: The request id passed to the originating call (0 for sendText()).
     *
     * Covers both completion and user cancellation; it does not guarantee the target app
     * actually consumed the content (not all apps report a result back).
     */
    void shareFinished(int requestCode);

    /*!
     * \brief Emitted when no installed application can handle the requested action.
     * \param requestCode: The request id passed to the originating call.
     */
    void shareNoAppAvailable(int requestCode);

    /*!
     * \brief Emitted when an operation failed.
     * \param requestCode: The request id passed to the originating call (0 when not applicable).
     * \param message: A human-readable description of what went wrong.
     */
    void shareError(int requestCode, QString message);

    /*!
     * \brief fileReceived signal, emitted once per incoming file.
     * \param filePath: The path to the file received.
     *
     * The path always points to a real, readable file the app owns (a copy in the module's cache subdir).
     * The cache will be deleted next time the app starts, so copy/move it into your own storage if you want to keep it.
     */
    void fileReceived(const QString &filePath);

    /*!
     * \brief fileSaved signal, emitted once a saveFile() request completed successfully.
     * \param requestCode: The request id passed to saveFile().
     *
     * A cancelled save emits shareFinished() instead, and a failed one shareError().
     */
    void fileSaved(int requestCode);

public slots:
    // Internal: applies the incoming-file relocation into our cache, then re-emits fileReceived(). Not intended to be called by host code.
    void onFileReceived(const QString &filePath);

public:
    /*!
     * \brief Get the process-wide MobileSharing singleton instance.
     *
     * Use this to access the instance from C++.
     * The same instance is shared with QML.
     */
    static MobileSharing *getInstance();

    /*!
     * \brief QML singleton factory.
     *
     * Called by the QML engine to obtain the MobileSharing singleton.
     * Returns getInstance(), so C++ and QML share the same single instance,
     * and flags it C++ owned so the JS engine never deletes it.
     */
    static MobileSharing *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    // Tools ///////////////////////////////////////////////////////////////////

    //! Access the module's shared QMimeDatabase (for mime lookups by name or content).
    const QMimeDatabase &getMimeDatabase() const;

    /*!
     * \brief Check whether some installed app can VIEW a given mime type.
     * \param mimeType: The mime type to test (like "application/pdf").
     * \return True if at least one app can handle an ACTION_VIEW for this type.
     * \note Android only; returns true on other platforms.
     *
     * Handy to enable/disable an "Open with" affordance before calling viewFile().
     */
    Q_INVOKABLE bool checkMimeTypeView(const QString &mimeType);

    /*!
     * \brief Return the module's session-scoped cache directory (cache/MobileSharing).
     *
     * Handy when the host application wants to create a throwaway file to share: anything
     * created under this directory is wiped at the next startup, and is already serviceable
     * by the platform's file sharing (e.g. Android's FileProvider exposes exactly this path),
     * so the resulting file can be passed straight to sendFile().
     */
    Q_INVOKABLE QString getCacheDirectory() const;

    /*!
     * \brief Explicitly reject/drop a received file by deleting our cached copy.
     * \param filePath: A path previously delivered through fileReceived().
     *
     * As a safety guard, only files located inside the module's own cache directory are
     * removed; a path pointing anywhere else is ignored (and logged as a warning).
     */
    Q_INVOKABLE void discardFileReceived(const QString &filePath);

    // Sharing /////////////////////////////////////////////////////////////////

    /*!
     * \brief Share plain text (and an optional URL) through the system share sheet.
     * \param text: The text body to share.
     * \param subject: An optional subject, used by targets that support one (e.g. email).
     * \param url: An optional URL appended to the shared content.
     */
    Q_INVOKABLE void sendText(const QString &text, const QString &subject, const QUrl &url);

    /*!
     * \brief Share a file with another application through the system share sheet.
     * \param filePath: The file to share (must be readable, e.g. one under getCacheDirectory()).
     * \param title: A human-readable title for the share (used by some targets).
     * \param mimeType: The file's mime type (like "image/jpeg"), or "*" if unknown.
     * \param requestId: Caller-chosen id, echoed back in shareFinished() / shareError().
     * \param move: If true, the file is relocated into the module's (session-wiped) outgoing dir instead of copied,
     *              useful for throwaway files. No-op on iOS.
     */
    Q_INVOKABLE void sendFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId, bool move = false);

    /*!
     * \brief Share several files at once through the system share sheet.
     * \param filePaths: The files to share (each must be readable, e.g. ones under getCacheDirectory()).
     * \param title: A human-readable title for the share (used by some targets).
     * \param mimeType: A common mime type for the set (like "image/jpeg"), or "*" if mixed/unknown.
     * \param requestId: Caller-chosen id, echoed back in shareFinished() / shareError().
     * \param move: If true, each file is relocated into the module's (session-wiped) outgoing dir
     *              instead of copied, useful for throwaway files. No-op on iOS.
     *
     * On Android this uses ACTION_SEND_MULTIPLE; unshareable paths are skipped and it fails only
     * if none could be shared. On iOS the share sheet takes the whole set natively.
     */
    Q_INVOKABLE void sendFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId, bool move = false);

    /*!
     * \brief Open a file in another application for viewing.
     * \param filePath: The file to view.
     * \param title: A human-readable title (used by some targets).
     * \param mimeType: The file's mime type, or "*" if unknown.
     * \param requestId: Caller-chosen id, echoed back in shareFinished() / shareError().
     */
    Q_INVOKABLE void viewFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId);

    /*!
     * \brief Preview several files at once in an in-app viewer.
     * \param filePaths: The files to preview.
     * \param title: A human-readable title (used by some targets).
     * \param mimeType: A common mime type for the set, or "*" if mixed/unknown.
     * \param requestId: Caller-chosen id, echoed back in shareFinished() / shareError().
     *
     * \note iOS only: QLPreviewController pages through the whole set. Android has no multi-file
     * ACTION_VIEW equivalent, so this is a no-op there (call viewFile() per file instead).
     */
    Q_INVOKABLE void viewFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId);

    // Open / Save /////////////////////////////////////////////////////////////

    /*!
     * \brief Import an arbitrary file (through a FileDialog) into the module's cache.
     * \param source: URL of the source file (file:// on desktop/iOS, content:// on Android).
     *
     * Streams the content into our 'MobileSharing/incoming/' subdir so the app ends up owning a real,
     * readable copy, then emits fileReceived() exactly as if the file had been shared in.
     * This makes it possible to use the native file pickers through Qt FileDialog, and still use
     * the files with something else than a QFile.
     */
    Q_INVOKABLE void importFile(const QUrl &source);

    /*!
     * \brief Open (import) a file through the OS native file picker.
     *
     * Presents the platform's document picker and copies the chosen file into the module's
     * cache, surfacing it through fileReceived() exactly like a received share.
     *
     * Use this where Qt's own FileDialog can't deliver a readable result - notably iOS,
     * where the picker hands back a security-scoped File Provider URL that QFile cannot read;
     * the native picker imports a readable copy into the app sandbox instead.
     *
     * On Android a Qt FileDialog + importFile() works fine, so this is currently implemented natively on iOS only.
     */
    Q_INVOKABLE void openFile();

    /*!
     * \brief Save (export) a file to a user-chosen location via the OS file picker.
     * \param filePath: The source file to export (typically one the app owns, e.g. in the cache).
     * \param suggestedName: The default file name proposed to the user in the picker.
     * \param mimeType: The file's mime type (like "application/pdf").
     * \param requestId: Caller-chosen id, echoed back in fileSaved()/shareFinished()/shareError().
     *
     * On Android this drives SAF's ACTION_CREATE_DOCUMENT and streams the bytes into the chosen destination
     * through the system ContentResolver (which is why it works where a plain QFileDialog "save" does not).
     * Emits fileSaved() on success, shareFinished() if the user cancels, shareError() on failure.
     *
     * Requires the host to run QShareActivity.
     */
    Q_INVOKABLE void saveFile(const QString &filePath, const QString &suggestedName, const QString &mimeType, int requestId);

    // Directory sharing (Android SAF DocumentsProvider) ///////////////////////

    /*!
     * \brief Optional Android Storage Access Framework (SAF) DocumentProvider.
     *
     * The whole directory-sharing feature lives in this instance. Owned by MobileSharing, do not delete.
     * Always valid on non-Android platforms, just doesn't do much :)
     *
     * Use it in QML through its property:
     * - MobileSharing.documentProvider.enabled = true
     * - var sharedRoot: "file://" + MobileSharing.documentProvider.sharedDirectory
     */
    DocumentProvider *documentProvider() const;

private slots:
    void onApplicationStateChanged(Qt::ApplicationState state);

private:
    bool mPendingIntentsChecked = false;

    QString mWorkingDir;  //!< module-owned cache root (cache/MobileSharing), wiped at startup
    QString mIncomingDir; //!< subdir where received files are copied (cache/MobileSharing/incoming)
    QString mOutgoingDir; //!< subdir where sending files are copied (cache/MobileSharing/outgoing)

    //! Optional Android Storage Access Framework (SAF) DocumentProvider
    DocumentProvider *mDocumentProvider = nullptr;

    //! Per-platform backend.
    PlatformShareUtils *mPlatformShareUtils = nullptr;

    // Singleton
    explicit MobileSharing(QObject *parent = nullptr);
};

/* ************************************************************************** */
#endif // MOBILESHARING_H

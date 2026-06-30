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

#ifndef MOBILESHARING_IOS_H
#define MOBILESHARING_IOS_H
/* ************************************************************************** */

#include "MobileSharing.h"

/* ************************************************************************** */

/*!
 * \brief iOS backend for MobileSharing (UIKit / UniformTypeIdentifiers).
 *
 * Implements the PlatformShareUtils interface on top of UIActivityViewController
 * (share/send) and UIDocumentPickerViewController (open/save).
 */
class IosShareUtils : public PlatformShareUtils
{
    Q_OBJECT

public:
    explicit IosShareUtils(QObject *parent = 0);

    bool checkMimeTypeView(const QString &mimeType);

    void sendText(const QString &text, const QString &subject, const QUrl &url);

    void sendFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId, bool move);
    void sendFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId, bool move);
    void viewFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId);
    void viewFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId);

    void saveFile(const QString &filePath, const QString &suggestedName, const QString &mimeType, int requestId);
    void openFile();

    /*!
     * \brief Called by the export-picker delegate once a saveFile() flow finished.
     * \param requestId: The request id passed to saveFile().
     * \param success: True if the file was exported to the chosen destination.
     * \param canceled: True if the user dismissed the picker (success is then false).
     *
     * Emits fileSaved() on success, shareFinished() on cancel, shareError() otherwise.
     */
    void handleSaveResult(int requestId, bool success, bool canceled);

    /*!
     * \brief Called by the import-picker delegate with the (sandbox-local, readable) picked file.
     * \param filePath: Path to the file the document picker imported into the app sandbox.
     *
     * Emits fileReceived() so it lands in the cache like any other incoming file.
     */
    void handleImportedFile(const QString &filePath);

    /*!
     * \brief Called by the QLPreviewController delegate when the in-app viewer is dismissed.
     * \param requestId: The request id passed to the originating viewFile() call.
     *
     * Emits shareFinished().
     */
    void handlePreviewDismissed(int requestId);

public slots:
    /*!
     * \brief Incoming-file entry point: a file:// URL was opened into the app.
     * \param url: The local URL iOS delivered (typically into the app's Documents/Inbox).
     *
     * Registered as the QDesktopServices "file" scheme handler in the constructor,
     * so iOS "Open in <app>" / document-type opens land here.
     * Validates the path and emits fileReceived().
     */
    void handleFileUrlReceived(const QUrl &url);
};

/* ************************************************************************** */
#endif // MOBILESHARING_IOS_H

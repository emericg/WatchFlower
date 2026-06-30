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

#ifndef MOBILESHARING_ANDROID_H
#define MOBILESHARING_ANDROID_H
/* ************************************************************************** */

#include "MobileSharing.h"

/* ************************************************************************** */

/*!
 * \brief Android backend for MobileSharing (JNI to QShareActivity / QShareUtils).
 *
 * Implements the PlatformShareUtils interface using Android intents (ACTION_SEND/VIEW/EDIT)
 * and the Storage Access Framework (ACTION_CREATE_DOCUMENT / OPEN_DOCUMENT).
 * It is a singleton: the JNI bridges in MobileSharing_android.cpp call back into getInstance().
 */
class AndroidShareUtils : public PlatformShareUtils
{
    static AndroidShareUtils *mInstance;

    /*!
     * \brief Return a path that FileProvider can serve (one under an exposed sandbox dir)
     * \param filePath: The path of the file we want to share.
     * \param move: Do we want to copy or to move that file?
     * \return If \a filePath already qualifies it is returned as-is (unless \a move);
     *         otherwise the file is copied (or moved, deleting the original) into the
     *         session-wiped outgoing dir. Returns an empty string on failure.
     */
    QString ensureShareableFile(const QString &filePath, bool move);

    /*!
     * \brief isShareablePath()
     * \param filePath: The path of the file we want to share.
     * \return True if \a filePath lives under a dir declared in res/xml/filepaths.xml
     */
    bool isShareablePath(const QString &filePath) const;

public:
    AndroidShareUtils(QObject *parent = nullptr);

    //! The process-wide instance (set by the constructor), used by the JNI bridges to reach this object.
    static AndroidShareUtils *getInstance();

    //! Ask QShareActivity to deliver any intent that arrived before QML was ready (incoming share).
    void checkPendingIntents(const QString &workingDirPath) override;

    bool checkMimeTypeView(const QString &mimeType) override;

    void sendText(const QString &text, const QString &subject, const QUrl &url) override;

    void sendFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId, bool move) override;
    void sendFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId, bool move) override;
    void viewFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId) override;
    void saveFile(const QString &filePath, const QString &suggestedName, const QString &mimeType, int requestId) override;

    /*!
     * \brief Called from JNI (QShareActivity) once a saveFile() flow finished in Java.
     * \param requestCode: The request id passed to saveFile().
     * \param success: True if the source bytes were written into the chosen destination.
     * \param canceled: True if the user dismissed the picker (success is then false).
     *
     * Emits fileSaved() on success, shareFinished() on cancel, shareError() otherwise.
     */
    void onSaveResult(int requestCode, bool success, bool canceled);

public slots:
    /*!
     * \brief Called from JNI (QShareActivity) once the incoming file has been copied into our cache subdir.
     * \param filePath: Path to our copy of the file we just receive.
     *
     * Emits fileReceived() if the file is valid.
     */
    void setFileReceived(const QString &filePath);
};

/* ************************************************************************** */
#endif // MOBILESHARING_ANDROID_H

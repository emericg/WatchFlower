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

#ifndef MOBILESHARING_PRIVATE_H
#define MOBILESHARING_PRIVATE_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QStringList>
#include <QMimeDatabase>
#include <QUrl>
#include <QDebug>

/* ************************************************************************** */

/*!
 * \brief Internal platform backend behind MobileSharing.
 *
 * This is the module's private interface: the base class provides a dummy
 * default implementation.
 */
class PlatformShareUtils : public QObject
{
    Q_OBJECT

Q_SIGNALS:
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);

    void fileReceived(QString filePath);
    void fileSaved(int requestCode);

public:
    PlatformShareUtils(QObject *parent = nullptr) : QObject(parent) { };
    virtual ~PlatformShareUtils() = default;

    virtual void checkPendingIntents(const QString &workingDirPath) { }
    virtual bool checkMimeTypeView(const QString &mimeType) { return true; }

    virtual void sendText(const QString &text, const QString &subject, const QUrl &url) {
        qDebug() << text << subject << url.url();
    }
    virtual void sendFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId, bool move) {
        qDebug() << filePath << " - " << title << "requestId: " << requestId << " - " << mimeType << " - " << move;
    }
    virtual void sendFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId, bool move) {
        qDebug() << filePaths << " - " << title << "requestId: " << requestId << " - " << mimeType << " - " << move;
    }
    virtual void viewFile(const QString &filePath, const QString &title, const QString &mimeType, int requestId) {
        qDebug() << filePath << " - " << title << "requestId: " << requestId << " - " << mimeType;
    }
    virtual void viewFiles(const QStringList &filePaths, const QString &title, const QString &mimeType, int requestId) {
        qDebug() << filePaths << " - " << title << "requestId: " << requestId << " - " << mimeType;
    }

    virtual void saveFile(const QString &filePath, const QString &suggestedName, const QString &mimeType, int requestId) {
        qDebug() << filePath << " - " << suggestedName << "requestId: " << requestId << " - " << mimeType;
    }
    virtual void openFile() {
        qDebug() << "openFile";
    }

    const QMimeDatabase &getMimeDatabase() const {
        return m_mimeDatabase;
    }

    /*!
     * \brief Centralized module cache layout
     *
     * Everything lives under the app's CacheLocation and everything is wiped at startup.
     *
     * - <cache>/MobileSharing
     * - <cache>/MobileSharing/incoming
     * - <cache>/MobileSharing/outgoing
     */
    static QString cacheRootDir();
    static QString cacheIncomingDir();
    static QString cacheOutgoingDir();

private:
    QMimeDatabase m_mimeDatabase;
};

/* ************************************************************************** */
#endif // MOBILESHARING_PRIVATE_H

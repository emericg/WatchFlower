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

#ifndef MOBILESHARING_DIRECTORY_H
#define MOBILESHARING_DIRECTORY_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

/* ************************************************************************** */

/*!
 * \brief Optional "expose a folder via SAF" control, reached as MobileSharing.documentProvider.
 *
 * Self-contained, fully optional, Android-only feature backed by a DocumentsProvider
 * (see QShareDocumentProvider). It is OFF by default and inert until enabled: while disabled the
 * shared directory is invisible in every picker and the provider refuses all access, so \c enabled
 * is the single on/off switch.
 *
 * The exposed directory is \c sharedDirectory (created on demand when enabling). The current
 * implementation is READ-ONLY. On non-Android platforms the object still exists but is a no-op
 * (\c enabled stays false), so QML bindings never need a null check.
 *
 * State is persisted by the provider itself (the provider keeps serving across app exits/reboots),
 * and this object seeds itself from that persisted state on construction, so \c enabled mirrors what
 * the system-managed provider is actually doing on a fresh launch.
 *
 * Requires the host AndroidManifest to declare the io.emeric.mobilesharing.QShareDocumentProvider
 * <provider> entry (authority "${applicationId}.documents").
 */
class DocumentProvider : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString sharedDirectory READ sharedDirectory WRITE setSharedDirectory NOTIFY sharedDirectoryChanged)

Q_SIGNALS:
    void enabledChanged();
    void titleChanged();
    void sharedDirectoryChanged();

public:
    explicit DocumentProvider(QObject *parent = nullptr);

    bool enabled() const;
    void setEnabled(bool enabled);

    QString title() const;
    void setTitle(const QString &title);

    QString sharedDirectory() const;

    /*!
     * \brief Customize which app-owned directory is exposed.
     * \param absolutePath: Absolute path to an app-owned directory (created on demand when enabled).
     *
     * Pass an empty string to restore the default (<app data>/MobileSharing/shared).
     * Safe to call while enabled: the change is applied to the live provider immediately.
     */
    void setSharedDirectory(const QString &absolutePath);

private:
    static QString defaultDirectory();

    //! Push the current state to the Android provider (via JNI). No-op on other platforms.
    void apply();

    bool m_enabled = false;
    bool m_writable = false;                            //!< TODO read/write (forced read-only for now)
    QString m_dir;                                      //!< Persistent app-owned dir exposed when enabled
    QString m_title = QStringLiteral("Shared");         //!< Title shown in pickers
};

/* ************************************************************************** */
#endif // MOBILESHARING_DIRECTORY_H

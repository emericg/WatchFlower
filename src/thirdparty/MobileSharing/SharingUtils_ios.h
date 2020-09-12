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

#ifndef SHARINGUTILS_IOS_H
#define SHARINGUTILS_IOS_H
/* ************************************************************************** */

#include "SharingUtils.h"

/* ************************************************************************** */

class IosShareUtils : public PlatformShareUtils
{
    Q_OBJECT

public:
    explicit IosShareUtils(QObject *parent = 0);

    bool checkMimeTypeView(const QString &mimeType);
    bool checkMimeTypeEdit(const QString &mimeType);
    void share(const QString &text, const QUrl &url);
    void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);

    void handleDocumentPreviewDone(const int &requestId);

public slots:
    void handleFileUrlReceived(const QUrl &url);
};

/* ************************************************************************** */
#endif // SHARINGUTILS_IOS_H

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

#ifndef SHARINGAPPLICATION_H
#define SHARINGAPPLICATION_H
/* ************************************************************************** */

#include <QGuiApplication>

class QQmlContext;
class ShareUtils;

/* ************************************************************************** */

class SharingApplication : public QGuiApplication
{
    Q_OBJECT

    ShareUtils *mShareUtils = nullptr;
    bool mPendingIntentsChecked = false;

    QString mAppDataFilesPath;
    QString mDocumentsWorkPath;

public:
    explicit SharingApplication(int &argc, char **argv);
    ~SharingApplication();

signals:
    void fileDropped(const QString &filePath);

public slots:
    void onApplicationStateChanged(Qt::ApplicationState state);

protected:
    bool event(QEvent *e);
};

/* ************************************************************************** */
#endif // SHARINGAPPLICATION_H

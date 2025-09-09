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

#include "SharingApplication.h"
#include "SharingUtils.h"

#include <QGuiApplication>
#include <QQmlContext>

#include <QDir>
#include <QFile>
#include <QFileOpenEvent>

#include <QDebug>

/* ************************************************************************** */

SharingApplication::SharingApplication(int &argc, char **argv) : QGuiApplication(argc, argv)
{
    mShareUtils = new ShareUtils(this);

    connect(this, &QGuiApplication::applicationStateChanged, this, &SharingApplication::onApplicationStateChanged);
}

SharingApplication::~SharingApplication()
{
    //
}

/* ************************************************************************** */

bool SharingApplication::event(QEvent *e)
{
    // macOS "drag to dock" feature
    if (e->type() == QEvent::FileOpen)
    {
        QFileOpenEvent *openEvent = static_cast<QFileOpenEvent *>(e);
        if (QFile::exists(openEvent->file()))
        {
            Q_EMIT fileDropped(openEvent->file());
        }
    }

    return QGuiApplication::event(e);
}

void SharingApplication::onApplicationStateChanged(Qt::ApplicationState appState)
{
    if (appState == Qt::ApplicationState::ApplicationActive)
    {
        if (!mPendingIntentsChecked)
        {
            mPendingIntentsChecked = true;
            mShareUtils->checkPendingIntents(mAppDataFilesPath);
        }
    }
}

/* ************************************************************************** */

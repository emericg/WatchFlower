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

#include "MobileSharing_QmlDispatcher.h"
#include "MobileSharing.h"

/* ************************************************************************** */

MobileSharing_QmlDispatcher::MobileSharing_QmlDispatcher(QObject *parent) : QObject(parent)
{
    MobileSharing *ms = MobileSharing::getInstance();

    connect(ms, &MobileSharing::shareFinished,       this, &MobileSharing_QmlDispatcher::shareFinished);
    connect(ms, &MobileSharing::shareNoAppAvailable, this, &MobileSharing_QmlDispatcher::shareNoAppAvailable);
    connect(ms, &MobileSharing::shareError,          this, &MobileSharing_QmlDispatcher::shareError);

    connect(ms, &MobileSharing::fileSaved,           this, &MobileSharing_QmlDispatcher::fileSaved);
    connect(ms, &MobileSharing::fileReceived,        this, &MobileSharing_QmlDispatcher::fileReceived);
}

/* ************************************************************************** */

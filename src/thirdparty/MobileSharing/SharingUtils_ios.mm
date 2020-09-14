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

#import "SharingUtils_ios.h"
#import "docviewcontroller_ios.h"

#import <UIKit/UIKit.h>
#import <QGuiApplication>
#import <QQuickWindow>
#import <QDesktopServices>
#import <QUrl>
#import <QFileInfo>

#import <UIKit/UIDocumentInteractionController.h>

/* ************************************************************************** */

IosShareUtils::IosShareUtils(QObject *parent) : PlatformShareUtils(parent)
{
    // Sharing Files from other iOS Apps I got the ideas and some code contribution from:
    // Thomas K. Fischer (@taskfabric) - http://taskfabric.com - thx
    QDesktopServices::setUrlHandler("file", this, "handleFileUrlReceived");
}

/* ************************************************************************** */

bool IosShareUtils::checkMimeTypeView(const QString &mimeType) {
#pragma unused (mimeType)
    // MimeType not used yet
    return true;
}

bool IosShareUtils::checkMimeTypeEdit(const QString &mimeType) {
#pragma unused (mimeType)
    // MimeType not used yet
    return true;
}

void IosShareUtils::share(const QString &text, const QUrl &url) {

    NSMutableArray *sharingItems = [NSMutableArray new];

    if (!text.isEmpty()) {
        [sharingItems addObject:text.toNSString()];
    }
    if (url.isValid()) {
        [sharingItems addObject:url.toNSURL()];
    }

    // get the main window rootViewController
    UIViewController *qtUIViewController = [[UIApplication sharedApplication].keyWindow rootViewController];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    if ( [activityController respondsToSelector:@selector(popoverPresentationController)] ) { // iOS8
        activityController.popoverPresentationController.sourceView = qtUIViewController.view;
    }
    [qtUIViewController presentViewController:activityController animated:YES completion:nil];
}

void IosShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    NSString *nsFilePath = filePath.toNSString();
    NSURL *nsFileUrl = [NSURL fileURLWithPath:nsFilePath];

    static DocViewController *docViewController = nil;
    if (docViewController != nil) {
        [docViewController removeFromParentViewController];
        [docViewController release];
    }

    UIDocumentInteractionController *documentInteractionController = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:nsFileUrl];

    UIViewController *qtUIViewController = [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    if (qtUIViewController!=nil) {
        docViewController = [[DocViewController alloc] init];

        docViewController.requestId = requestId;
        // we need this to be able to execute handleDocumentPreviewDone() method,
        // when preview was finished
        docViewController.mIosShareUtils = this;

        [qtUIViewController addChildViewController:docViewController];
        documentInteractionController.delegate = docViewController;
        // [documentInteractionController presentPreviewAnimated:YES];
        if (![documentInteractionController presentPreviewAnimated:YES]) {
            emit shareError(0, QString("No App found to open: %1").arg(filePath));
        }
    }
}

void IosShareUtils::viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    sendFile(filePath, title, mimeType, requestId);
}

void IosShareUtils::editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    sendFile(filePath, title, mimeType, requestId);
}

void IosShareUtils::handleDocumentPreviewDone(const int &requestId)
{
    // documentInteractionControllerDidEndPreview
    qDebug() << "handleShareDone: " << requestId;
    emit shareFinished(requestId);
}

void IosShareUtils::handleFileUrlReceived(const QUrl &url)
{
    QString incomingUrl = url.toString();
    if (incomingUrl.isEmpty()) {
        qWarning() << "setFileUrlReceived: we got an empty URL";
        emit shareError(0, "Empty URL received");
        return;
    }
    qDebug() << "IosShareUtils setFileUrlReceived: we got the File URL from iOS: " << incomingUrl;
    QString myUrl;
    if (incomingUrl.startsWith("file://")) {
        myUrl = incomingUrl.right(incomingUrl.length()-7);
        qDebug() << "QFile needs this URL: " << myUrl;
    } else {
        myUrl = incomingUrl;
    }

    // check if File exists
    QFileInfo fileInfo = QFileInfo(myUrl);
    if (fileInfo.exists()) {
        emit fileUrlReceived(myUrl);
    } else {
        qDebug() << "setFileUrlReceived: FILE does NOT exist ";
        emit shareError(0, QString("File does not exist: %1").arg(myUrl));
    }
}

/* ************************************************************************** */

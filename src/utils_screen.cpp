/*!
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2019
 */

#include "utils_screen.h"

#include <QApplication>
#include <QScreen>
#include <QWindow>
#include <QDebug>

#if defined(Q_OS_IOS)
#include <QtGui/qpa/qplatformwindow.h>
#endif

#include <cmath>

/* ************************************************************************** */

void UtilsScreen::getScreenInfos()
{
    qDebug() << "UtilsScreen::getScreenInfos()";

    QScreen *scr = QApplication::primaryScreen();
    if (scr)
    {
        qDebug() << "- physicalSize (mm) " << scr->physicalSize();
        qDebug() << "- dpi " << scr->physicalDotsPerInch();
        qDebug() << "- pixel ratio " << scr->devicePixelRatio();

        if (scr->devicePixelRatio() == 1.0)
        {
            qDebug() << "- pixel size" << scr->size();
        }
        else
        {
            qDebug() << "- pixel size (hdpi corrected)" << scr->size();
            qDebug() << "- pixel size (physical) " << scr->size() * scr->devicePixelRatio();
        }

        // TODO // On Android, physicalSize().height seems to ignore the buttons and/or status bar
        qDebug() << "- inches count: " << getScreenSize();
    }
    else
    {
        qDebug() << "- Unable to get screen infos :-(";
    }
}

double UtilsScreen::getScreenSize()
{
    if (m_screenSize <= 0)
    {
        QScreen *scr = QApplication::primaryScreen();
        if (scr)
        {
            // TODO // On Android, physicalSize().height seems to ignore the buttons and/or status bar
            m_screenSize = std::sqrt(std::pow(scr->physicalSize().width(), 2.0) + std::pow(scr->physicalSize().height(), 2.0)) / (2.54 * 10.0);
        }
    }

    return m_screenSize;
}

int UtilsScreen::getScreenDpi()
{
    if (m_screenDpi <= 0)
    {
        QScreen *scr = QApplication::primaryScreen();
        if (scr)
        {
            m_screenDpi = static_cast<int>(std::round(scr->physicalDotsPerInch()));
        }
    }

    return m_screenDpi;
}

/* ************************************************************************** */

QVariantMap UtilsScreen::getSafeAreaMargins(QQuickWindow *window)
{
    QVariantMap map;

    if (window)
    {
#if defined(Q_OS_IOS)
        QPlatformWindow *platformWindow = static_cast<QPlatformWindow *>(window->handle());
        if (platformWindow)
        {
            QMargins margins = platformWindow->safeAreaMargins();
            map["top"] = margins.top();
            map["right"] = margins.right();
            map["bottom"] = margins.bottom();
            map["left"] = margins.left();
            map["total"] = margins.top() + margins.right() + margins.bottom() + margins.left();
        }
        else
        {
            qDebug() << "getSafeAreaMargins() No QPlatformWindow available";
        }
#endif // defined(Q_OS_IOS)
    }
    else
    {
        qDebug() << "getSafeAreaMargins() No QQuickWindow available";
    }

    return map;
}

/* ************************************************************************** */

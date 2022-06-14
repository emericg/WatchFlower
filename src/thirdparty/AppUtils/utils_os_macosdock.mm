/*!
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
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
 * \date      2019
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "utils_os_macosdock.h"

#if defined(Q_OS_MACOS)

#include <AppKit/AppKit.h>
#include <objc/runtime.h>

static MacOSDockHandler *instance = nullptr;

/* ************************************************************************** */

bool dockClickHandler(id self, SEL _cmd, ...)
{
    Q_UNUSED(self)
    Q_UNUSED(_cmd)

    if (instance)
    {
        Q_EMIT instance->dockIconClicked();
    }

    // Return NO (false) to suppress the default macOS actions
    return false;
}

void setupDockClickHandler()
{
    Class delClass = (Class)[[[NSApplication sharedApplication] delegate] class];
    SEL shouldHandle = sel_registerName("applicationShouldHandleReopen:hasVisibleWindows:");
    class_replaceMethod(delClass, shouldHandle, reinterpret_cast<IMP>(dockClickHandler), "B@:");
}

/* ************************************************************************** */

MacOSDockHandler *MacOSDockHandler::getInstance()
{
    if (instance == nullptr)
    {
        instance = new MacOSDockHandler();
    }

    return instance;
}

MacOSDockHandler::MacOSDockHandler() : QObject()
{
    setupDockClickHandler();
}

MacOSDockHandler::~MacOSDockHandler()
{
    delete instance;
}

/* ************************************************************************** */
#endif // Q_OS_MACOS

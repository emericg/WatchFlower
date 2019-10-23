/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
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

#ifndef MACOS_DOCK_MANAGER_H
#define MACOS_DOCK_MANAGER_H
/* ************************************************************************** */

#include <QObject>

/* ************************************************************************** */

#if defined(Q_OS_MACOS)

/*!
 * \brief macOS dock manager, to hande dock icon clicks
 */
class MacOSDockManager : public QObject
{
    Q_OBJECT

    MacOSDockManager();
    ~MacOSDockManager();

signals:
    void dockIconClicked();

public:
    static MacOSDockManager *getInstance();
};

#endif // defined(Q_OS_MACOS)

/* ************************************************************************** */
#endif // MACOS_DOCK_MANAGER_H

/*
*   Copyright (C) 2016 by Marco Martin <mart@kde.org>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/

import QtQuick 2.5
import "templates" as T

/**
 * An overlay sheet that covers the current Page content.
 * Its contents can be scrolled up or down, scrolling all the way up or
 * all the way down, dismisses it.
 * Use this for big, modal dialogs or information display, that can't be
 * logically done as a new separate Page, even if potentially
 * are taller than the screen space.
 */
T.OverlaySheet {
    id: root

    /**
     * opened: bool
     * If true the sheet is open showing the contents of the OverlaySheet
     * component.
     */
    //property bool opened

    /**
     * leftPadding: int
     * default contents padding at left
     */
    //property int leftPadding: Units.gridUnit

    /**
     * topPadding: int
     * default contents padding at top
     */
    //property int topPadding: Units.gridUnit

    /**
     * rightPadding: int
     * default contents padding at right
     */
    //property int rightPadding: Units.gridUnit

    /**
     * bottomPadding: int
     * default contents padding at bottom
     */
    //property int bottomPadding: Units.gridUnit
}
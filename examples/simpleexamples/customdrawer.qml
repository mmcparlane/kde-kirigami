/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    globalDrawer: Kirigami.OverlayDrawer {
        contentItem: Rectangle {
            implicitWidth: Kirigami.Units.gridUnit * 10
            color: "red"
            anchors.fill: parent
        }
    }
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: mainPageComponent

    Component {
        id: mainPageComponent
        Kirigami.ScrollablePage {
            title: "Hello"
            Rectangle {
                anchors.fill: parent
            }
        }
    }


}

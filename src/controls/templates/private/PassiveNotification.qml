/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.4

MouseArea {
    id: root
    z: 9999999
    width: background.width
    height: background.height
    opacity: 0
    enabled: appearAnimation.appear

    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: Units.gridUnit * 4
    }
    function showNotification(message, timeout, actionText, callBack) {
        if (!message) {
            return;
        }
        appearAnimation.running = false;
        appearAnimation.appear = true;
        appearAnimation.running = true;
        if (timeout == "short") {
            timer.interval = 4000;
        } else if (timeout == "long") {
            timer.interval = 12000;
        } else if (timeout > 0) {
            timer.interval = timeout;
        } else {
            timer.interval = 7000;
        }
        messageLabel.text = message ? message : "";
        actionButton.text = actionText ? actionText : "";
        actionButton.callBack = callBack ? callBack : "";

        timer.stop(); // stop first to ensure it always starts anew

        // Only start the timer when the window has focus, to ensure that
        // messages don't get missed on the desktop where it's common to
        //be working with multiple windows at once
        timer.running = Qt.binding(function() {
            return root.Window.active;
        });
    }

    function hideNotification() {
        appearAnimation.running = false;
        appearAnimation.appear = false;
        appearAnimation.running = true;
    }


    onClicked: {
        appearAnimation.appear = false;
        appearAnimation.running = true;
    }

    transform: Translate {
        id: transform
        y: root.height
    }

    Timer {
        id: timer
        interval: 4000
        onTriggered: {
            appearAnimation.appear = false;
            appearAnimation.running = true;
        }
    }
    ParallelAnimation {
        id: appearAnimation
        property bool appear: true
        NumberAnimation {
            target: root
            properties: "opacity"
            to: appearAnimation.appear ? 1 : 0
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: transform
            properties: "y"
            to: appearAnimation.appear ? 0 : background.height
            duration: Units.longDuration
            easing.type: appearAnimation.appear ? Easing.OutQuad : Easing.InQuad
        }
    }

    Item {
        id: background
        width: backgroundRect.width + Units.gridUnit
        height: backgroundRect.height + Units.gridUnit
        Rectangle {
            id: backgroundRect
            anchors.centerIn: parent
            radius: Units.smallSpacing
            color: Theme.textColor
            opacity: 0.6
            width: mainLayout.width + Math.round((height - mainLayout.height))
            height: Math.max(mainLayout.height + Units.smallSpacing*2, Units.gridUnit*2)
        }
        RowLayout {
            id: mainLayout
            anchors.centerIn: parent
            QQC2.Label {
                id: messageLabel
                Layout.maximumWidth: Math.min(root.parent.width - Units.largeSpacing*2, implicitWidth)
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                color: Theme.backgroundColor
            }
            QQC2.Button {
                id: actionButton
                property var callBack
                visible: text != ""
                onClicked: {
                    appearAnimation.appear = false;
                    appearAnimation.running = true;
                    if (callBack) {
                        callBack();
                    }
                }
            }
        }
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: Units.gridUnit
            samples: 32
            color: Qt.rgba(0, 0, 0, 0.5)
        }
    }
}


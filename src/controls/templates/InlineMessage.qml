/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Templates 2.0 as T2
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.5 as Kirigami
import "private"

/**
 * An inline message item with support for informational, positive,
 * warning and error types, and with support for associated actions.
 *
 * InlineMessage can be used to give information to the user or
 * interact with the user, without requiring the use of a dialog.
 *
 * The InlineMessage item is hidden by default. It also manages its
 * height (and implicitHeight) during an animated reveal when shown.
 * You should avoid setting height on an InlineMessage unless it is
 * already visible.
 *
 * Optionally an icon can be set, defaulting to an icon appropriate
 * to the message type otherwise.
 *
 * Optionally a close button can be shown.
 *
 * Actions are added from left to right. If more actions are set than
 * can fit, an overflow menu is provided.
 *
 * Example:
 * @code
 * InlineMessage {
 *     type: Kirigami.MessageType.Error
 *
 *     text: "My error message"
 *
 *     actions: [
 *         Kirigami.Action {
 *             iconName: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         },
 *         Kirigami.Action {
 *             iconName: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *     ]
 * }
 * @endcode
 *
 * @since 5.45
 */

T2.Control {
    id: root

    visible: false

    /**
     * Emitted when a link is hovered in the message text.
     * @param The hovered link.
     */
    signal linkHovered(string link)

    /**
     * Emitted when a link is clicked or tapped in the message text.
     * @param The clicked or tapped link.
     */
    signal linkActivated(string link)

    /**
     * type: int
     * The message type. One of Information, Positive, Warning or Error.
     *
     * The default is Kirigami.MessageType.Information.
     */
    property int type: Kirigami.MessageType.Information

    /**
     * A grouped property describing an optional icon.
     * * source: The source of the icon, a freedesktop-compatible icon name is recommended.
     * * color: An optional tint color for the icon.
     *
     * If no custom icon is set, an icon appropriate to the message type
     * is shown.
     */
    property IconPropertiesGroup icon: IconPropertiesGroup {}

    /**
     * text: string
     * The message text.
     */
    property string text

    /**
     * showCloseButton: bool
     * When enabled, a close button is shown.
     * The default is false.
     */
    property bool showCloseButton: false

    /**
     * actions: list<Action>
     * The list of actions to show. Actions are added from left to
     * right. If more actions are set than can fit, an overflow menu is
     * provided.
     */
    property list<QtObject> actions

    /**
     * animating: bool
     * True while the message item is animating.
     */
    readonly property bool animating: root.hasOwnProperty("_animating") && _animating

    implicitHeight: visible ? contentLayout.implicitHeight + (2 * (background.border.width + Kirigami.Units.smallSpacing)) : 0

    property bool _animating: false

    leftPadding: background.border.width + Kirigami.Units.smallSpacing
    topPadding: background.border.width + Kirigami.Units.smallSpacing
    rightPadding: background.border.width + Kirigami.Units.smallSpacing
    bottomPadding: background.border.width + Kirigami.Units.smallSpacing

    Behavior on implicitHeight {
        enabled: !root.visible

        SequentialAnimation {
            PropertyAction { targets: root; property: "_animating"; value: true }
            NumberAnimation { duration: Kirigami.Units.longDuration }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            contentLayout.opacity = 0.0;
        }
    }

    opacity: visible ? 1.0 : 0.0

    Behavior on opacity {
        enabled: !root.visible

        NumberAnimation { duration: Kirigami.Units.shortDuration }
    }

    onOpacityChanged: {
        if (opacity == 0.0) {
            contentLayout.opacity = 0.0;
        } else if (opacity == 1.0) {
            contentLayout.opacity = 1.0;
        }
    }

    onImplicitHeightChanged: {
        height = implicitHeight;
    }

    contentItem: GridLayout {
        id: contentLayout

        // Used to defer opacity animation until we know if InlineMessage was
        // initialized visible.
        property bool complete: false

        Behavior on opacity {
            enabled: root.visible && contentLayout.complete

            SequentialAnimation {
                NumberAnimation { duration: Kirigami.Units.shortDuration * 2 }
                PropertyAction { targets: root; property: "_animating"; value: false }
            }
        }

        rowSpacing: Kirigami.Units.largeSpacing
        columnSpacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            id: icon

            width: Kirigami.Units.iconSizes.smallMedium
            height: width

            Layout.alignment: text.lineCount > 1 ? Qt.AlignTop : Qt.AlignVCenter

            Layout.minimumWidth: width
            Layout.minimumHeight: height

            source: {
                if (root.icon.source) {
                    return root.icon.source;
                }

                if (root.type == Kirigami.MessageType.Positive) {
                    return "dialog-positive";
                } else if (root.type == Kirigami.MessageType.Warning) {
                    return "dialog-warning";
                } else if (root.type == Kirigami.MessageType.Error) {
                    return "dialog-error";
                }

                return "dialog-information";
            }

            color: root.icon.color
        }

        MouseArea {
            implicitHeight: text.implicitHeight

            Layout.fillWidth: true
            Layout.alignment: text.lineCount > 1 ? Qt.AlignTop : Qt.AlignVCenter
            Layout.row: 0
            Layout.column: 1

            cursorShape: text.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor

            Controls.Label {
                id: text

                width: parent.width

                color: Kirigami.Theme.textColor
                wrapMode: Text.WordWrap
                elide: Text.ElideRight

                text: root.text

                onLinkHovered: root.linkHovered(link)
                onLinkActivated: root.linkActivated(link)
            }
            //this must be child of an item which doesn't try to resize it
            TextMetrics {
                id: messageTextMetrics

                font: text.font
                text: text.text
            }
        }

        Kirigami.ActionToolBar {
            id: actionsLayout

            flat: false
            actions: root.actions
            visible: root.actions.length
            alignment: Qt.AlignRight

            Layout.alignment: Qt.AlignRight
            Layout.maximumWidth: maximumContentWidth
            Layout.fillWidth: true

            Layout.row: {
                var width = contentLayout.width - icon.width - actionsLayout.maximumContentWidth
                            - (closeButton.visible ? closeButton.width : 0)
                            - 3 * contentLayout.columnSpacing

                if (messageTextMetrics.width + Kirigami.Units.smallSpacing > width) {
                    return 1;
                }
                return 0;
            }
            Layout.column: Layout.row ? 0 : 2
            Layout.columnSpan: Layout.row ? (closeButton.visible ? 3 : 2) : 1
        }

        Controls.ToolButton {
            id: closeButton

            visible: root.showCloseButton

            Layout.alignment: text.lineCount > 1 || actionsLayout.Layout.row ? Qt.AlignTop : Qt.AlignVCenter
            Layout.row: 0
            Layout.column: actionsLayout.Layout.row ? 2 : 3

            icon.name: "dialog-close"

            onClicked: root.visible = false
        }

        Component.onCompleted: complete = true
    }
}

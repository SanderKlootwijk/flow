/*
* Copyright (C) 2025  Sander Klootwijk
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; version 3.
*
* flow is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

ListItem {
    id: queueItem
    
    width: parent.width
    height: units.gu(8)

    swipeEnabled: removeAction.enabled

    leadingActions: ListItemActions {
        actions: [
            Action {
                id: removeAction
                enabled: player.playerType == "mod"
                iconName: "delete"
                onTriggered: {
                    player.removeTrackAtIndex(trackIndex)
                }
            }
        ]
    }

    Rectangle {
        anchors.fill: parent

        color: queueItem.highlightColor

        visible: queueListView.currentIndex == trackIndex
    }

    LomiriShape {
        id: albumArtImageShape

        width: units.gu(6)
        height: units.gu(6)

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        source: Image {
            source: "https://e-cdns-images.dzcdn.net/images/cover/" + image + "/96x96-000000-80-0-0.jpg"
        }
        
        aspect: LomiriShape.Flat
        backgroundColor: settings.darkMode == false ? theme.palette.normal.base : theme.palette.normal.overlay
    }

    Column {
        id: infoColumn

        width: parent.width - units.gu(11)
        height: units.gu(5)

        anchors {
            left: albumArtImageShape.right
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }

        spacing: units.gu(0.5)

        Label {
            id: titleLabel

            width: parent.width
            
            anchors.left: parent.left
                                
            maximumLineCount: 1
            elide: Text.ElideRight
            
            text: title
        }

        Label {
            id: artistAlbumLabel

            width: parent.width

            anchors.left: parent.left

            maximumLineCount: 1
            elide: Text.ElideRight
            textSize: Label.Small

            text: artist + " - " + album
        }
    }

    onClicked: {
        player.playTrackAtIndex(trackIndex)
    }
}
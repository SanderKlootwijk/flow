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
    id: playlistItem
    
    width: parent.width
    height: units.gu(8)

    enabled: player.playerLoaded

    property string playlistID: id

    LomiriShape {
        id: imageShape

        height: units.gu(6)
        width: height

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        source: Image {
            source: image
        }

        aspect: LomiriShape.Flat
        backgroundColor: settings.darkMode == false ? theme.palette.normal.base : theme.palette.normal.overlay
    }

    Column {
        id: infoColumn

        height: units.gu(5)

        anchors {
            left: imageShape.right
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(7)
            verticalCenter: imageShape.verticalCenter
        }

        spacing: units.gu(0.5)

        Label {
            id: titleLabel

            width: parent.width
            
            anchors.left: parent.left
                                
            font.bold: true
            maximumLineCount: 1
            elide: Text.ElideRight
            
            text: title
        }

        Label {
            id: songCountLabel

            width: parent.width

            anchors.left: parent.left

            maximumLineCount: 1
            elide: Text.ElideRight

            text: songCount + " " + i18n.tr("songs")
        }
    }

    Icon {
        height: units.gu(3)
        width: units.gu(3)

        visible: player.playerContextID == playlistID.toString()

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)    
        }

        name: {
            if (player.playerContextID == playlistID.toString()) {
                player.playingState ? "media-playback-pause" : "media-playback-start"
            }
            else {
                "media-playback-start"
            }
        }
        
        color: titleLabel.color
    }

    onClicked: {
        if (player.playerContextID == playlistID.toString()) {
            player.togglePause()
        }
        else {
            player.play("playlist", playlistID, false, 0, "profile_playlists")
        }
    }
}
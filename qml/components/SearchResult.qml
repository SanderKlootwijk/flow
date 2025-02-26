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
    id: searchResult
    
    width: parent.width
    height: units.gu(8)

    property string resultID: id

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
            rightMargin: units.gu(2)
            verticalCenter: imageShape.verticalCenter
        }

        spacing: units.gu(0.5)

        Label {
            width: parent.width
            
            anchors.left: parent.left
                                
            font.bold: true
            maximumLineCount: 1
            elide: Text.ElideRight
            
            text: title
        }

        Label {
            width: parent.width

            anchors.left: parent.left

            maximumLineCount: 1
            elide: Text.ElideRight

            text: subTitle
        }
    }

    onClicked: {
        if (searchPage.searchSectionIndex == 0) {
            player.play("track_mix", resultID, true, 0, "search_page", true)
        }
        else if (searchPage.searchSectionIndex == 1) {
            player.play("album", resultID, false, 0, "search_album")
        }
        else if (searchPage.searchSectionIndex == 2) {
            player.play("playlist", resultID, false, 0, "search_playlist")
        }
        else if (searchPage.searchSectionIndex == 3) {
            player.play("artist", resultID, true, 0, "search_artist")
        }

        adaptivePageLayout.removePages(searchPage)
        searchField.text = null
        searchField.searchExecuted = false
        searchListModel.clear()
    }
}
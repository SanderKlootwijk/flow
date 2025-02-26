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

import QtQuick 2.9
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import "../components"

Page {
    id: lyricsPage
    
    property alias lyricsLabel: lyricsLabel
    property alias metadataLabel: metadataLabel
    property alias lyricsFlickable: lyricsFlickable

    header: PageHeader {
        id: lyricsPageHeader
        
        title: i18n.tr("Lyrics")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    adaptivePageLayout.removePages(lyricsPage)
                    lyricsFlickable.contentY = 0
                }
            }
        ]
    }

    Flickable {
        id: lyricsFlickable

        contentWidth: lyricsColumn.width
        contentHeight: lyricsColumn.height

        anchors {
            fill: parent
            topMargin: lyricsPageHeader.height
        }

        Column {
            id: lyricsColumn

            width: lyricsPage.width

            Item {
                width: parent.width
                height: units.gu(4)
            }

            Label {
                id: lyricsLabel

                width: lyricsPage.width - units.gu(8)

                anchors.horizontalCenter: parent.horizontalCenter

                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                textSize: Label.Large
            }

            Item {
                width: parent.width
                height: units.gu(4)
            }

            Label {
                id: metadataLabel

                width: lyricsPage.width - units.gu(4)

                anchors.horizontalCenter: parent.horizontalCenter

                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: theme.palette.normal.backgroundSecondaryText
            }

            Item {
                width: parent.width
                height: units.gu(4)

                visible: metadataLabel.text.length > 0
            }
        }
    }

    Scrollbar {
        z: 1

        flickableItem: lyricsFlickable
        align: Qt.AlignTrailing
    }
}
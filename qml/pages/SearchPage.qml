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
    id: searchPage
    
    property alias searchListModel: searchListModel
    property alias searchField: searchField
    property int searchSectionIndex: 0

    header: searchPageHeader

    PageHeader {
        id: searchPageHeader

        contents: TextField {
            id: searchField

            property bool searchExecuted: false

            width: Math.min(parent.width)
            
            anchors.centerIn: parent

            objectName: "searchField"
            
            enabled: !root.searchLoading
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: {
                if (searchSectionIndex == 0) {
                    i18n.tr("Search for tracks") + "..."
                }
                else if (searchSectionIndex == 1) {
                    i18n.tr("Search for albums") + "..."
                }
                else if (searchSectionIndex == 2) {
                    i18n.tr("Search for playlists") + "..."
                }
                else if (searchSectionIndex == 3) {
                    i18n.tr("Search for artists") + "..."
                }
            }
            hasClearButton: false
            
            onAccepted: {
                if (searchSectionIndex == 0) {
                    searchUrl = "https://api.deezer.com/search/track?q=" + searchField.text
                }
                else if (searchSectionIndex == 1) {
                    searchUrl = "https://api.deezer.com/search/album?q=" + searchField.text
                }
                else if (searchSectionIndex == 2) {
                    searchUrl = "https://api.deezer.com/search/playlist?q=" + searchField.text
                }
                else if (searchSectionIndex == 3) {
                    searchUrl = "https://api.deezer.com/search/artist?q=" + searchField.text
                }
                getSearchResults()
                searchExecuted = true
            }
        }

        extension: Sections {
            id: searchSections

            width: parent.width

            model: [i18n.tr("Tracks"), i18n.tr("Albums"), i18n.tr("Playlists"), i18n.tr("Artists")]
            
            onSelectedIndexChanged: {
                if (searchField.text == "") {
                    searchSectionIndex = selectedIndex
                }
                else {
                    searchSectionIndex = selectedIndex
                    
                    searchField.searchExecuted = false
                    if (searchSectionIndex == 0) {
                        searchUrl = "https://api.deezer.com/search/track?q=" + searchField.text
                    }
                    else if (searchSectionIndex == 1) {
                        searchUrl = "https://api.deezer.com/search/album?q=" + searchField.text
                    }
                    else if (searchSectionIndex == 2) {
                        searchUrl = "https://api.deezer.com/search/playlist?q=" + searchField.text
                    }
                    else if (searchSectionIndex == 3) {
                        searchUrl = "https://api.deezer.com/search/artist?q=" + searchField.text
                    }
                    searchListModel.clear()
                    getSearchResults()
                    searchField.searchExecuted = true
                }
            }
        }

        onVisibleChanged: if (visible) searchField.forceActiveFocus()
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    adaptivePageLayout.removePages(searchPage)
                    searchField.text = null
                    searchField.searchExecuted = false
                    searchListModel.clear()
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "find"
                onTriggered: {
                    if (!root.searchLoading) {
                        searchUrl = "https://api.deezer.com/search/track?q=" + searchField.text
                        getSearchResults()
                        searchField.searchExecuted = true
                    }
                }
            }
        ]        
    }

    Scrollbar {
        z: 1
        flickableItem: searchFlickable
        align: Qt.AlignTrailing
    }

    ActivityIndicator {
        id: loadingIndicator
        running: root.searchLoading

        anchors {
            centerIn: parent
        }
    }

    Label {
        width: parent.width - units.gu(8)

        visible: !loadingIndicator.running

        anchors {
            top: searchPageHeader.bottom
            topMargin: units.gu(13)
            horizontalCenter: parent.horizontalCenter
        }

        text: {
            if (searchListModel.count == 0 && searchField.searchExecuted) {
                if (searchSections.selectedIndex == 0) {
                    i18n.tr("No tracks found")
                }
                else if (searchSections.selectedIndex == 1) {
                    i18n.tr("No albums found")
                }
                else if (searchSections.selectedIndex == 2) {
                    i18n.tr("No playlists found")
                }
                else if (searchSections.selectedIndex == 3) {
                    i18n.tr("No artists found")
                }
            }
            else {
                ""
            }
        }

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    ListModel {
        id: searchListModel
    }

    Flickable {
        id: searchFlickable

        anchors {
            fill: parent
            topMargin: searchPageHeader.height
        }
        
        contentHeight: searchColumn.height

        Column {
            id: searchColumn
            
            width: parent.width

            Repeater {
                id: searchListView

                width: parent.width

                visible: !root.searchLoading

                model: searchListModel

                delegate: SearchResult {}
            }
        }
    }
}
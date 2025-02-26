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
    id: mainPage

    property alias playlistsListModel: playlistsListModel

    header: PageHeader {
        id: mainPageHeader
        title: i18n.tr("Flow")

        trailingActionBar {
            numberOfSlots: 2

            actions: [
                Action {
                    iconName: "toolkit_input-search"
                    text: i18n.tr("Search")
                    enabled: player.playerLoaded
                    onTriggered: {
                        mainPage.pageStack.addPageToCurrentColumn(mainPage, searchPage)
                    }
                },
                Action {
                    iconName: "settings"
                    text: i18n.tr("Settings")
                    onTriggered: {
                        mainPage.pageStack.addPageToCurrentColumn(mainPage, settingsPage)
                    }
                },
                Action {
                    iconName: "info"
                    text: i18n.tr("About")
                    onTriggered: {
                        mainPage.pageStack.addPageToCurrentColumn(mainPage, aboutPage)
                    }
                }
            ]
        }

        extension: Sections {
            id: mainPageHeaderSections

            actions: [
                Action {
                    text: i18n.tr("Home")
                },
                Action {
                    text: i18n.tr("Playlists")
                }
            ]
        }
    }

    ListModel {
        id: playlistsListModel
    }

    Item {
        id: homeItem

        visible: mainPageHeaderSections.selectedIndex == 0

        anchors {
            fill: parent
            topMargin: mainPageHeader.height
            bottomMargin: bottomMenu.visible ? bottomMenu.height - units.dp(1) : 0
        }

        Scrollbar {
            z: 1

            id: homeScrollbar

            flickableItem: homeFlickable
            align: Qt.AlignTrailing
        }

        Flickable {
            id: homeFlickable

            anchors.fill: parent

            contentWidth: homeColumn.width
            contentHeight: homeColumn.height

            clip: true

            Column {
                id: homeColumn

                width: mainPage.width

                spacing: units.gu(2)

                Row {
                    width: parent.width - units.gu(4)
                    height: units.gu(15)

                    anchors.horizontalCenter: parent.horizontalCenter

                    spacing: units.gu(2)

                    FlowShape {
                        anchors.bottom: parent.bottom

                        title: i18n.tr("Flow")
                        image: "../img/flow.svg"
                        playColor: "#b0289d"

                        radioType: "user"
                        radioId: player.userId
                        context: "dynamic_page_user_radio"
                    }

                    FlowShape {
                        anchors.bottom: parent.bottom

                        title: i18n.tr("New releases")
                        image: "../img/newreleases.png"
                        playColor: "#74e788"

                        radioType: "multi_flow"
                        radioId: "new_releases"
                        context: "dynamic_page_flow_config"
                    }                            
                }

                Label {
                    id: moodsLabel

                    width: parent.width - units.gu(4)
                    
                    anchors.horizontalCenter: parent.horizontalCenter

                    font.bold: true
                    elide: Text.ElideRight
                    color: theme.palette.normal.backgroundSecondaryText
                    
                    text: i18n.tr("Moods:")
                }

                Flickable {
                    width: parent.width - units.gu(2)
                    height: units.gu(13)

                    anchors.right: parent.right

                    contentWidth: moodsRow.width
                    contentHeight: moodsRow.height

                    clip: true

                    Row {
                        id: moodsRow

                        height: units.gu(13)

                        spacing: units.gu(2)

                        FlowShape {
                            title: i18n.tr("Workout")
                            image: "../img/motivation.png"
                            playColor: "#fc663c"

                            radioType: "multi_flow"
                            radioId: "motivation"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Party")
                            image: "../img/party.png"
                            playColor: "#df5114"

                            radioType: "multi_flow"
                            radioId: "party"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Chill")
                            image: "../img/chill.png"
                            playColor: "#c01fc3"

                            radioType: "multi_flow"
                            radioId: "chill"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Melancholy")
                            image: "../img/melancholy.png"
                            playColor: "#2cd4b7"

                            radioType: "multi_flow"
                            radioId: "melancholy"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Love")
                            image: "../img/youandme.png"
                            playColor: "#ef70f7"

                            radioType: "multi_flow"
                            radioId: "you_and_me"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Focus")
                            image: "../img/focus.png"
                            playColor: "#5465ff"

                            radioType: "multi_flow"
                            radioId: "focus"
                            context: "dynamic_page_flow_config"
                        }

                        Item {
                            width: units.dp(1)
                            height: units.gu(13)
                        }
                    }
                }

                Label {
                    id: genresLabel

                    width: parent.width - units.gu(4)
                    
                    anchors.horizontalCenter: parent.horizontalCenter

                    font.bold: true
                    elide: Text.ElideRight
                    color: theme.palette.normal.backgroundSecondaryText
                    
                    text: i18n.tr("Genres:")
                }

                Flickable {
                    width: parent.width - units.gu(2)
                    height: units.gu(13)

                    anchors.right: parent.right

                    contentWidth: genresRow.width
                    contentHeight: genresRow.height

                    clip: true

                    Row {
                        id: genresRow

                        height: units.gu(13)

                        spacing: units.gu(2)

                        FlowShape {
                            title: i18n.tr("Pop")
                            image: "../img/genre-pop.png"
                            playColor: "#7e0087"

                            radioType: "multi_flow"
                            radioId: "genre-pop"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("R&B")
                            image: "../img/genre-rnb.png"
                            playColor: "#9a199c"

                            radioType: "multi_flow"
                            radioId: "genre-rnb"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Alternative")
                            image: "../img/genre-alternative.png"
                            playColor: "#000f9a"

                            radioType: "multi_flow"
                            radioId: "genre-alternative"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Rock")
                            image: "../img/genre-rock.png"
                            playColor: "#ac1910"

                            radioType: "multi_flow"
                            radioId: "genre-rock"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Dance & EDM")
                            image: "../img/genre-danceedm.png"
                            playColor: "#20a997"

                            radioType: "multi_flow"
                            radioId: "genre-danceedm"
                            context: "dynamic_page_flow_config"
                        }

                        FlowShape {
                            title: i18n.tr("Rap")
                            image: "../img/genre-rap.png"
                            playColor: "#2b00a5"

                            radioType: "multi_flow"
                            radioId: "genre-rap"
                            context: "dynamic_page_flow_config"
                        }

                        Item {
                            width: units.dp(1)
                            height: units.gu(13)
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: units.dp(1)
                }
            }
        }
    }

    Item {
        id: playlistsItem

        visible: mainPageHeaderSections.selectedIndex == 1

        anchors {
            fill: parent
            topMargin: mainPageHeader.height
            bottomMargin: bottomMenu.visible ? bottomMenu.height - units.dp(1) : 0
        }

        Scrollbar {
            z: 1

            id: playlistsScrollbar

            flickableItem: playlistsFlickable
            align: Qt.AlignTrailing
        }

        Flickable {
            id: playlistsFlickable

            anchors.fill: parent

            contentWidth: playlistsColumn.width
            contentHeight: playlistsColumn.height

            clip: true

            Column {
                id: playlistsColumn

                width: mainPage.width

                Repeater {
                    id: playlistsListView

                    width: parent.width

                    model: playlistsListModel

                    delegate: PlaylistItem {}
                }
            }
        }
    }

    BottomMenu {
        id: bottomMenu

        visible: root.width < units.gu(90)

        width: parent.width

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
    }
}
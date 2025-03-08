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
import QtGraphicalEffects 1.12
import "../components"

Page {
    id: playerPage
    
    property alias playerPageHeaderSections: playerPageHeaderSections
    property alias queueListModel: queueListModel
    property alias queueListView: queueListView
    property var lyricsCheckAttempts: 0

    header: PageHeader {
        id: playerPageHeader
        
        title: i18n.tr("Now playing")

        trailingActionBar {
            numberOfSlots: 1

            actions: [
                Action {
                    iconName: player.favorited ? "like" : "unlike"
                    visible: playerPageHeaderSections.selectedIndex == 0
                    enabled: player.playerLoaded
                    text: i18n.tr("Favorite")
                    onTriggered: player.toggleFavorite()
                }
            ]
        }

        extension: Sections {
            id: playerPageHeaderSections

            enabled: player.playerLoaded

            actions: [
                Action {
                    text: i18n.tr("Full view")
                },
                Action {
                    text: i18n.tr("Queue")
                }
            ]

            onSelectedIndexChanged: queueListView.positionViewAtIndex(queueListView.currentIndex, ListView.Contain)
        }
    }

    ListModel {
        id: queueListModel
    }

    Item {
        id: fullViewItem

        visible: playerPageHeaderSections.selectedIndex == 0

        anchors {
            fill: parent
            topMargin: playerPageHeader.height
            bottomMargin: playerControlsItem.height
        }

        Item {
            id: albumArtContainer

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: controlsContainer.top
            }

            FastBlur {
                id: backgroundBlur

                width: parent.width
                height: width

                source: albumArtImage.progress < 1 ? fallbackImage : albumArtImage
                radius: 75
            }

            Rectangle {
                anchors {
                    top: albumArtImage.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                width: parent.width
                height: fullViewItem.height

                color: theme.palette.normal.background
            }

            Image {
                id: albumArtImage

                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                width: height
                height: {
                    if (parent.height > backgroundBlur.height) {
                        backgroundBlur.height
                    }
                    else if (parent.height < units.gu(18)) {
                        Math.min(parent.width, units.gu(18))
                    }
                    else {
                        parent.height
                    }
                }

                source: "https://e-cdns-images.dzcdn.net/images/cover/" + player.albumArt + "/512x512-000000-80-0-0.jpg"

                Image {
                    id: fallbackImage

                    visible: albumArtImage.progress < 1

                    anchors.fill: parent

                    source: Theme.name == "Lomiri.Components.Themes.Ambiance" ? "../img/coverlight.jpg" : "../img/coverdark.jpg"
                }
            }

            Button {
                id: lyricsButton

                visible: player.hasLyrics

                height: units.gu(3)
                width: lyricsButtonLabel.implicitWidth + lyricsButtonIcon.width + units.gu(2.5)

                anchors {
                    bottom: albumArtImage.bottom
                    bottomMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }

                color: theme.palette.normal.foreground

                Image {
                    id: lyricsButtonIcon

                    height: parent.height - units.gu(1.25)
                    width: height

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(1)
                    }

                    source: Theme.name == "Lomiri.Components.Themes.Ambiance" ? "../img/lyricslight.svg" : "../img/lyricsdark.svg"
                }

                Label {
                    id: lyricsButtonLabel

                    anchors {
                        top: parent.top
                        topMargin: units.gu(0.25)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    text: "Lyrics"
                }

                onClicked: {
                    player.loadLyrics()
                    lyricsTimer.restart()
                }
            }
        }

        Timer {
            id: lyricsTimer
            interval: 100
            running: false
            repeat: true
            onTriggered: {
                if (lyricsCheckAttempts >= 10) {
                    lyricsTimer.stop();
                    lyricsCheckAttempts = 0;
                    console.log("Lyrics loading timed out after 10 attempts.");
                    return;
                }

                webEngineView.runJavaScript(`
                    (function() {
                        return dzPlayer.getLyrics();
                    })();
                `, (result) => {
                    if (typeof result === "undefined") {
                        lyricsCheckAttempts++;
                        lyricsTimer.start();
                    } else {
                        lyricsTimer.stop();
                        lyricsCheckAttempts = 0;
                        player.getLyrics();
                    }
                });
            }
        }

        Item {
            id: controlsContainer

            enabled: player.playerLoaded

            width: parent.width
            height: songInfoColumn.height + controlsColumn.height + units.gu(4.30)

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                anchors.fill: parent

                color: theme.palette.normal.background

                opacity: fullViewItem.height - controlsContainer.height < units.gu(18) ? 0.9 : 1
            }

            Column {
                id: songInfoColumn

                height: units.gu(5)
                width: parent.width - units.gu(4)

                anchors {
                    top: parent.top
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(2)
                }

                spacing: units.gu(0.5)

                Label {
                    id: songInfoTitle

                    width: parent.width
                    
                    anchors.left: parent.left
                                        
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    textSize: Label.Large
                    
                    text: player.songTitle
                }

                Label {
                    id: songInfoArtist

                    width: parent.width

                    anchors.left: parent.left

                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: theme.palette.normal.backgroundSecondaryText

                    text: player.artistName
                }
            }

            LomiriShape {
                id: radioTypeShape

                height: units.gu(2)
                width: radioTypeLabel.contentWidth + units.gu(1)

                visible: {
                    if (player.playerType == "radio" && player.radioType == "user") {
                        true
                    }
                    else if (player.playerType == "radio" && player.radioType == "multi_flow") {
                        true
                    }
                    else if (player.playerType == "radio" && player.radioType == "up_next_artist") {
                        true
                    }
                    else if (player.playerType == "radio" && player.radioType == "track_mix") {
                        true
                    }
                    else if (player.playerType == "radio" && player.radioType == "artist") {
                        true
                    }
                    else {
                        false
                    }
                }

                anchors {
                    left: songInfoColumn.left
                    bottom: controlsColumn.top
                    bottomMargin: units.gu(1)
                }

                backgroundColor: theme.palette.normal.foreground

                aspect: LomiriShape.Flat

                Label {
                    id: radioTypeLabel

                    anchors {
                        centerIn: parent
                    }

                    color: theme.palette.normal.foregroundText
                                
                    text: {
                        if (player.playerType == "radio" && player.radioType == "user") {
                            i18n.tr("Flow")
                        }
                        else if (player.playerType == "radio" && player.radioType == "multi_flow") {
                            i18n.tr("Flow")
                        }
                        else if (player.playerType == "radio" && player.radioType == "up_next_artist") {
                            i18n.tr("Recommended")
                        }
                        else if (player.playerType == "radio" && player.radioType == "track_mix") {
                            i18n.tr("Mixes")
                        }
                        else if (player.playerType == "radio" && player.radioType == "artist") {
                            i18n.tr("Mixes")
                        }
                        else {
                            ""
                        }
                    }
                }
            }

            Column {
                id: controlsColumn

                height: units.gu(8)
                width: parent.width - units.gu(4)

                spacing: units.gu(0.5)

                anchors {
                    top: songInfoColumn.bottom
                    topMargin: units.gu(6)
                    horizontalCenter: parent.horizontalCenter
                }

                ProgressBar {
                    id: progressBar

                    visible: false

                    minimumValue: 0
                    maximumValue: player.songDuration
                    value: player.songPosition
                }

                Slider {
                    id: playerSlider

                    width: parent.width
                    height: units.gu(2)

                    anchors.horizontalCenter: parent.horizontalCenter

                    function formatValue(v) {
                        return timeFormat(v)
                    }

                    onPressedChanged: player.seek(playerSlider.value / player.songDuration)

                    minimumValue: 0
                    maximumValue: player.songDuration
                    value: player.songPosition

                    Connections {
                        target: progressBar
                        onValueChanged: playerSlider.pressed ? "" : playerSlider.value = player.songPosition
                    }
                }

                Item {
                    id: durationItem

                    width: parent.width
                    height: units.gu(2)

                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        id: songPosition
                        
                        anchors {
                            left: parent.left
                        }
                        
                        color: theme.palette.normal.backgroundSecondaryText
                        
                        text: timeFormat(player.songPosition)
                    }

                    Label {
                        id: songDuration
                        
                        anchors {
                            right: parent.right
                        }
                        
                        color: theme.palette.normal.backgroundSecondaryText
                        
                        text: timeFormat(player.songDuration)
                    }
                }
            }    
        }
    }

    Item {
        id: queueItem

        visible: playerPageHeaderSections.selectedIndex == 1

        anchors {
            fill: parent
            topMargin: playerPageHeader.height
            bottomMargin: playerControlsItem.height
        }

        Scrollbar {
            z: 1

            id: queueScrollbar

            flickableItem: queueListView
            align: Qt.AlignTrailing
        }

        ListView {
            id: queueListView

            property int maxIndex: 0

            onCurrentIndexChanged: {
                if (currentIndex > maxIndex) {
                    maxIndex = currentIndex
                }
            }

            anchors.fill: parent

            clip: true
            
            model: queueListModel

            delegate: QueueItem {}
        }
    }

    Item {
        id: playerControlsItem

        width: parent.width
        height: units.gu(8)

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            z: 1
            
            visible: playerPageHeaderSections.selectedIndex == 1

            width: parent.width
            height: units.dp(1)

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            color: theme.palette.normal.base            
        }

        Rectangle {
            anchors.fill: parent

            color: theme.palette.normal.background

            opacity: fullViewItem.height - controlsContainer.height < units.gu(18) ? 0.9 : 1
        }

        Row {
            id: playerControls

            height: units.gu(6)

            anchors {
                top: parent.top
                topMargin: units.gu(1)
                horizontalCenter: parent.horizontalCenter
            }

            spacing: units.gu(1)

            MouseArea {
                id: shuffleButton

                height: units.gu(4)
                width: units.gu(4)

                anchors.verticalCenter: parent.verticalCenter

                onClicked: player.toggleShuffle()

                Icon {
                    height: units.gu(2)
                    width: units.gu(2)

                    anchors.centerIn: parent

                    name: "media-playlist-shuffle"
                    color: {
                        if (player.playerType != "radio") {
                            if (player.shuffle == true) {
                                theme.palette.normal.activity
                            }
                            else {
                                theme.palette.disabled.baseText
                            }
                        }
                        else {
                            theme.palette.disabled.baseText
                        }
                    }
                }
            }

            MouseArea {
                id: previousButton

                height: units.gu(4)
                width: units.gu(4)

                anchors.verticalCenter: parent.verticalCenter  

                onClicked: player.prevSong()

                Icon {
                    height: units.gu(3)
                    width: units.gu(3)

                    anchors.centerIn: parent

                    name: "media-skip-backward"
                    color: theme.palette.normal.baseText
                }
            }

            MouseArea {
                id: playPauseButton

                height: units.gu(5)
                width: units.gu(5)

                anchors.verticalCenter: parent.verticalCenter

                onClicked: player.togglePause()

                Icon {
                    height: units.gu(4)
                    width: units.gu(4)

                    anchors.centerIn: parent

                    name: player.playingState ? "media-playback-pause" : "media-playback-start"
                    color: theme.palette.normal.baseText
                }
            }

            MouseArea {
                id: nextButton

                height: units.gu(4)
                width: units.gu(4)

                anchors.verticalCenter: parent.verticalCenter  

                onClicked: player.nextSong()

                Icon {
                    height: units.gu(3)
                    width: units.gu(3)

                    anchors.centerIn: parent

                    name: "media-skip-forward"
                    color: theme.palette.normal.baseText
                }
            }

            MouseArea {
                id: repeatButton

                height: units.gu(4)
                width: units.gu(4)

                anchors.verticalCenter: parent.verticalCenter

                onClicked: player.setRepeat()

                Icon {
                    height: units.gu(2)
                    width: units.gu(2)

                    anchors.centerIn: parent

                    name: player.repeat == 2 ? "media-playlist-repeat-one" : "media-playlist-repeat"
                    color: player.repeat == 0 ? theme.palette.disabled.baseText : theme.palette.normal.activity
                }
            }
        }
    }
}
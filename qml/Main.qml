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
import UserMetrics 0.1
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtWebEngine 1.10
import "pages"
import "components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'flow.sanderklootwijk'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    anchors {
        bottomMargin: LomiriApplication.inputMethod.visible ? LomiriApplication.inputMethod.keyboardRectangle.height/(units.gridUnit / 8) : 0

        Behavior on bottomMargin {
            NumberAnimation {
                duration: 175
                easing.type: Easing.OutQuad
            }
        }
    }

    Metric {
        id: metric
        name: "flow"
        format: "<b>%1</b> " + i18n.tr("songs played on Flow today")
        emptyFormat: i18n.tr("No songs played on Flow today")
        domain: "flow.sanderklootwijk"
    }

    theme.name: {
        switch (settings.theme) {
            case 0: return "";
            case 1: return "Lomiri.Components.Themes.Ambiance";
            case 2: return "Lomiri.Components.Themes.SuruDark";
            default: return "";
        }
    }

    Component.onCompleted: {
        if (width > units.gu(90)) {
            mainPage.pageStack.addPageToNextColumn(mainPage, playerPage)
        }
    }

    onWidthChanged: {
        if (width > units.gu(90)) {
            if (!lyricsPage.visible) {
                if (mainPage.visible) {
                    mainPage.pageStack.addPageToNextColumn(mainPage, playerPage)
                }
            }
        }
    }

    // Keyboard controls
    Keys.onSpacePressed: player.togglePause()

    // App properties
    property string version: "1.4.0"

    // Webview
    property string url: webEngineView.url
      
    // Search
    property string searchUrl
    property bool searchLoading: false

    Settings {
        id: settings

        property int theme: 0
    }

    // AdaptivePageLayout
    AdaptivePageLayout {
        id: adaptivePageLayout
        
        anchors.fill: parent

        visible: player.playerLoaded
        
        primaryPage: mainPage

        layouts: [
            PageColumnsLayout {
                when: width > units.gu(90)
                // column #0
                PageColumn {
                    fillWidth: true
                }
                // column #1
                PageColumn {
                    minimumWidth: units.gu(40)
                    maximumWidth: units.gu(40)
                    preferredWidth: units.gu(40)
                }
            },
            PageColumnsLayout {
                when: true
                PageColumn {
                    fillWidth: true
                    minimumWidth: units.gu(10)
                }
            }
        ]
    }

    // Pages
    
    MainPage {
        id: mainPage

        anchors.fill: parent

        visible: false

        onVisibleChanged: {
            if (width > units.gu(90)) {
                if (mainPage.visible) {
                    if (!lyricsPage.visible) {
                        mainPage.pageStack.addPageToNextColumn(mainPage, playerPage)
                    }
                }
            }
        }
    }

    PlayerPage {
        id: playerPage

        anchors.fill: parent
        
        visible: false
    }

    LyricsPage {
        id: lyricsPage

        anchors.fill: parent
        
        visible: false
    }

    SearchPage {
        id: searchPage

        anchors.fill: parent
        
        visible: false
    }

    SettingsPage {
        id: settingsPage

        anchors.fill: parent
        
        visible: false
    }

    AboutPage {
        id: aboutPage

        anchors.fill: parent
        
        visible: false
    }

    Page {
        id: loginPage

        anchors.fill: parent
        
        visible: !player.playerLoaded

        header: PageHeader {
            id: loginPageHeader
            title: i18n.tr('Login')

            trailingActionBar {
                actions: [
                    Action {
                        iconName: "view-refresh"
                        text: i18n.tr("Refresh")
                        onTriggered: {
                            webEngineView.url = "https://www.deezer.com/login"
                        }
                    }
                ]
            }
        }

        Rectangle {
            z: 1

            id: loginOverlay

            property bool profileVisible: false

            anchors {
                fill: parent
                topMargin: loginPageHeader.height
            }

            visible: {
                if (!(root.url.includes("login") || root.url.includes("signup") || root.url.includes("activate")) && player.playerLoaded == false) {
                    true
                }
                else {
                    false
                }
            }

            onVisibleChanged: {
                loginOverlay.profileVisible = false
                profileTimer.restart()
                loadingLabelTimer.restart()
                loadingLabelTimer.index = 0
            }

            color: theme.palette.normal.background

            ActivityIndicator {
                id: loginIndicator

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: units.gu(22)
                }

                running: true
            }

            Label {
                id: loadingLabel

                anchors {
                    top: loginIndicator.bottom
                    topMargin: units.gu(2)
                    horizontalCenter: parent.horizontalCenter
                }

                Timer {
                    id: loadingLabelTimer

                    property int index: 0
                    property var loadingMessages: [
                        i18n.tr("Logging in..."),
                        i18n.tr("Fetching your favorite songs..."),
                        i18n.tr("Loading your albums..."),
                        i18n.tr("It seems to take a while...")
                    ]
                    
                    interval: 6000
                    repeat: true
                    onTriggered: {
                        if (index < loadingMessages.length) {
                            index = index + 1
                        }
                        else {
                            loadingLabelTimer.running = false
                        }
                    }
                }

                text: loadingLabelTimer.loadingMessages[loadingLabelTimer.index]

                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                visible: loginOverlay.profileVisible

                anchors {
                    top: loadingLabel.bottom
                    topMargin: units.gu(2.5)
                    horizontalCenter: parent.horizontalCenter
                }

                text: i18n.tr("Are you using a Family or Duo account?")

                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
            }

            Button {
                id: profileButton

                visible: loginOverlay.profileVisible

                anchors {
                    top: loginIndicator.bottom
                    topMargin: units.gu(11)
                    horizontalCenter: parent.horizontalCenter
                }

                text: i18n.tr("Select a profile")

                onClicked: loginOverlay.visible = false
            }

            Timer {
                id: profileTimer

                interval: 21000
                running: false
                repeat: false

                onTriggered: loginOverlay.profileVisible = true
            }
        }

        WebEngineView {
            id: webEngineView

            anchors {
                fill: parent
                topMargin: loginPageHeader.height
            }

            url: "https://www.deezer.com/login"

            settings {
                playbackRequiresUserGesture: false
            }

            userScripts: [
                WebEngineScript {
                    injectionPoint: WebEngineScript.DocumentReady
                    sourceUrl: "js/deezer.js"
                    worldId: WebEngineScript.UserWorld
                },
                WebEngineScript {
                    injectionPoint: WebEngineScript.Deferred
                    sourceCode: theme.name == "Lomiri.Components.Themes.Ambiance" ? "document.documentElement.setAttribute('data-theme', 'light')" : "document.documentElement.setAttribute('data-theme', 'dark')"
                    worldId: WebEngineScript.UserWorld
                }
            ]
        }

        ProgressBar {
            width: parent.width
            
            anchors {
                top: loginPageHeader.bottom
                left: parent.left
            }

            minimumValue: 0
            maximumValue: 10
            value: webEngineView.loadProgress
        }
    }

    Item {
        id: player

        // Song details
        property string artistName
        property string songTitle
        property string albumArt
        property bool hasLyrics
        property string songId
        property bool songCounted

        onSongIdChanged: {
            adaptivePageLayout.removePages(lyricsPage)
            lyricsPage.lyricsFlickable.contentY = 0
            player.getSongDetails()
            player.getQueue()
            player.songCounted = false
        }

        onSongPositionChanged: {
            if (player.songPosition > 10 && player.songCounted == false) {
                player.songCounted = true
                metric.increment()
            }
        }

        // Player properties
        property var currentQueueArray

        // Player
        property string playerType
        property string radioType
        property string radioId
        property string playerContextID
        property bool playingState: false
        property bool playerLoaded: false
        property bool favorited
        property var songDuration: 0
        property var songPosition: 0
        property bool metricCount: false
        property double playerVolume: 0
        property bool shuffle
        property int repeat

        onPlayerTypeChanged: {
            if (playerType == "radio") {
                if (player.shuffle) {
                    player.toggleShuffle()
                }
                player.setRepeat(0)
            }
        }

        onPlayerContextIDChanged: player.getQueue()

        // User information
        property bool playlistsLoaded: false
        property string userId

        onPlaylistsLoadedChanged: {
            player.getPlaylists()
        }

        // Timer to continuesly fetch player properties and song details
        Timer {
            id: fetchTimer
            running: true
            repeat: true
            interval: 100
            onTriggered: {
                if (!(root.url.includes("login") || root.url.includes("signup") || root.url.includes("activate"))) {
                    var script = `
                        (function() {
                            var playlistsKey = Object.keys(localStorage).find(key => key.startsWith("PLAYLISTS_"));

                            return {
                                playingState: dzPlayer.playing,
                                playerLoaded: dzPlayer.playerLoaded,
                                radioType: dzPlayer.radioType,
                                radioId: dzPlayer.radioId,
                                playerType: dzPlayer.getPlayerType(),
                                playerContextID: dzPlayer.getContext("ID"),
                                userId: playlistsKey ? playlistsKey.replace("PLAYLISTS_", "") : null,
                                songId: dzPlayer.getSongId(),
                                songDuration: dzPlayer.getDuration(),
                                songPosition: dzPlayer.getPosition(),
                                favorited: $('.chakra-button__group').find('button[class^="chakra-button"] > svg').attr("data-testid") === "HeartFilledIcon",
                                playerVolume: dzPlayer.volume,
                                shuffle: dzPlayer.shuffle,
                                repeat: dzPlayer.repeat,
                                playlistsLoaded: playlistsKey ? localStorage[playlistsKey] : null
                            };
                        })();
                    `;

                    webEngineView.runJavaScript(script, function(result) {
                        if (result) {                        
                            if (result.playingState !== undefined) {
                                player.playingState = result.playingState;
                            }
                            if (result.playerLoaded !== undefined) {
                                player.playerLoaded = result.playerLoaded;
                            }
                            if (result.radioType !== undefined) {
                                player.radioType = result.radioType;
                            }
                            if (result.radioId !== undefined) {
                                player.radioId = result.radioId;
                            }
                            if (result.playerType !== undefined) {
                                player.playerType = result.playerType;
                            }
                            if (result.playerContextID !== undefined) {
                                player.playerContextID = result.playerContextID;
                            }
                            if (result.userId !== undefined) {
                                player.userId = result.userId;
                            }
                            if (result.songId !== undefined) {
                                player.songId = result.songId;
                            }
                            if (result.artistName !== undefined) {
                                player.artistName = result.artistName;
                            }
                            if (result.songTitle !== undefined) {
                                player.songTitle = result.songTitle;
                            }
                            if (result.albumArt !== undefined) {
                                player.albumArt = result.albumArt;
                            }
                            if (result.songDuration !== undefined) {
                                player.songDuration = result.songDuration;
                            }
                            if (result.songPosition !== undefined) {
                                player.songPosition = result.songPosition;
                            }
                            if (result.favorited !== undefined) {
                                player.favorited = result.favorited;
                            }
                            if (result.playerVolume !== undefined) {
                                player.playerVolume = result.playerVolume;
                            }
                            if (result.shuffle !== undefined) {
                                player.shuffle = result.shuffle;
                            }
                            if (result.repeat !== undefined) {
                                player.repeat = result.repeat;
                            }
                            if (result.playlistsLoaded !== undefined) {
                                player.playlistsLoaded = true;
                            }
                        }
                    });
                }
            }
        }

        // Player functions
        function play(type, id, radio, index, contextType, forceAsFirstTrack) {
            const playConfig = {
                type: type,
                id: id,
                radio: radio,
                format: "MP3_MISC",
                index: index,
                context: {
                    ID: id,
                    TYPE: contextType
                },
                forceAsFirstTrack: forceAsFirstTrack
            };

            const playScript = `
                dzPlayer.play(${JSON.stringify(playConfig)});
            `;

            webEngineView.runJavaScript(playScript);
        }

        function togglePause() {
            webEngineView.runJavaScript("dzPlayer.control.togglePause()")
        }

        function prevSong() {
            webEngineView.runJavaScript("dzPlayer.control.prevSong()")
        }
        
        function nextSong() {
            webEngineView.runJavaScript("dzPlayer.control.nextSong()")
        }

        function toggleShuffle() {
            player.shuffle ? webEngineView.runJavaScript("dzPlayer.control.setShuffle(0)") : webEngineView.runJavaScript("dzPlayer.control.setShuffle(1)");
            player.getQueue();
        }

        function setRepeat(repeatMode) {
            if (repeatMode === undefined || repeatMode === null) {
                repeatMode = (player.repeat + 1) % 3;
            }

            webEngineView.runJavaScript(`dzPlayer.control.setRepeat(${repeatMode})`);
        }

        function seek(position) {
            webEngineView.runJavaScript("dzPlayer.control.seek(" + position + ")")
        }

        function setVolume(value) {
            webEngineView.runJavaScript("dzPlayer.control.setVolume(" + value + ")")
        }

        function toggleFavorite() {
            webEngineView.runJavaScript(`$('.chakra-button__group').find('button[class^="chakra-button"] > svg').filter((_, svg) => ['HeartFilledIcon', 'HeartOutlinedIcon'].includes($(svg).attr('data-testid'))).closest('button').first().click();`)
        }

        function playTrackAtIndex(index) {
            webEngineView.runJavaScript("dzPlayer.playTrackAtIndex(" + index + ")")
        }

        function loadLyrics() {
            webEngineView.runJavaScript('dzPlayer.control.loadLyrics()')
        }

        function getLyrics() {
            var lyricsScript = `
                (function() {
                    return dzPlayer.getLyrics();
                })();
            `;

            var metadataScript = `
                (function() {
                    return dzPlayer.getLyricsMetadata();
                })();
            `;

            // Fetch lyrics
            webEngineView.runJavaScript(lyricsScript, (lyricsResult) => {
                var formattedLyrics = lyricsResult
                    .map(entry => {
                        // Handle object with "line" key or plain strings
                        if (typeof entry === "string") {
                            return entry.trim(); // Trim unnecessary whitespace
                        } else if (entry && entry.line) {
                            return entry.line.trim(); // Trim line if it exists
                        }
                        return null; // Skip null, undefined, or empty entries
                    })
                    .filter(line => line) // Remove any null or empty entries
                    .join("\n\n"); // Join lines with \n
                lyricsPage.lyricsLabel.text = formattedLyrics;
                playerPage.pageStack.addPageToCurrentColumn(playerPage, lyricsPage);
            });

            // Fetch metadata
            webEngineView.runJavaScript(metadataScript, (metadataResult) => {
                if (metadataResult.copyrights.length > 0 && typeof metadataResult === "object") {
                    // Format metadata
                    var formattedMetadata = `© ${metadataResult.copyrights}\n${metadataResult.writers}`;
                    lyricsPage.metadataLabel.text = formattedMetadata;
                } else {
                    // Handle cases where metadata is undefined or unavailable
                    lyricsPage.metadataLabel.text = "";
                }
            });
        }

        function getSongDetails() {
            var script = `
                (function() {
                    return {
                        artistName: dzPlayer.getArtistName(),
                        songTitle: dzPlayer.getSongTitle(),
                        albumArt: dzPlayer.getCover(),
                        hasLyrics: dzPlayer.hasLyrics()
                    };
                })();
            `;

            webEngineView.runJavaScript(script, function(result) {
                if (result) {                        
                    if (result.artistName !== undefined) {
                        player.artistName = result.artistName;
                    }
                    if (result.songTitle !== undefined) {
                        player.songTitle = result.songTitle;
                    }
                    if (result.albumArt !== undefined) {
                        player.albumArt = result.albumArt;
                    }
                    if (result.hasLyrics !== undefined) {
                        player.hasLyrics = result.hasLyrics;
                    }
                }
            });
        }

        function getQueue() {
            var queueArray = `
                (function() {
                    return dzPlayer.getTrackList();
                })();
            `;

            var queueIndex = `
                (function() {
                    return dzPlayer.getTrackListIndex()
                })();
            `;

            webEngineView.runJavaScript(queueArray, (queueArrayResult) => {
                var currentQueueArray = player.currentQueueArray;
                player.currentQueueArray = queueArrayResult;
                if(JSON.stringify(currentQueueArray) !== JSON.stringify(queueArrayResult)) {
                    if (Array.isArray(queueArrayResult) && queueArrayResult.length > 0) {                        
                        playerPage.queueListModel.clear();
                        for (var i = 0; i < queueArrayResult.length; i++) {
                            playerPage.queueListModel.append({
                                "trackIndex": i,
                                "id": queueArrayResult[i].SNG_ID,
                                "title": queueArrayResult[i].SNG_TITLE,
                                "artist": queueArrayResult[i].ART_NAME,
                                "album": queueArrayResult[i].ALB_TITLE,
                                "image": queueArrayResult[i].ALB_PICTURE
                            });
                        }
                        playerPage.queueListView.maxIndex = 0;
                    } else {
                        console.log("No queue data received or invalid format.");
                    }
                } else {
                    console.log("Queue data unchanged.");
                }
            });

            webEngineView.runJavaScript(queueIndex, (queueIndexResult) => {
                playerPage.queueListView.currentIndex = queueIndexResult;
            });
        }

        function removeTrackAtIndex(index) {
            webEngineView.runJavaScript(`dzPlayer.removeTracks(${index})`);

            getQueue();
        }

        function getPlaylists() {
            var script = `
                (function() {
                    var playlists = Object.keys(localStorage).find(key => key.startsWith("PLAYLISTS_"));
                    return localStorage[playlists];
                })();
            `;

            webEngineView.runJavaScript(script, (result) => {
                if (!result) {
                    console.error("No playlists found in localStorage.");
                    return;
                }

                try {
                    const playlistsData = JSON.parse(result);
                    const playlists = playlistsData.data || [];

                    mainPage.playlistsListModel.clear();

                    playlists.forEach(playlist => {
                        if (playlist.TITLE !== "Unknown Title") {
                            mainPage.playlistsListModel.append({
                                id: playlist.PLAYLIST_ID,
                                title: playlist.TITLE,
                                songCount: playlist.NB_SONG,
                                image: `https://e-cdns-images.dzcdn.net/images/${playlist.PICTURE_TYPE}/${playlist.PLAYLIST_PICTURE}/96x96.jpg` // Constructing the image URL
                            });
                        }
                    });
                } catch (error) {
                    console.error("Error parsing playlists:", error);
                }
            });
        }
    }

    function getSearchResults() {
        root.searchLoading = true;

        var request = new XMLHttpRequest();

        function makeRequest() {
            request.open("GET", searchUrl);
            request.onreadystatechange = function() {
                if (request.readyState == XMLHttpRequest.DONE) {
                    if (request.status === 200) {
                        var response = JSON.parse(request.responseText);
                        var list = response.data;
                        searchPage.searchListModel.clear();
                        for (var i in list) {
                            if (searchPage.searchSectionIndex == 0) {
                                searchPage.searchListModel.append({ 
                                    "id": list[i].id, 
                                    "title": list[i].title, 
                                    "subTitle": list[i].artist.name,
                                    "image": list[i].album.cover_medium
                                });
                            }
                            else if (searchPage.searchSectionIndex == 1) {
                                searchPage.searchListModel.append({ 
                                    "id": list[i].id, 
                                    "title": list[i].title, 
                                    "subTitle": list[i].artist.name,
                                    "image": list[i].cover_medium
                                });
                            }
                            else if (searchPage.searchSectionIndex == 2) {
                                searchPage.searchListModel.append({ 
                                    "id": list[i].id, 
                                    "title": list[i].title, 
                                    "subTitle": list[i].user.name,
                                    "image": list[i].picture_medium
                                });
                            }
                            else if (searchPage.searchSectionIndex == 3) {
                                searchPage.searchListModel.append({ 
                                    "id": list[i].id, 
                                    "title": list[i].name, 
                                    "subTitle": list[i].nb_fan + " " + i18n.tr("fans"),
                                    "image": list[i].picture_medium
                                });
                            }
                        }
                        searchPage.searchFlickable.contentY = 0
                        root.searchLoading = false;
                    } else {
                        console.log("HTTP:", request.status, request.statusText);
                        root.searchLoading = false;
                    }
                }
            };
            request.send();
        }

        makeRequest();
    }

    function timeFormat(duration) {   
        // Hours, minutes and seconds
        var hrs = ~~(duration / 3600);
        var mins = ~~((duration % 3600) / 60);
        var secs = ~~duration % 60;

        // Output like "1:01" or "4:03:59" or "123:03:59"
        var ret = "";

        if (hrs > 0) {
            ret += "" + hrs + ":" + (mins < 10 ? "0" : "");
        }

        ret += "" + mins + ":" + (secs < 10 ? "0" : "");
        ret += "" + secs;
        return ret;
    }
}
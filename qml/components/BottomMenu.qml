import QtQuick 2.7
import Lomiri.Components 1.3

Item {
    id: bottomMenu

    height: units.gu(8)

    enabled: player.playerLoaded

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

    // Grey line on top of bottomMenu
    Rectangle {
        width: parent.width
        height: units.gu(0.1)

        anchors.top: parent.top

        color: theme.palette.normal.base
    }

    LomiriShape {
        id: albumArtShape

        height: units.gu(6)
        width: height

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        source: Image {
            id: albumArt
            
            source: "https://e-cdns-images.dzcdn.net/images/cover/" + player.albumArt + "/128x128-000000-80-0-0.jpg"
        }

        aspect: LomiriShape.Flat
        backgroundColor: settings.darkMode == false ? theme.palette.normal.base : theme.palette.normal.overlay
    }

    Column {
        id: songInfo

        height: units.gu(5)

        anchors {
            left: albumArtShape.right
            leftMargin: units.gu(1)
            right: playPauseButtonArea.left
            verticalCenter: albumArtShape.verticalCenter
        }

        spacing: units.gu(0.5)

        Label {
            id: songInfoTitle

            width: parent.width
            
            anchors.left: parent.left
                                
            font.bold: true
            maximumLineCount: 1
            elide: Text.ElideRight
            
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

    MouseArea {
        id: backToPlayerArea

        anchors {
            fill: parent
            rightMargin: units.gu(5)
        }

        onClicked: {
            playerPage.playerPageHeaderSections.selectedIndex = 0
            mainPage.pageStack.addPageToNextColumn(mainPage, playerPage)
        }
    }
    
    MouseArea {
        id: playPauseButtonArea
        
        height: units.gu(7)
        width: units.gu(7)

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        onClicked: player.togglePause()

        ActivityIndicator {
            height: units.gu(3)
            width: units.gu(3)
            
            anchors.centerIn: playPauseButton
            
            running: player.playerLoaded ? false : true
        }

        Icon {
            id: playPauseButton

            visible: player.playerLoaded

            height: units.gu(3)
            width: units.gu(3)

            anchors.centerIn: parent

            name: player.playingState ? "media-playback-pause" : "media-playback-start"
            color: player.playerLoaded ? theme.palette.normal.baseText : theme.palette.disabled.baseText
        }
    }
}
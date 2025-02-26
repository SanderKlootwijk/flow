import QtQuick 2.7
import Lomiri.Components 1.3

Item {
    id: flowShape

    width: units.gu(10)
    height: units.gu(13)

    enabled: player.playerLoaded

    property string title
    property string image
    property string playColor
    property string radioType
    property string radioId
    property string context

    LomiriShape {
        id: shape

        height: units.gu(10)
        width: height

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }

        source: Image {
                    id: flowImage

                    source: pausePlayIcon.visible ? "" : image
                }

        aspect: LomiriShape.Flat
        backgroundColor: {
            if (pausePlayIcon.visible == true) {
                playColor
            }
            else {
                if (Theme.name == "Lomiri.Components.Themes.Ambiance") {
                    "#f5f2f8"
                }
                else {
                    "#3b3b3b"
                }
            }
        }
    }

    Label {
        id: titleLabel

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        
        text: title
    }

    Rectangle {
        id: pausePlayIcon

        height: units.gu(5)
        width: units.gu(5)

        visible: player.playerType == "radio" && player.radioId == radioId ? true : false

        anchors.centerIn: shape
        
        radius: 50

        color: Theme.name == "Lomiri.Components.Themes.Ambiance" ? "#f5f2f8" : "#3b3b3b"

        Icon {
            height: units.gu(2.5)
            width: units.gu(2.5)

            anchors.centerIn: parent  

            name: {
                if (player.playingState == false) {
                    "media-playback-start"
                }
                else {
                    player.playerType == "radio" && player.radioId == radioId ? "media-playback-pause" : "media-playback-start"
                }
            }
            color: Theme.name == "Lomiri.Components.Themes.Ambiance" ? "#3b3b3b" : "#f5f2f8"
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (player.playerType == "radio" && player.radioId == radioId) {
                player.togglePause()
            }
            else {
                if (player.shuffle) {
                    player.toggleShuffle()
                }
                player.setRepeat(0)
                player.play(radioType, radioId, true, 0, context)
            }
        }
    }
}
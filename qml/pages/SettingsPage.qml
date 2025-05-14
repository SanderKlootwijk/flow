import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.3

Page {
    id: settingsPage

    header: PageHeader {
                id: settingsPageHeader

                title: i18n.tr('Settings')
            }
    
    Scrollbar {
        z: 1
        id: scrollSettings

        flickableItem: flickSettings
        align: Qt.AlignTrailing
    }

    Flickable {
        id: flickSettings

        anchors {
            fill: parent
            topMargin: settingsPageHeader.height
        }

        contentWidth: columnSettings.width
        contentHeight: columnSettings.height
    
        Column {
            id: columnSettings

            width: settingsPage.width

            ListItem {
                id: themeTitle

                height: units.gu(6.25)

                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: themeTitleLabel
                    width: parent.width - units.gu(4)

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1.25)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Theme") + ":"

                    color: theme.palette.normal.backgroundSecondaryText
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            ListItem {
                id: themeListItem

                height: themeOptionSelector.height + units.gu(2)

                OptionSelector {
                    id: themeOptionSelector

                    width: parent.width - units.gu(4)

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                    }

                    model: [i18n.tr("System"), "Ambiance", "Suru Dark"]

                    onSelectedIndexChanged: settings.theme = selectedIndex

                    Component.onCompleted: selectedIndex = settings.theme
                }   
            }

            ListItem {
                id: audioTitle

                height: units.gu(6.25)

                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: audioTitleLabel
                    width: parent.width - units.gu(4)

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1.25)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Audio")

                    color: theme.palette.normal.backgroundSecondaryText
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            ListItem {
                id: volumeListItem

                enabled: player.playerLoaded

                height: units.gu(10)

                Label {
                    id: volumeLabel

                    width: parent.width - currentVolumeLabel.width - units.gu(6)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    text: i18n.tr("Volume")
                    elide: Text.ElideRight
                }

                Label {
                    id: currentVolumeLabel

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    text: player.playerVolume.toFixed(2)
                }

                ProgressBar {
                    id: progressBar

                    visible: false

                    minimumValue: 0
                    maximumValue: player.playerVolume
                    value: player.playerVolume
                }

                Slider {
                    id: volumeSlider

                    anchors {
                        top: volumeLabel.bottom
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    onPressedChanged: player.setVolume (volumeSlider.value)

                    function formatValue(v) { return v.toFixed(2) }

                    minimumValue: 0
                    maximumValue: 1
                    value: player.playerVolume

                    Connections {
                        target: progressBar
                        onValueChanged: volumeSlider.pressed ? "" : volumeSlider.value = player.playerVolume
                    }
                }
            }

            ListItem {
                id: accountTitle

                height: units.gu(6.25)

                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: accoutTitleLabel
                    width: parent.width - units.gu(4)

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1.25)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Account")

                    color: theme.palette.normal.backgroundSecondaryText
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            ListItem {
                id: logoutListItem

                onClicked: PopupUtils.open(logoutDialogComponent)

                Label {
                    id: logoutLabel

                    width: parent.width - units.gu(8)

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Log out")

                    elide: Text.ElideRight
                }

                Icon {
                    height: units.gu(2.5)
                    width: units.gu(2.5)

                    name: 'next'
                    
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)    
                    }
                }     
            }
        }
    }

    Component {
        id: logoutDialogComponent

        Dialog {
            id: logoutDialog

            title: i18n.tr("Log out")
            text: i18n.tr("Are you sure you want to log out?")

            Button {
                text: i18n.tr("Log out")
                color: theme.palette.normal.negative

                onClicked: {
                    pageStack.removePages(settingsPage)
                    PopupUtils.close(logoutDialog)
                    webEngineView.navigationHistory.clear()
                    webEngineView.url = "https://www.deezer.com/logout.php?redirect=login"
                    webEngineView.navigationHistory.clear()
                    player.playerLoaded = false
                    loadingLabelTimer.index = 0
                }
            }

            Button {
                text: i18n.tr("Cancel")

                onClicked: PopupUtils.close(logoutDialog)
            }
        }
    }
}
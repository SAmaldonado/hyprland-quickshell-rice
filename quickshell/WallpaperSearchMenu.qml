import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 
import Qt.labs.folderlistmodel 
import Quickshell
import Quickshell.Io // Volvemos a nuestro confiable Io para el Process

Window {
    id: rootWindow
    width: 600  
    height: 250 
    visible: true // Nace visible instantáneamente
    color: "transparent"
    title: "TitanWallpaperMenu"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        anchors.margins: 10
        color: Theme.surface
        radius: 16
        border.color: Theme.primaryContainer
        border.width: 2
        opacity: 0.98

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 20
            color: Theme.surface
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 15

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: Theme.primaryContainer
                radius: 15 
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Text { text: "🔍"; font.pixelSize: 12 }
                    
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Buscar atmósfera..."
                        color: Theme.primary
                        background: null
                        focus: true
                        font.pixelSize: 12
                        font.bold: true
                        onFocusChanged: if (focus) searchField.selectAll()
                        
                        // Si te arrepientes, presiona ESC y se cierra
                        Keys.onEscapePressed: Qt.quit()
                    }
                }
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                orientation: ListView.Horizontal 
                spacing: 15
                focus: true 
                
                model: FolderListModel {
                    folder: "file:///home/Maxstep/Pictures/Wallpapers/Live"
                    nameFilters: [ "*" + searchField.text + "*.mp4" ] 
                    showDirs: false
                }

                highlight: Rectangle {
                    color: Theme.primary
                    opacity: 0.15
                    radius: 8
                    border.color: Theme.primary
                    border.width: 1
                    Behavior on y { SpringAnimation { spring: 3; damping: 0.25 } }
                }
                highlightMoveDuration: 200

                // Al dar Enter
                Keys.onReturnPressed: {
                    let selectedFile = model.get(listView.currentIndex, "fileName")
                    ejecutarScript.command = ["/home/Maxstep/.local/bin/dinamico.sh", selectedFile]
                    rootWindow.visible = false 
                    ejecutarScript.running = true
                }

                delegate: Item {
                    width: 130
                    height: listView.height
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 5

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            clip: true
                            border.color: ListView.isCurrentItem ? Theme.primary : "transparent"
                            border.width: 1

                            Image {
                                anchors.fill: parent
                                source: fileURL.toString().replace(".mp4", ".jpg") 
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        Text {
                            text: fileName.replace(".mp4", "")
                            color: Theme.foreground
                            font.bold: true
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Al hacer Clic
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ejecutarScript.command = ["/home/Maxstep/.local/bin/dinamico.sh", fileName]
                            rootWindow.visible = false 
                            ejecutarScript.running = true
                        }
                    } 
                } 
            } 
        } 
    } 

    // El motor confiable para correr bash
    Process {
        id: ejecutarScript
        onExited: Qt.quit() 
    }
}
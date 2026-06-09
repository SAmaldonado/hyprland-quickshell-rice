import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 
import Qt.labs.folderlistmodel 
import Quickshell
import Quickshell.Io 

Window {
    id: rootWindow
    width: 850  // <-- 1. Mucho más ancho para que quepan 5 fondos
    height: 250 
    visible: true 
    color: "transparent"
    title: "TitanWallpaperMenu"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    
    // <-- INTENTO DE SOLDADURA NATIVA -->
    // Si Hyprland respeta esto, se pegará arriba al centro
    x: (Screen.width - width) / 2
    y: 35 // Ajusta este número según el grosor de tu barra superior

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        anchors.margins: 10
        color: Theme.surface
        radius: 16
        border.color: Theme.primaryContainer
        border.width: 2
        opacity: 0.98

        // Parche cuadrado superior para la soldadura
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 20
            color: Theme.surface
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            anchors.margins: 20

            // BUSCADOR
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                color: Theme.primaryContainer
                radius: 10 
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    Text { text: "🔍"; font.pixelSize: 14 }
                    
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Buscar atmósfera o comando..."
                        color: Theme.primary
                        background: null
                        focus: true
                        font.pixelSize: 13
                        font.bold: true
                        onFocusChanged: if (focus) searchField.selectAll()
                        Keys.onEscapePressed: Qt.quit() // ESC para cerrar
                    }
                }
            }

            // CARRUSEL
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                orientation: ListView.Horizontal 
                spacing: 20 // <-- 2. Más espacio para evitar textos remontados
                focus: true 
                
                // Físicas del carrusel (Cover Flow)
                preferredHighlightBegin: width / 2 - 80 
                preferredHighlightEnd: width / 2 + 80
                highlightRangeMode: ListView.StrictlyEnforceRange
                snapMode: ListView.SnapToItem

                model: FolderListModel {
                    folder: "file:///home/Maxstep/Pictures/Wallpapers/Live"
                    nameFilters: [ "*" + searchField.text + "*.mp4" ] 
                    showDirs: false
                }

                highlight: Rectangle {
                    color: Theme.primary
                    opacity: 0.15
                    radius: 12
                    border.color: Theme.primary
                    border.width: 1
                    Behavior on x { SpringAnimation { spring: 3; damping: 0.25 } }
                }
                highlightMoveDuration: 200

                Keys.onReturnPressed: {
                    let selectedFile = model.get(listView.currentIndex, "fileName")
                    ejecutarScript.command = ["/home/Maxstep/.local/bin/dinamico.sh", selectedFile]
                    rootWindow.visible = false 
                    ejecutarScript.running = true
                }

                delegate: Item {
                    width: 160 // <-- 3. Tarjetas más anchas
                    height: listView.height
                    
                    // Efecto visual: agranda el seleccionado, achica el resto
                    scale: ListView.isCurrentItem ? 1.05 : 0.85
                    opacity: ListView.isCurrentItem ? 1.0 : 0.5
                    Behavior on scale { SpringAnimation { spring: 3; damping: 0.2 } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        // MINIATURA DEL VIDEO
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.surfaceVariant // Fondo por si falla la imagen
                            radius: 12
                            clip: true
                            border.color: ListView.isCurrentItem ? Theme.primary : "transparent"
                            border.width: 2

                            Image {
                                anchors.fill: parent
                                source: fileURL.toString().replace(".mp4", ".jpg") 
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        // TEXTO CONTROLADO
                        Text {
                            text: fileName.replace(".mp4", "")
                            color: Theme.foreground
                            font.bold: true
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight // <-- Corta el texto con "..." si es enorme
                        }
                    }

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

    Process {
        id: ejecutarScript
        onExited: Qt.quit() 
    }
}
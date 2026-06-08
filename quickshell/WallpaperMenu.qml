import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel 
import Quickshell
import Quickshell.Io 

Window {
    id: rootWindow
    width: 900  // Mucho más ancho para que quepan varias opciones
    height: 300 // Más bajito
    visible: true
    color: "transparent"
    
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: "TitanWallpaperMenu"

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 16
        border.color: Theme.primaryContainer
        border.width: 2
        opacity: 0.98

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            // CABECERA (Estilo buscador)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.margins: 15
                Layout.bottomMargin: 0
                color: Theme.primaryContainer
                radius: 25 // Totalmente redondo como una barra de búsqueda
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    Text { text: "🔍"; font.pixelSize: 16 }
                    Text {
                        text: "Atmósfera del Titán..."
                        color: Theme.primary
                        font.bold: true
                        font.pixelSize: 15
                        Layout.fillWidth: true
                    }
                }
            }

            // EL CARRUSEL HORIZONTAL
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 15
                orientation: ListView.Horizontal // ¡De izquierda a derecha!
                spacing: 25
                clip: true
                focus: true 
                
                // --- MAGIA DEL CENTRADO ---
                // Mantiene el elemento activo siempre en el centro de la pantalla
                preferredHighlightBegin: width / 2 - 110 
                preferredHighlightEnd: width / 2 + 110
                highlightRangeMode: ListView.StrictlyEnforceRange
                snapMode: ListView.SnapToItem

                model: FolderListModel {
                    folder: "file:///home/Maxstep/Pictures/Wallpapers/Live"
                    nameFilters: ["*.mp4"]
                    showDirs: false
                }

                Keys.onReturnPressed: {
                    let selectedFile = model.get(listView.currentIndex, "fileName")
                    ejecutarScript.command = ["/home/Maxstep/.local/bin/dinamico.sh", selectedFile]
                    rootWindow.visible = false 
                    ejecutarScript.running = true
                }

                // CÓMO SE VE CADA TARJETA DEL CARRUSEL
                delegate: Item {
                    width: 220
                    height: listView.height
                    
                    // Efecto de Zoom: La tarjeta central se hace más grande, las de los lados se encogen y se opacan
                    scale: ListView.isCurrentItem ? 1.05 : 0.85
                    opacity: ListView.isCurrentItem ? 1.0 : 0.5
                    Behavior on scale { SpringAnimation { spring: 3; damping: 0.2 } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // LA MINIATURA DEL FONDO
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            clip: true
                            border.color: ListView.isCurrentItem ? Theme.primary : "transparent"
                            border.width: 2

                            Image {
                                anchors.fill: parent
                                // Truco: Busca un archivo con el mismo nombre pero .jpg para usar de portada
                                source: fileURL.toString().replace(".mp4", ".png") 
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        // EL NOMBRE DEL FONDO
                        Text {
                            text: fileName.replace(".mp4", "")
                            color: Theme.foreground
                            font.bold: true
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: listView.currentIndex = index 
                        
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
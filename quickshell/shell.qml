import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes 
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import "components"

PanelWindow {
    implicitHeight: 35 
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    margins {
        top: 8
        left: 12
        right: 12
    }

    color: "transparent"

    // ==========================================
    // BLOQUE IZQUIERDO (Ajustes y Música)
    // ==========================================
    Item {
        anchors.left: parent.left
        width: leftContent.width + 40
        height: parent.height

        Shape {
            anchors.fill: parent
            layer.enabled: true  // <-- EL PARCHE ANTI-NVIDIA (Transparencia)
            layer.samples: 4
            ShapePath {
                fillColor: Theme.surface
                strokeColor: Theme.primaryContainer
                strokeWidth: 1
                startX: 0; startY: 0
                PathLine { x: parent.width; y: 0 }
                PathLine { x: parent.width - 15; y: parent.height }
                PathLine { x: 0; y: parent.height }
            }
        }

        RowLayout {
            id: leftContent
            anchors.centerIn: parent
            spacing: 12

            Text { text: "⚙️"; font.pixelSize: 16; color: Theme.primary }
            Text { text: " | "; color: Theme.surfaceVariant }

            Repeater {
                model: Mpris.players
                Text {
                    visible: modelData.title !== undefined && modelData.title !== ""
                    text: {
                        let artista = modelData.artist ? modelData.artist + " - " : ""
                        return "🎵 " + artista + modelData.title
                    }
                    color: Theme.foreground
                    font.bold: true
                    elide: Text.ElideRight 
                    Layout.maximumWidth: 250 
                }
            }
            Text {
                visible: Mpris.players.length === 0
                text: "🎵 Sin reproducción"
                color: Theme.surfaceVariant
                font.bold: true
            }
        }
    }

    // ==========================================
    // BLOQUE CENTRAL (Búsqueda y Workspaces)
    // ==========================================
    Item {
        anchors.centerIn: parent
        width: centerContent.width + 50
        height: parent.height

        Shape {
            anchors.fill: parent
            layer.enabled: true  // <-- EL PARCHE ANTI-NVIDIA (Transparencia)
            layer.samples: 4
            ShapePath {
                fillColor: Theme.surface
                strokeColor: Theme.primaryContainer
                strokeWidth: 1
                startX: 15; startY: 0
                PathLine { x: parent.width; y: 0 }
                PathLine { x: parent.width - 15; y: parent.height }
                PathLine { x: 0; y: parent.height }
            }
        }

        RowLayout {
            id: centerContent
            anchors.centerIn: parent
            spacing: 15

            // BOTÓN DE BÚSQUEDA FUNCIONAL
            Rectangle {
                width: 80; height: 22; radius: 11
                color: Theme.surfaceVariant
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "🔍"; font.pixelSize: 11 }
                    Text { text: "Fondos"; color: Theme.foreground; font.pixelSize: 11; font.bold: true }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: openMenuScript.running = true
                }
            }

            WorkspacesWidget {}
        }
    }

    // ==========================================
    // BLOQUE DERECHO (Fecha, Hora y Telemetría)
    // ==========================================
    Item {
        anchors.right: parent.right
        width: rightContent.width + 40
        height: parent.height

        Shape {
            anchors.fill: parent
            layer.enabled: true  // <-- EL PARCHE ANTI-NVIDIA (Transparencia)
            layer.samples: 4
            ShapePath {
                fillColor: Theme.surface
                strokeColor: Theme.primaryContainer
                strokeWidth: 1
                startX: 15; startY: 0
                PathLine { x: parent.width; y: 0 }
                PathLine { x: parent.width; y: parent.height }
                PathLine { x: 0; y: parent.height }
            }
        }

        RowLayout {
            id: rightContent
            anchors.centerIn: parent
            spacing: 12

            Text { text: "📦"; font.pixelSize: 14 }
            
            Text {
                id: reloj
                color: Theme.foreground
                font.pixelSize: 13
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: reloj.text = Qt.formatDateTime(new Date(), "hh:mm  dd/MM")
                }
                Component.onCompleted: reloj.text = Qt.formatDateTime(new Date(), "hh:mm  dd/MM")
            }

            Text { text: " | "; color: Theme.surfaceVariant }

            // Telemetría sin batería y con icono de Ethernet/Descarga (Por ahora visual, luego lo volvemos dinámico)
            Text { text: "⚙️ 24%  ⬇️ -- MB/s"; color: Theme.primary; font.pixelSize: 13; font.bold: true }
            
            Text { text: "⏻"; font.pixelSize: 16; color: Theme.error }
        }
    }

    // Demonio IPC que despierta el menú al hacer clic
    Process {
        id: openMenuScript
        // Usamos la nueva sintaxis: quickshell ipc call [target] [function]
        command: [ "quickshell", "ipc", "call", "Omnibar", "open" ]
    }
}
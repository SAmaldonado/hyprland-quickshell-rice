import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../"

// El componente raíz es un RowLayout para alinear los círculos horizontalmente
RowLayout {
    spacing: 6
    
    Repeater {
        model: Hyprland.workspaces
        
        Rectangle {
            width: 20
            height: 20
            radius: 10 // Círculos perfectos (mitad del width/height)
            
            // Lógica reactiva de colores usando el Tema global
            color: modelData.active ? Theme.primary : Theme.surfaceVariant
            
            // Animación suave al cambiar de escritorio
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: modelData.active ? Theme.surface : Theme.foreground
                font.bold: true
                font.pixelSize: 11
            }

            // Interactividad con el ratón
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}
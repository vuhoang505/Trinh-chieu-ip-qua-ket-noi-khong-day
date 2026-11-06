import QtQuick
import QtQuick.Controls

Button {
    id: root
    property string glyph: ""
    property color accent: "#6D9DFF"
    property bool danger: false
    implicitHeight: 44
    implicitWidth: text.length > 0 ? 126 : 44
    hoverEnabled: true
    font.pixelSize: 13
    font.weight: Font.DemiBold
    contentItem: Row {
        spacing: 8
        anchors.centerIn: parent
        Text { text: root.glyph; color: root.danger ? "#FF9AAB" : "#DCE7FF"; font.pixelSize: 16 }
        Text { text: root.text; color: "#EEF3FF"; font: root.font; visible: root.text.length > 0 }
    }
    background: Rectangle {
        radius: 13
        color: root.down ? "#35558E" : (root.hovered ? "#293C63" : "#202A42")
        border.width: 1
        border.color: root.danger ? "#55FF637D" : (root.hovered ? "#557AA7FF" : "#26FFFFFF")
        scale: root.down ? 0.97 : 1
        Behavior on color { ColorAnimation { duration: 130 } }
        Behavior on scale { NumberAnimation { duration: 90 } }
    }
}


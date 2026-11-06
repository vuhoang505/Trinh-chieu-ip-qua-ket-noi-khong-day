import QtQuick
import QtQuick.Controls

Button {
    id: root
    property string glyph: ""
    property color accent: "#6D9DFF"
    property bool danger: false
    property bool primary: false
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
        gradient: Gradient {
            GradientStop { position: 0; color: root.primary ? (root.down ? "#4779DB" : "#6598FF") : (root.down ? "#283C61" : (root.hovered ? "#263855" : "#1A2335")) }
            GradientStop { position: 1; color: root.primary ? (root.down ? "#6546C8" : "#7B5CE7") : (root.down ? "#202E4A" : (root.hovered ? "#202E48" : "#171E2E")) }
        }
        border.width: 1
        border.color: root.danger ? "#65FF637D" : (root.primary ? "#558EAEFF" : (root.hovered ? "#557AA7FF" : "#26FFFFFF"))
        scale: root.down ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: 90 } }
    }
}


import QtQuick

GlassPanel {
    id: root
    property string label: ""
    property string value: "—"
    property string detail: ""
    property color accent: "#4F7CFF"

    implicitWidth: 170
    implicitHeight: 82
    panelRadius: 19
    panelColor: "#F5FFFFFF"
    strokeColor: "#DCE7F4"

    Rectangle {
        width: 5; height: 38; radius: 3
        color: root.accent
        anchors.left: parent.left; anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
    }
    Rectangle {
        width: 14; height: 38; radius: 7
        color: root.accent; opacity: 0.12
        anchors.left: parent.left; anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        anchors.left: parent.left; anchors.leftMargin: 31
        anchors.right: parent.right; anchors.rightMargin: 12
        anchors.top: parent.top; anchors.topMargin: 14
        text: root.label.toUpperCase()
        color: "#78869B"
        font.family: "Segoe UI"
        font.pixelSize: 9
        font.weight: Font.DemiBold
        font.letterSpacing: 1.1
        elide: Text.ElideRight
    }
    Text {
        anchors.left: parent.left; anchors.leftMargin: 31
        anchors.right: parent.right; anchors.rightMargin: 54
        anchors.bottom: parent.bottom; anchors.bottomMargin: 14
        text: root.value
        color: "#23324A"
        font.family: "Segoe UI"
        font.pixelSize: 17
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }
    Text {
        anchors.right: parent.right; anchors.rightMargin: 12
        anchors.bottom: parent.bottom; anchors.bottomMargin: 13
        text: root.detail
        color: root.accent
        font.family: "Segoe UI"
        font.pixelSize: 9
        font.weight: Font.DemiBold
    }
}

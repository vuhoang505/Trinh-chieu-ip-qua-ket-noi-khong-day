import QtQuick

GlassPanel {
    id: root
    property string label: ""
    property string value: "—"
    property string detail: ""
    property color accent: "#73A5FF"
    implicitWidth: 150
    implicitHeight: 82
    panelRadius: 17
    panelColor: "#70171D30"
    Rectangle { width: 3; height: 28; radius: 2; color: root.accent; anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter }
    Text { text: root.label.toUpperCase(); color: "#748198"; font.pixelSize: 9; font.letterSpacing: 1.2; anchors.left: parent.left; anchors.leftMargin: 26; anchors.top: parent.top; anchors.topMargin: 15 }
    Text { text: root.value; color: "#F4F7FF"; font.pixelSize: 18; font.weight: Font.DemiBold; anchors.left: parent.left; anchors.leftMargin: 26; anchors.top: parent.top; anchors.topMargin: 35 }
    Text { text: root.detail; color: "#75839B"; font.pixelSize: 10; anchors.right: parent.right; anchors.rightMargin: 12; anchors.bottom: parent.bottom; anchors.bottomMargin: 10 }
}


import QtQuick

Rectangle {
    id: root
    property color panelColor: "#99151A2B"
    property color strokeColor: "#24FFFFFF"
    property real panelRadius: 22
    color: panelColor
    radius: panelRadius
    border.width: 1
    border.color: strokeColor

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, parent.radius - 1)
        color: "transparent"
        border.width: 1
        border.color: "#0BFFFFFF"
    }
}


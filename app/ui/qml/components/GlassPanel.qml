import QtQuick
import QtQuick.Effects

Item {
    id: root
    property color panelColor: "#F4FFFFFF"
    property color strokeColor: "#D8E5F5"
    property real panelRadius: 22
    property bool elevated: true

    MultiEffect {
        anchors.fill: panel
        source: panel
        visible: root.elevated
        shadowEnabled: true
        shadowColor: "#42638C"
        shadowOpacity: 0.22
        shadowBlur: 0.75
        shadowVerticalOffset: 8
        shadowHorizontalOffset: 0
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        color: root.panelColor
        radius: root.panelRadius
        border.width: 1
        border.color: root.strokeColor

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2
            height: Math.min(40, parent.height * 0.32)
            radius: Math.max(0, parent.radius - 2)
            color: "transparent"
            border.width: 1
            border.color: "#BFFFFFFF"
            opacity: 0.8
        }
    }
}

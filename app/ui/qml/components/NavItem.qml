import QtQuick

Item {
    id: root
    property string label: ""
    property string iconText: "•"
    property bool selected: false
    signal clicked()

    implicitHeight: 52
    scale: mouse.pressed ? 0.97 : (mouse.containsMouse ? 1.015 : 1)
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

    Rectangle {
        x: 4; y: root.selected ? 6 : 4
        width: parent.width - 8; height: parent.height - 2
        radius: 16
        color: root.selected ? "#5672C8" : "#A6B8D1"
        opacity: root.selected ? 0.25 : (mouse.containsMouse ? 0.16 : 0)
        Behavior on opacity { NumberAnimation { duration: 170 } }
    }

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: root.selected ? 4 : 0
        radius: 16
        border.width: root.selected || mouse.containsMouse ? 1 : 0
        border.color: root.selected ? "#B8CBFF" : "#D5E2F2"
        gradient: Gradient {
            GradientStop { position: 0; color: root.selected ? "#F9FBFF" : (mouse.containsMouse ? "#F7FAFF" : "transparent") }
            GradientStop { position: 1; color: root.selected ? "#DDE8FF" : (mouse.containsMouse ? "#EAF1FA" : "transparent") }
        }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        width: 34; height: 34; radius: 11
        anchors.left: parent.left; anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.selected ? -2 : 0
        color: root.selected ? "#FFFFFF" : (mouse.containsMouse ? "#EDF3FF" : "#E8EEF7")
        border.width: 1
        border.color: root.selected ? "#C2D3FF" : "#D9E2EF"
        Text {
            anchors.centerIn: parent
            text: root.iconText
            color: root.selected ? "#4F73E6" : "#70809A"
            font.family: "Segoe UI Symbol"
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
    }

    Text {
        anchors.left: parent.left; anchors.leftMargin: 54
        anchors.right: parent.right; anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.selected ? -2 : 0
        text: root.label
        color: root.selected ? "#223A72" : "#5D6B82"
        font.family: "Segoe UI"
        font.pixelSize: 13
        font.weight: root.selected ? Font.DemiBold : Font.Medium
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

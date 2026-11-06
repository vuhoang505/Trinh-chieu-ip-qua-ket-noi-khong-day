import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string label: ""
    property string iconText: "•"
    property bool selected: false
    signal clicked()
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.selected ? "#264F8CFF" : (mouse.containsMouse ? "#12FFFFFF" : "transparent")
        border.width: root.selected ? 1 : 0
        border.color: "#405D9DFF"
        Behavior on color { ColorAnimation { duration: 160 } }
    }
    Rectangle {
        width: 3; height: 22; radius: 2
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        color: "#7AA7FF"; opacity: root.selected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }
    Text {
        id: glyph
        text: root.iconText
        color: root.selected ? "#AFCBFF" : "#8290AA"
        font.pixelSize: 18
        anchors.left: parent.left; anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.label
        color: root.selected ? "#F4F7FF" : "#AAB2C5"
        font.pixelSize: 13; font.weight: root.selected ? Font.DemiBold : Font.Normal
        anchors.left: glyph.right; anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
    }
    MouseArea {
        id: mouse; anchors.fill: parent; hoverEnabled: true
        cursorShape: Qt.PointingHandCursor; onClicked: root.clicked()
    }
}


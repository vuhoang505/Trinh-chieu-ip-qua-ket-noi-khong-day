import QtQuick
import QtQuick.Controls

Button {
    id: root
    property string glyph: ""
    property color accent: "#377DFF"
    property bool danger: false
    property bool primary: false

    implicitHeight: 46
    implicitWidth: Math.max(46, contentRow.implicitWidth + 30)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font.family: "Segoe UI"
    font.pixelSize: 12
    font.weight: Font.DemiBold
    scale: down ? 0.96 : (hovered ? 1.025 : 1)
    opacity: enabled ? 1 : 0.48

    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    contentItem: Item {
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.text.length > 0 && root.glyph.length > 0 ? 8 : 0

            Text {
                width: visible ? 18 : 0
                visible: root.glyph.length > 0
                text: root.glyph
                color: root.primary || root.danger ? "#FFFFFF" : root.accent
                font.family: "Segoe UI Symbol"
                font.pixelSize: 17
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: root.text.length > 0
                text: root.text
                color: root.primary || root.danger ? "#FFFFFF" : "#24324A"
                font: root.font
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    background: Item {
        Rectangle {
            x: 3; y: root.down ? 2 : 6
            width: parent.width - 6; height: parent.height - 4
            radius: 15
            color: root.danger ? "#C23B64" : (root.primary ? "#345FD0" : "#8CA5C8")
            opacity: root.hovered ? 0.3 : 0.2
            Behavior on y { NumberAnimation { duration: 120 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: face
            anchors.fill: parent
            radius: 15
            clip: true
            border.width: root.activeFocus ? 2 : 1
            border.color: root.activeFocus ? "#6B9CFF" : (root.primary ? "#739BFF" : (root.danger ? "#FF7B9C" : "#CFDDF0"))
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: root.danger ? (root.down ? "#DD456B" : "#FF668B")
                                       : root.primary ? (root.down ? "#4C6DE0" : "#6B8FFF")
                                                      : root.down ? "#E5ECF6" : (root.hovered ? "#FFFFFF" : "#F7FAFF")
                }
                GradientStop {
                    position: 1
                    color: root.danger ? (root.down ? "#B52E55" : "#D83B68")
                                       : root.primary ? (root.down ? "#6749C7" : "#7D63E8")
                                                      : root.down ? "#D5E0EE" : (root.hovered ? "#EAF2FF" : "#E5EDF8")
                }
            }

            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.leftMargin: 3; anchors.rightMargin: 3; anchors.topMargin: 2
                height: 17; radius: 11
                color: "#8FFFFFFF"
                opacity: root.down ? 0.15 : 0.75
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Rectangle {
                anchors.centerIn: parent
                width: root.down ? parent.width * 1.3 : 0
                height: width
                radius: width / 2
                color: "#45FFFFFF"
                opacity: root.down ? 1 : 0
                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 220 } }
            }
        }
    }
}

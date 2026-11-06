pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: window
    width: 1440
    height: 900
    minimumWidth: 980
    minimumHeight: 660
    visible: true
    title: "iPhone Wireless Mirror"
    color: "#EDF4FF"
    font.family: "Segoe UI"

    property int currentPage: 0
    property bool immersive: false
    property int restoreVisibility: Window.Windowed

    function toggleFullscreen() {
        if (immersive) {
            immersive = false
            if (restoreVisibility === Window.Maximized)
                showMaximized()
            else
                showNormal()
        } else {
            restoreVisibility = visibility
            currentPage = 0
            immersive = true
            showFullScreen()
        }
    }

    Shortcut { sequence: "F11"; onActivated: window.toggleFullscreen() }
    Shortcut { sequence: "Esc"; enabled: window.immersive; onActivated: window.toggleFullscreen() }
    Shortcut { sequence: "R"; enabled: window.currentPage === 0; onActivated: App.rotateClockwise() }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#E9F5FF" }
            GradientStop { position: 0.46; color: "#F5F2FF" }
            GradientStop { position: 1.0; color: "#EAF9F7" }
        }
    }
    Rectangle {
        width: 620; height: 620; radius: 310
        x: -280; y: -360; color: "#5B8CFF"
        opacity: 0.13
        SequentialAnimation on opacity {
            running: App.animationsEnabled && !window.immersive
            loops: Animation.Infinite
            NumberAnimation { from: 0.08; to: 0.18; duration: 4200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.08; duration: 4200; easing.type: Easing.InOutSine }
        }
    }
    Rectangle {
        width: 520; height: 520; radius: 260
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.rightMargin: -260; anchors.bottomMargin: -300
        color: "#6546D6B7"
    }

    RowLayout {
        id: shell
        anchors.fill: parent
        anchors.margins: window.immersive ? 0 : 18
        spacing: 16

        GlassPanel {
            id: sidebar
            visible: !window.immersive
            Layout.preferredWidth: 232
            Layout.fillHeight: true
            panelRadius: 26
            panelColor: "#EFFFFFFF"
            strokeColor: "#D8E5F4"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Row {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 14
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#79A6FF" }
                            GradientStop { position: 1; color: "#8768ED" }
                        }
                        border.width: 1; border.color: "#A6BFFF"
                        Rectangle { anchors.fill: parent; anchors.margins: 2; radius: 12; color: "transparent"; border.width: 1; border.color: "#70FFFFFF" }
                        Text { anchors.centerIn: parent; text: "M"; color: "white"; font.family: "Segoe UI"; font.pixelSize: 20; font.weight: Font.Bold }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text { text: "Mirror Studio"; color: "#24324A"; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text { text: "AIRPLAY • LOCAL"; color: "#7B89A0"; font.pixelSize: 9; font.letterSpacing: 1.3 }
                    }
                }

                Text {
                    text: "KHÔNG GIAN"
                    color: "#8492A8"
                    font.pixelSize: 9
                    font.letterSpacing: 1.6
                    leftPadding: 12
                    Layout.topMargin: 8
                }
                NavItem { Layout.fillWidth: true; iconText: "◉"; label: "Trình chiếu"; selected: window.currentPage === 0; onClicked: window.currentPage = 0 }
                NavItem { Layout.fillWidth: true; iconText: "▣"; label: "Thư viện"; selected: window.currentPage === 1; onClicked: window.currentPage = 1 }
                NavItem { Layout.fillWidth: true; iconText: "⚙"; label: "Cài đặt"; selected: window.currentPage === 2; onClicked: window.currentPage = 2 }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    radius: 18
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#FFFFFFFF" }
                        GradientStop { position: 1; color: "#E8F0FF" }
                    }
                    border.width: 1
                    border.color: App.receiverRunning ? "#8ADAB9" : "#D6E2F1"
                    Column {
                        anchors.fill: parent; anchors.margins: 15; spacing: 8
                        Row {
                            spacing: 8
                            Rectangle {
                                width: 8; height: 8; radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: App.hasFrame ? "#24C889" : (App.receiverRunning ? "#F0A43A" : "#91A0B4")
                            }
                            Text {
                                text: App.hasFrame ? "Đang trình chiếu" : (App.receiverRunning ? "Đang chờ iPhone" : "Receiver đang tắt")
                                color: "#2C3A51"; font.pixelSize: 12; font.weight: Font.DemiBold
                            }
                        }
                        Text { width: parent.width; text: App.statusDetail; color: "#78869C"; font.pixelSize: 10; elide: Text.ElideRight }
                        Text { text: "Kết nối riêng tư trong mạng LAN"; color: "#6685B7"; font.pixelSize: 9 }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: window.immersive ? 0 : 14

            Item {
                visible: !window.immersive
                Layout.fillWidth: true
                Layout.preferredHeight: 62

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Text {
                        text: ["Trình chiếu trực tiếp", "Thư viện nội dung", "Cài đặt ứng dụng"][window.currentPage]
                        color: "#1E2D45"; font.pixelSize: 25; font.weight: Font.DemiBold
                    }
                    Text {
                        text: window.currentPage === 0 ? "Độ trễ thấp • Tự thích ứng màn hình dọc và ngang" : "Dữ liệu được lưu cục bộ trên máy tính"
                        color: "#718096"; font.pixelSize: 11
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Rectangle {
                        width: 124; height: 36; radius: 18
                        gradient: Gradient {
                            GradientStop { position: 0; color: App.hasFrame ? "#E5FFF5" : "#FFFFFF" }
                            GradientStop { position: 1; color: App.hasFrame ? "#D1F7E8" : "#E7EEF8" }
                        }
                        border.width: 1
                        border.color: App.hasFrame ? "#8FE0BF" : "#D2DFEF"
                        Row {
                            anchors.centerIn: parent; spacing: 7
                            Rectangle { width: 7; height: 7; radius: 4; color: App.hasFrame ? "#22C584" : "#8A98AC" }
                            Text { text: App.hasFrame ? "LIVE  " + App.fps.toFixed(0) + " FPS" : "CHƯA KẾT NỐI"; color: "#42516A"; font.pixelSize: 9; font.weight: Font.DemiBold }
                        }
                    }
                    ToolButton { glyph: "⛶"; text: "Toàn màn hình"; onClicked: window.toggleFullscreen() }
                }
            }

            StackLayout {
                currentIndex: window.currentPage
                Layout.fillWidth: true
                Layout.fillHeight: true

                Item { LiveView { anchors.fill: parent } }
                Item { LibraryView { anchors.fill: parent } }
                ScrollView { clip: true; SettingsView { width: parent.width } }
            }
        }
    }

    component LiveView: Item {
        ColumnLayout {
            anchors.fill: parent
            spacing: window.immersive ? 0 : 12

            RowLayout {
                visible: !window.immersive
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                spacing: 10
                MetricCard { Layout.fillWidth: true; label: "KẾT NỐI"; value: App.hasFrame ? "LIVE" : (App.receiverRunning ? "READY" : "OFFLINE"); detail: "AIRPLAY"; accent: App.hasFrame ? "#22C98A" : "#8290A5" }
                MetricCard { Layout.fillWidth: true; label: "ĐỘ PHÂN GIẢI"; value: App.resolution; detail: App.videoWidth > App.videoHeight ? "NGANG" : "DỌC"; accent: "#4F82FF" }
                MetricCard { Layout.fillWidth: true; label: "TỐC ĐỘ KHUNG"; value: App.hasFrame ? App.fps.toFixed(1) + " FPS" : "—"; detail: "REAL TIME"; accent: "#8B61E9" }
                MetricCard { Layout.fillWidth: true; label: "GHI HÌNH"; value: App.recording ? App.recordingTime : "SẴN SÀNG"; detail: App.recordingPaused ? "TẠM DỪNG" : "LOCAL"; accent: App.recording ? "#FF6F91" : "#77859C" }
            }

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                panelRadius: window.immersive ? 0 : 26
                panelColor: window.immersive ? "#FF000000" : "#F7FFFFFF"
                strokeColor: window.immersive ? "transparent" : "#D8E5F4"
                elevated: !window.immersive

                Item {
                    id: stage
                    anchors.fill: parent
                    anchors.margins: window.immersive ? 0 : 18

                    Rectangle {
                        id: videoSurface
                        anchors.centerIn: parent
                        property real ratio: Math.max(0.1, App.displayAspectRatio)
                        width: Math.min(stage.width, stage.height * ratio)
                        height: width / ratio
                        radius: window.immersive ? 0 : (App.videoWidth > App.videoHeight ? 18 : 30)
                        color: App.hasFrame ? "#020308" : "#EDF4FF"
                        border.width: window.immersive ? 0 : 1
                        border.color: "#C5D7EC"
                        clip: true

                        Image {
                            anchors.centerIn: parent
                            width: App.rotation % 180 === 0 ? parent.width : parent.height
                            height: App.rotation % 180 === 0 ? parent.height : parent.width
                            source: App.hasFrame ? "image://mirror/frame?" + App.frameSerial : ""
                            fillMode: Image.PreserveAspectFit
                            cache: false
                            asynchronous: false
                            smooth: true
                            mipmap: false
                            rotation: App.rotation
                            visible: App.hasFrame
                            transformOrigin: Item.Center
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: !App.hasFrame
                            gradient: Gradient {
                                GradientStop { position: 0; color: "#F7FBFF" }
                                GradientStop { position: 0.55; color: "#E7F0FF" }
                                GradientStop { position: 1; color: "#EFE9FF" }
                            }
                            Column {
                                anchors.centerIn: parent
                                width: Math.min(360, parent.width - 40)
                                spacing: 13
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 72; height: 72; radius: 24
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#FFFFFF" }
                                        GradientStop { position: 1; color: "#D8E6FF" }
                                    }
                                    border.width: 1; border.color: "#B9CBEE"
                                    Text { anchors.centerIn: parent; text: "⌁"; color: "#557BE0"; font.family: "Segoe UI Symbol"; font.pixelSize: 38 }
                                    SequentialAnimation on scale {
                                        running: App.animationsEnabled && App.receiverRunning
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.94; to: 1.05; duration: 1100; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 0.94; duration: 1100; easing.type: Easing.InOutSine }
                                    }
                                }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: App.receiverRunning ? "Sẵn sàng nhận màn hình" : "Bắt đầu trình chiếu"; color: "#24334B"; font.pixelSize: 19; font.weight: Font.DemiBold }
                                Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: App.receiverRunning ? "Mở Trung tâm điều khiển → Phản chiếu màn hình" : "Khởi động receiver để iPhone tìm thấy máy tính"; color: "#718098"; font.pixelSize: 11 }
                                ToolButton { anchors.horizontalCenter: parent.horizontalCenter; visible: !App.receiverRunning; primary: true; glyph: "▶"; text: "Khởi động receiver"; onClicked: App.startReceiver() }
                            }
                        }

                        MouseArea { anchors.fill: parent; acceptedButtons: Qt.LeftButton; onDoubleClicked: window.toggleFullscreen() }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: window.immersive ? 24 : 12
                        width: dockRow.width + 24
                        height: 58
                        radius: 20
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#F8FFFFFF" }
                            GradientStop { position: 1; color: "#F2E5EDF8" }
                        }
                        border.width: 1
                        border.color: "#C5D4E7"

                        Rectangle {
                            x: 12; y: parent.height - 1; width: parent.width - 24; height: 7; radius: 4
                            color: "#315D7EA6"; z: -1
                        }

                        Row {
                            id: dockRow
                            anchors.centerIn: parent
                            spacing: 8
                            ToolButton { visible: !App.receiverRunning; primary: true; glyph: "▶"; text: window.immersive ? "" : "Bắt đầu"; onClicked: App.startReceiver() }
                            ToolButton { visible: App.receiverRunning; danger: true; glyph: "■"; text: window.immersive ? "" : "Dừng"; onClicked: App.stopReceiver() }
                            ToolButton { glyph: "↻"; text: window.immersive ? "" : "Xoay 90°"; enabled: App.hasFrame; onClicked: App.rotateClockwise() }
                            ToolButton { glyph: "▣"; text: window.immersive ? "" : "Chụp ảnh"; enabled: App.hasFrame; onClicked: App.captureScreenshot() }
                            ToolButton { glyph: App.recording ? "■" : "●"; text: window.immersive ? "" : (App.recording ? "Dừng ghi" : "Ghi hình"); danger: App.recording; enabled: App.hasFrame; onClicked: App.toggleRecording() }
                            ToolButton { glyph: App.muted ? "×" : "◖"; text: ""; onClicked: App.toggleMute() }
                            ToolButton { glyph: window.immersive ? "⤢" : "⛶"; text: ""; onClicked: window.toggleFullscreen() }
                        }
                    }

                    Text {
                        visible: window.immersive
                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 18
                        text: "F11 / ESC để thoát  •  R để xoay"
                        color: "#7EFFFFFF"; font.pixelSize: 10
                    }
                }
            }
        }
    }

    component LibraryView: Item {
        GridLayout {
            anchors.fill: parent
            columns: width > 850 ? 2 : 1
            rowSpacing: 14; columnSpacing: 14
            GlassPanel {
                Layout.fillWidth: true; Layout.fillHeight: true
                Column { anchors.centerIn: parent; spacing: 15
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "●"; color: "#F05283"; font.family: "Segoe UI Symbol"; font.pixelSize: 38 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Bản ghi màn hình"; color: "#26354D"; font.pixelSize: 20; font.weight: Font.DemiBold }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; width: Math.min(360, parent.parent.width - 48); horizontalAlignment: Text.AlignHCenter; elide: Text.ElideMiddle; text: App.recordingsPath; color: "#75839A"; font.pixelSize: 10 }
                    ToolButton { anchors.horizontalCenter: parent.horizontalCenter; glyph: "↗"; text: "Mở thư mục"; onClicked: App.openPath(App.recordingsPath) }
                }
            }
            GlassPanel {
                Layout.fillWidth: true; Layout.fillHeight: true
                Column { anchors.centerIn: parent; spacing: 15
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "▣"; color: "#4F82F3"; font.family: "Segoe UI Symbol"; font.pixelSize: 42 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Ảnh chụp màn hình"; color: "#26354D"; font.pixelSize: 20; font.weight: Font.DemiBold }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; width: Math.min(360, parent.parent.width - 48); horizontalAlignment: Text.AlignHCenter; elide: Text.ElideMiddle; text: App.screenshotsPath; color: "#75839A"; font.pixelSize: 10 }
                    ToolButton { anchors.horizontalCenter: parent.horizontalCenter; glyph: "↗"; text: "Mở thư mục"; onClicked: App.openPath(App.screenshotsPath) }
                }
            }
        }
    }

    component SettingsView: ColumnLayout {
        spacing: 14
        GlassPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: 460
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 28; spacing: 14
                Text { text: "Receiver & lưu trữ"; color: "#24334A"; font.pixelSize: 20; font.weight: Font.DemiBold }
                Text { text: "Tên hiển thị trên iPhone"; color: "#718097"; font.pixelSize: 11 }
                TextField { id: receiverName; Layout.fillWidth: true; Layout.preferredHeight: 48; text: App.receiverName; color: "#27364E"; selectByMouse: true; leftPadding: 16; rightPadding: 16; font.family: "Segoe UI"; font.pixelSize: 12; background: Rectangle { radius: 14; gradient: Gradient { GradientStop { position: 0; color: "#FFFFFF" } GradientStop { position: 1; color: "#E8EFF8" } } border.width: parent.activeFocus ? 2 : 1; border.color: parent.activeFocus ? "#6C8FFF" : "#D0DCEC" } }
                Text { text: "Thư mục ảnh chụp"; color: "#718097"; font.pixelSize: 11 }
                TextField { id: screenshotsPath; Layout.fillWidth: true; Layout.preferredHeight: 48; text: App.screenshotsPath; color: "#27364E"; selectByMouse: true; leftPadding: 16; rightPadding: 16; font.family: "Segoe UI"; font.pixelSize: 12; background: Rectangle { radius: 14; gradient: Gradient { GradientStop { position: 0; color: "#FFFFFF" } GradientStop { position: 1; color: "#E8EFF8" } } border.width: parent.activeFocus ? 2 : 1; border.color: parent.activeFocus ? "#6C8FFF" : "#D0DCEC" } }
                Text { text: "Thư mục bản ghi"; color: "#718097"; font.pixelSize: 11 }
                TextField { id: recordingsPath; Layout.fillWidth: true; Layout.preferredHeight: 48; text: App.recordingsPath; color: "#27364E"; selectByMouse: true; leftPadding: 16; rightPadding: 16; font.family: "Segoe UI"; font.pixelSize: 12; background: Rectangle { radius: 14; gradient: Gradient { GradientStop { position: 0; color: "#FFFFFF" } GradientStop { position: 1; color: "#E8EFF8" } } border.width: parent.activeFocus ? 2 : 1; border.color: parent.activeFocus ? "#6C8FFF" : "#D0DCEC" } }
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Hiệu ứng chuyển động"; color: "#34435A"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Switch {
                        id: animations
                        checked: App.animationsEnabled
                        indicator: Rectangle {
                            implicitWidth: 50; implicitHeight: 28; radius: 14
                            color: animations.checked ? "#6E8DFF" : "#D9E3EF"
                            border.width: 1; border.color: animations.checked ? "#5976DC" : "#C3D0DF"
                            Rectangle {
                                x: animations.checked ? parent.width - width - 4 : 4
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20; height: 20; radius: 10
                                color: "#FFFFFF"
                                border.width: 1; border.color: "#D0D9E6"
                                Behavior on x { NumberAnimation { duration: 190; easing.type: Easing.OutBack } }
                            }
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                    }
                }
                ToolButton { primary: true; glyph: "✓"; text: "Lưu cài đặt"; onClicked: App.saveSettings(receiverName.text, screenshotsPath.text, recordingsPath.text, animations.checked) }
            }
        }
        GlassPanel {
            Layout.fillWidth: true; Layout.preferredHeight: 126
            Column { anchors.fill: parent; anchors.margins: 22; spacing: 8
                Text { text: "Phím tắt"; color: "#2A3950"; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text { width: parent.width; elide: Text.ElideRight; text: "F11: toàn màn hình   •   ESC: thoát toàn màn hình   •   R: xoay 90°"; color: "#718097"; font.pixelSize: 11 }
                Text { width: parent.width; elide: Text.ElideRight; text: "Khung hình tự thích ứng khi iPhone chuyển giữa chế độ dọc và ngang."; color: "#4F7CE2"; font.pixelSize: 11 }
            }
        }
    }

    Popup {
        id: toastPopup
        x: window.width - width - 28
        y: 26
        width: 360; height: 86; padding: 0
        closePolicy: Popup.NoAutoClose
        background: GlassPanel { panelColor: "#FAFFFFFF"; panelRadius: 18; strokeColor: "#BFD2EE" }
        contentItem: Column {
            leftPadding: 18; rightPadding: 18; topPadding: 15; spacing: 6
            Text { id: toastTitle; color: "#29384F"; font.pixelSize: 13; font.weight: Font.DemiBold }
            Text { id: toastMessage; width: parent.width - 36; elide: Text.ElideMiddle; color: "#748299"; font.pixelSize: 10 }
        }
        Timer { id: toastTimer; interval: 3500; onTriggered: toastPopup.close() }
    }

    Connections {
        target: App
        function onToast(title, message) {
            toastTitle.text = title
            toastMessage.text = message
            toastPopup.open()
            toastTimer.restart()
        }
    }
}

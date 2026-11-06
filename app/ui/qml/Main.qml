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
    color: "#070A12"

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
            GradientStop { position: 0.0; color: "#10182A" }
            GradientStop { position: 0.42; color: "#090D18" }
            GradientStop { position: 1.0; color: "#060810" }
        }
    }
    Rectangle {
        width: 620; height: 620; radius: 310
        x: -280; y: -360; color: "#1A3478FF"
        SequentialAnimation on opacity {
            running: App.animationsEnabled && !window.immersive
            loops: Animation.Infinite
            NumberAnimation { from: 0.35; to: 0.75; duration: 4200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.35; duration: 4200; easing.type: Easing.InOutSine }
        }
    }
    Rectangle {
        width: 520; height: 520; radius: 260
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.rightMargin: -260; anchors.bottomMargin: -300
        color: "#123CD9B2"
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
            panelColor: "#D00D1321"
            strokeColor: "#2DFFFFFF"

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
                            GradientStop { position: 0; color: "#5D91FF" }
                            GradientStop { position: 1; color: "#8B5CF6" }
                        }
                        Text { anchors.centerIn: parent; text: "M"; color: "white"; font.pixelSize: 20; font.weight: Font.Bold }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text { text: "Mirror Studio"; color: "#F8FAFF"; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text { text: "AIRPLAY • LOCAL"; color: "#71809C"; font.pixelSize: 9; font.letterSpacing: 1.3 }
                    }
                }

                Text {
                    text: "KHÔNG GIAN"
                    color: "#586781"
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
                    color: "#66192334"
                    border.width: 1
                    border.color: App.receiverRunning ? "#305CE5AA" : "#20FFFFFF"
                    Column {
                        anchors.fill: parent; anchors.margins: 15; spacing: 8
                        Row {
                            spacing: 8
                            Rectangle {
                                width: 8; height: 8; radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: App.hasFrame ? "#55E6A5" : (App.receiverRunning ? "#F4BD62" : "#647086")
                            }
                            Text {
                                text: App.hasFrame ? "Đang trình chiếu" : (App.receiverRunning ? "Đang chờ iPhone" : "Receiver đang tắt")
                                color: "#EDF2FB"; font.pixelSize: 12; font.weight: Font.DemiBold
                            }
                        }
                        Text { width: parent.width; text: App.statusDetail; color: "#8290A8"; font.pixelSize: 10; elide: Text.ElideRight }
                        Text { text: "Kết nối riêng tư trong mạng LAN"; color: "#637797"; font.pixelSize: 9 }
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
                        color: "#F7F9FF"; font.pixelSize: 25; font.weight: Font.DemiBold
                    }
                    Text {
                        text: window.currentPage === 0 ? "Độ trễ thấp • Tự thích ứng màn hình dọc và ngang" : "Dữ liệu được lưu cục bộ trên máy tính"
                        color: "#7B89A1"; font.pixelSize: 11
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Rectangle {
                        width: 124; height: 36; radius: 18
                        color: App.hasFrame ? "#1855E6A5" : "#12FFFFFF"
                        border.width: 1
                        border.color: App.hasFrame ? "#4055E6A5" : "#20FFFFFF"
                        Row {
                            anchors.centerIn: parent; spacing: 7
                            Rectangle { width: 7; height: 7; radius: 4; color: App.hasFrame ? "#55E6A5" : "#6F7A8E" }
                            Text { text: App.hasFrame ? "LIVE  " + App.fps.toFixed(0) + " FPS" : "CHƯA KẾT NỐI"; color: "#DCE5F5"; font.pixelSize: 9; font.weight: Font.DemiBold }
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
                MetricCard { Layout.fillWidth: true; label: "KẾT NỐI"; value: App.hasFrame ? "LIVE" : (App.receiverRunning ? "READY" : "OFFLINE"); detail: "AIRPLAY"; accent: App.hasFrame ? "#55E6A5" : "#72819A" }
                MetricCard { Layout.fillWidth: true; label: "ĐỘ PHÂN GIẢI"; value: App.resolution; detail: App.videoWidth > App.videoHeight ? "NGANG" : "DỌC"; accent: "#6A9CFF" }
                MetricCard { Layout.fillWidth: true; label: "TỐC ĐỘ KHUNG"; value: App.hasFrame ? App.fps.toFixed(1) + " FPS" : "—"; detail: "REAL TIME"; accent: "#A879FF" }
                MetricCard { Layout.fillWidth: true; label: "GHI HÌNH"; value: App.recording ? App.recordingTime : "SẴN SÀNG"; detail: App.recordingPaused ? "TẠM DỪNG" : "LOCAL"; accent: App.recording ? "#FF6F91" : "#77859C" }
            }

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                panelRadius: window.immersive ? 0 : 26
                panelColor: window.immersive ? "#FF000000" : "#C0090D16"
                strokeColor: window.immersive ? "transparent" : "#26FFFFFF"

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
                        color: "#020308"
                        border.width: window.immersive ? 0 : 1
                        border.color: "#405B79A8"
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
                                GradientStop { position: 0; color: "#121D34" }
                                GradientStop { position: 0.55; color: "#0B1020" }
                                GradientStop { position: 1; color: "#18102C" }
                            }
                            Column {
                                anchors.centerIn: parent
                                width: Math.min(360, parent.width - 40)
                                spacing: 13
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 72; height: 72; radius: 24
                                    color: "#225D8FFF"; border.width: 1; border.color: "#4E83AAFF"
                                    Text { anchors.centerIn: parent; text: "⌁"; color: "#C8D9FF"; font.pixelSize: 38 }
                                    SequentialAnimation on scale {
                                        running: App.animationsEnabled && App.receiverRunning
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.94; to: 1.05; duration: 1100; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 0.94; duration: 1100; easing.type: Easing.InOutSine }
                                    }
                                }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: App.receiverRunning ? "Sẵn sàng nhận màn hình" : "Bắt đầu trình chiếu"; color: "#F3F6FD"; font.pixelSize: 19; font.weight: Font.DemiBold }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: App.receiverRunning ? "Mở Trung tâm điều khiển → Phản chiếu màn hình" : "Khởi động receiver để iPhone tìm thấy máy tính"; color: "#8997AD"; font.pixelSize: 11 }
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
                        color: "#E3121826"
                        border.width: 1
                        border.color: "#35FFFFFF"

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
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "●"; color: "#FF7194"; font.pixelSize: 38 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Bản ghi màn hình"; color: "#F3F6FC"; font.pixelSize: 20; font.weight: Font.DemiBold }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; width: 360; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideMiddle; text: App.recordingsPath; color: "#7F8CA2"; font.pixelSize: 10 }
                    ToolButton { anchors.horizontalCenter: parent.horizontalCenter; glyph: "↗"; text: "Mở thư mục"; onClicked: App.openPath(App.recordingsPath) }
                }
            }
            GlassPanel {
                Layout.fillWidth: true; Layout.fillHeight: true
                Column { anchors.centerIn: parent; spacing: 15
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "▣"; color: "#6A9CFF"; font.pixelSize: 42 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Ảnh chụp màn hình"; color: "#F3F6FC"; font.pixelSize: 20; font.weight: Font.DemiBold }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; width: 360; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideMiddle; text: App.screenshotsPath; color: "#7F8CA2"; font.pixelSize: 10 }
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
                Text { text: "Receiver & lưu trữ"; color: "#F5F7FC"; font.pixelSize: 20; font.weight: Font.DemiBold }
                Text { text: "Tên hiển thị trên iPhone"; color: "#8996AA"; font.pixelSize: 11 }
                TextField { id: receiverName; Layout.fillWidth: true; text: App.receiverName; color: "#F0F4FC"; background: Rectangle { radius: 13; color: "#8A101725"; border.color: parent.activeFocus ? "#6C8FFF" : "#25FFFFFF" } }
                Text { text: "Thư mục ảnh chụp"; color: "#8996AA"; font.pixelSize: 11 }
                TextField { id: screenshotsPath; Layout.fillWidth: true; text: App.screenshotsPath; color: "#F0F4FC"; background: Rectangle { radius: 13; color: "#8A101725"; border.color: parent.activeFocus ? "#6C8FFF" : "#25FFFFFF" } }
                Text { text: "Thư mục bản ghi"; color: "#8996AA"; font.pixelSize: 11 }
                TextField { id: recordingsPath; Layout.fillWidth: true; text: App.recordingsPath; color: "#F0F4FC"; background: Rectangle { radius: 13; color: "#8A101725"; border.color: parent.activeFocus ? "#6C8FFF" : "#25FFFFFF" } }
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Hiệu ứng chuyển động"; color: "#DDE4F0"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Switch { id: animations; checked: App.animationsEnabled }
                }
                ToolButton { primary: true; glyph: "✓"; text: "Lưu cài đặt"; onClicked: App.saveSettings(receiverName.text, screenshotsPath.text, recordingsPath.text, animations.checked) }
            }
        }
        GlassPanel {
            Layout.fillWidth: true; Layout.preferredHeight: 126
            Column { anchors.fill: parent; anchors.margins: 22; spacing: 8
                Text { text: "Phím tắt"; color: "#F0F3F9"; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text { text: "F11: toàn màn hình   •   ESC: thoát toàn màn hình   •   R: xoay 90°"; color: "#8996AA"; font.pixelSize: 11 }
                Text { text: "Khung hình tự thích ứng khi iPhone chuyển giữa chế độ dọc và ngang."; color: "#6A9CFF"; font.pixelSize: 11 }
            }
        }
    }

    Popup {
        id: toastPopup
        x: window.width - width - 28
        y: 26
        width: 360; height: 86; padding: 0
        closePolicy: Popup.NoAutoClose
        background: GlassPanel { panelColor: "#F0182032"; panelRadius: 18; strokeColor: "#407DA4FF" }
        contentItem: Column {
            leftPadding: 18; rightPadding: 18; topPadding: 15; spacing: 6
            Text { id: toastTitle; color: "#F4F7FD"; font.pixelSize: 13; font.weight: Font.DemiBold }
            Text { id: toastMessage; width: parent.width - 36; elide: Text.ElideMiddle; color: "#9AA7BA"; font.pixelSize: 10 }
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

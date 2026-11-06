import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: window
    width: 1380
    height: 860
    minimumWidth: 940
    minimumHeight: 650
    visible: true
    title: "iPhone Wireless Mirror — Premium AirPlay Receiver"
    color: "#080B13"
    property int currentPage: 0
    property bool pipMode: false
    property bool wasMaximized: false
    flags: Qt.Window | (pipMode ? Qt.WindowStaysOnTopHint : 0)

    FontLoader { id: uiFont; source: "" }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#101729" }
            GradientStop { position: 0.52; color: "#090D18" }
            GradientStop { position: 1; color: "#070910" }
        }
    }
    Rectangle {
        width: 540; height: 540; radius: 270; x: -220; y: -250
        color: "#16478DF0"; rotation: 12
        SequentialAnimation on opacity {
            running: App.animationsEnabled; loops: Animation.Infinite
            NumberAnimation { to: 0.45; duration: 3600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.9; duration: 3600; easing.type: Easing.InOutSine }
        }
    }
    Rectangle {
        width: 460; height: 460; radius: 230; anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.rightMargin: -190; anchors.bottomMargin: -250; color: "#133A70F6"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: pipMode ? 10 : 18
        spacing: 16

        GlassPanel {
            id: sidebar
            visible: !window.pipMode
            Layout.preferredWidth: window.width < 1080 ? 206 : 238
            Layout.fillHeight: true
            panelColor: "#B0101524"

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 4
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 70
                    Rectangle {
                        width: 40; height: 40; radius: 13
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#6E9EFF" }
                            GradientStop { position: 1; color: "#845CF2" }
                        }
                        Text { anchors.centerIn: parent; text: "⌁"; color: "white"; font.pixelSize: 24; font.weight: Font.Bold }
                    }
                    Column {
                        anchors.left: parent.left; anchors.leftMargin: 52; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                        Text { text: "iPhone Mirror"; color: "#F4F7FF"; font.pixelSize: 15; font.weight: Font.DemiBold }
                        Text { text: "AIRPLAY RECEIVER"; color: "#66758F"; font.pixelSize: 8; font.letterSpacing: 1.5 }
                    }
                }
                Repeater {
                    model: [
                        ["◫", "Dashboard"], ["◉", "Screen Mirroring"], ["⌘", "Devices"],
                        ["●", "Recordings"], ["▣", "Screenshots"], ["⚙", "Settings"], ["ⓘ", "About"]
                    ]
                    NavItem {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        iconText: modelData[0]; label: modelData[1]; selected: window.currentPage === index
                        onClicked: window.currentPage = index
                    }
                }
                Item { Layout.fillHeight: true }
                GlassPanel {
                    Layout.fillWidth: true; Layout.preferredHeight: 92; panelRadius: 16; panelColor: "#631B2337"
                    Rectangle { width: 8; height: 8; radius: 4; color: App.receiverRunning ? "#59E6A6" : (App.status === "error" ? "#FF6D85" : "#59657A"); anchors.left: parent.left; anchors.leftMargin: 15; anchors.top: parent.top; anchors.topMargin: 18 }
                    Text { text: App.receiverRunning ? "Receiver online" : "Receiver offline"; color: "#E7ECF7"; font.pixelSize: 12; font.weight: Font.DemiBold; anchors.left: parent.left; anchors.leftMargin: 32; anchors.top: parent.top; anchors.topMargin: 14 }
                    Text { text: App.statusDetail; color: "#748198"; font.pixelSize: 10; elide: Text.ElideRight; width: parent.width - 30; anchors.left: parent.left; anchors.leftMargin: 15; anchors.top: parent.top; anchors.topMargin: 39 }
                    Text { text: "LAN only  •  Private"; color: "#58749F"; font.pixelSize: 9; anchors.left: parent.left; anchors.leftMargin: 15; anchors.bottom: parent.bottom; anchors.bottomMargin: 12 }
                }
            }
        }

        Item {
            Layout.fillWidth: true; Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent; spacing: 14

                Item {
                    visible: !window.pipMode
                    Layout.fillWidth: true; Layout.preferredHeight: 62
                    Column {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                        Text { text: ["Dashboard", "Screen Mirroring", "Devices", "Recordings", "Screenshots", "Settings", "About"][window.currentPage]; color: "#F5F7FC"; font.pixelSize: 24; font.weight: Font.DemiBold }
                        Text { text: window.currentPage < 2 ? "Low-latency AirPlay receiver on your local network" : "Manage your private mirroring workspace"; color: "#78859B"; font.pixelSize: 11 }
                    }
                    Row {
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 9
                        ToolButton { glyph: window.visibility === Window.FullScreen ? "↙" : "↗"; onClicked: window.visibility = window.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen }
                        ToolButton { glyph: "▱"; onClicked: { window.pipMode = true; window.width = 440; window.height = 760; window.show() } }
                        ToolButton { glyph: "⚙"; onClicked: window.currentPage = 5 }
                    }
                }

                StackLayout {
                    currentIndex: window.currentPage
                    Layout.fillWidth: true; Layout.fillHeight: true

                    Item { MirrorDashboard { anchors.fill: parent; compact: false } }
                    Item { MirrorDashboard { anchors.fill: parent; compact: false } }

                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width; spacing: 14
                            GlassPanel {
                                Layout.fillWidth: true; Layout.preferredHeight: 190
                                Column { anchors.fill: parent; anchors.margins: 24; spacing: 14
                                    Text { text: "Thiết bị hiện tại"; color: "#F1F4FB"; font.pixelSize: 18; font.weight: Font.DemiBold }
                                    Text { text: App.hasFrame ? "iPhone đang truyền màn hình" : "Chưa có thiết bị kết nối"; color: App.hasFrame ? "#67E3A7" : "#8490A5"; font.pixelSize: 14 }
                                    Text { width: parent.width; wrapMode: Text.WordWrap; text: "UxPlay chỉ cung cấp tên/model khi client gửi thông tin hợp lệ. Ứng dụng không suy đoán danh tính thiết bị và không thu thập dữ liệu ngoài LAN."; color: "#79869C"; font.pixelSize: 12 }
                                }
                            }
                        }
                    }

                    LibraryPage { title: "Recordings"; folder: App.recordingsPath; icon: "●" }
                    LibraryPage { title: "Screenshots"; folder: App.screenshotsPath; icon: "▣" }

                    ScrollView {
                        clip: true
                        SettingsPage { width: parent.width }
                    }

                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: parent.width; spacing: 14
                            GlassPanel {
                                Layout.fillWidth: true; Layout.preferredHeight: 300
                                Column { anchors.fill: parent; anchors.margins: 28; spacing: 14
                                    Text { text: "iPhone Wireless Mirror"; color: "#F4F7FF"; font.pixelSize: 23; font.weight: Font.DemiBold }
                                    Text { text: "Version 0.1.0  •  Local-first AirPlay Receiver"; color: "#7BA8FF"; font.pixelSize: 12 }
                                    Text { width: parent.width; wrapMode: Text.WordWrap; text: "Giao diện PySide6/QML điều khiển receiver UxPlay native. Video H.264 được chuyển qua RTP loopback và giải mã bằng FFmpeg/PyAV. Không có video nào được tải lên cloud."; color: "#9AA5B8"; font.pixelSize: 13; lineHeight: 1.35 }
                                    Text { width: parent.width; wrapMode: Text.WordWrap; text: "UxPlay: GPL-3.0. Ứng dụng chưa tuyên bố tương thích mọi phiên bản iOS; kiểm thử E2E cần iPhone thật trên cùng LAN."; color: "#F1BA78"; font.pixelSize: 12 }
                                }
                            }
                        }
                    }
                }
            }

            MirrorDashboard {
                anchors.fill: parent
                visible: window.pipMode
                compact: true
                z: 20
            }
        }
    }

    component MirrorDashboard: Item {
        id: dashboard
        property bool compact: false
        ColumnLayout {
            anchors.fill: parent; spacing: 12
            RowLayout {
                visible: !dashboard.compact
                Layout.fillWidth: true; Layout.preferredHeight: 82; spacing: 10
                MetricCard { Layout.fillWidth: true; label: "Receiver"; value: App.receiverRunning ? "ONLINE" : "OFFLINE"; detail: "LAN"; accent: App.receiverRunning ? "#5FE4A8" : "#69758B" }
                MetricCard { Layout.fillWidth: true; label: "Resolution"; value: App.resolution; detail: App.hasFrame ? "LIVE" : "NO DATA"; accent: "#759FFF" }
                MetricCard { Layout.fillWidth: true; label: "Frame rate"; value: App.hasFrame ? App.fps.toFixed(1) + " FPS" : "—"; detail: "MEASURED"; accent: "#B984FF" }
                MetricCard { Layout.fillWidth: true; label: "Recording"; value: App.recording ? App.recordingTime : "IDLE"; detail: App.recordingPaused ? "PAUSED" : "LOCAL"; accent: App.recording ? "#FF6B82" : "#728097" }
            }
            GlassPanel {
                Layout.fillWidth: true; Layout.fillHeight: true
                panelColor: "#A00D111E"; panelRadius: dashboard.compact ? 24 : 28

                Item {
                    id: stage
                    anchors.fill: parent; anchors.margins: dashboard.compact ? 10 : 20

                    Rectangle {
                        id: phone
                        anchors.centerIn: parent
                        width: {
                            if (App.hasFrame && App.resolution !== "—") return Math.min(parent.width, parent.height * (9/16))
                            return Math.min(parent.width * 0.52, 360)
                        }
                        height: Math.min(parent.height - (dashboard.compact ? 80 : 50), width * 2.02)
                        radius: 44
                        color: "#05070C"
                        border.width: 2
                        border.color: App.hasFrame ? "#657EACFF" : "#38445A"
                        scale: App.hasFrame ? 1 : 0.96
                        Behavior on scale { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent; anchors.margins: 8; radius: 37; color: "#0C1120"; clip: true
                            Image {
                                id: video
                                anchors.fill: parent
                                source: App.hasFrame ? "image://mirror/frame?" + App.frameSerial : ""
                                fillMode: Image.PreserveAspectFit
                                cache: false; asynchronous: false; smooth: true
                                visible: App.hasFrame
                            }
                            Item {
                                anchors.fill: parent; visible: !App.hasFrame
                                Rectangle {
                                    anchors.fill: parent
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#17233F" }
                                        GradientStop { position: 0.54; color: "#0E1425" }
                                        GradientStop { position: 1; color: "#19112B" }
                                    }
                                }
                                Repeater {
                                    model: 3
                                    Rectangle {
                                        required property int index
                                        anchors.centerIn: parent
                                        width: 92 + index * 56; height: width; radius: width/2; color: "transparent"
                                        border.width: 2; border.color: "#4A76A9FF"
                                        SequentialAnimation on opacity {
                                            running: App.animationsEnabled && !App.hasFrame; loops: Animation.Infinite
                                            PauseAnimation { duration: index * 480 }
                                            NumberAnimation { from: 0.12; to: 0.8; duration: 1200; easing.type: Easing.OutQuad }
                                            NumberAnimation { to: 0.08; duration: 1200; easing.type: Easing.InQuad }
                                        }
                                    }
                                }
                                Text { anchors.centerIn: parent; anchors.verticalCenterOffset: -2; text: "⌁"; color: "#B8CEFF"; font.pixelSize: 52 }
                                Column {
                                    anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 54; spacing: 8
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: App.status === "error" ? "Receiver unavailable" : "Waiting for iPhone"; color: "#EDF3FF"; font.pixelSize: 16; font.weight: Font.DemiBold }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Control Center  ›  Screen Mirroring"; color: "#8190A9"; font.pixelSize: 10 }
                                }
                            }
                        }
                        Rectangle { visible: !App.hasFrame; width: 104; height: 30; radius: 15; color: "#020307"; anchors.top: parent.top; anchors.topMargin: 15; anchors.horizontalCenter: parent.horizontalCenter }
                    }

                    Column {
                        visible: App.status === "error" && !App.hasFrame
                        anchors.right: parent.right; anchors.top: parent.top; width: Math.min(300, parent.width * 0.3); spacing: 7
                        Text { text: "Native dependency missing"; color: "#FF97A9"; font.pixelSize: 12; font.weight: Font.DemiBold }
                        Text { width: parent.width; wrapMode: Text.WordWrap; text: App.statusDetail; color: "#9EA8B9"; font.pixelSize: 10 }
                    }

                    ToolButton {
                        visible: dashboard.compact
                        glyph: "↩"; text: "Dashboard"
                        anchors.left: parent.left; anchors.top: parent.top
                        onClicked: { window.pipMode = false; window.width = 1380; window.height = 860; window.show() }
                    }
                }
            }
            GlassPanel {
                Layout.fillWidth: true; Layout.preferredHeight: 68; panelRadius: 20; panelColor: "#A3161C2B"
                Row {
                    anchors.centerIn: parent; spacing: 9
                    ToolButton { visible: !App.receiverRunning; glyph: "▶"; text: dashboard.compact ? "" : "Start Receiver"; onClicked: App.startReceiver() }
                    ToolButton { visible: App.receiverRunning; glyph: "■"; text: dashboard.compact ? "" : "Stop Receiver"; danger: true; onClicked: App.stopReceiver() }
                    ToolButton { glyph: "▣"; text: dashboard.compact ? "" : "Screenshot"; enabled: App.hasFrame; onClicked: App.captureScreenshot() }
                    ToolButton { glyph: App.recording ? "■" : "●"; text: dashboard.compact ? "" : (App.recording ? "Stop" : "Record"); danger: App.recording; enabled: App.hasFrame; onClicked: App.toggleRecording() }
                    ToolButton { visible: App.recording; glyph: App.recordingPaused ? "▶" : "Ⅱ"; onClicked: App.toggleRecordingPause() }
                    ToolButton { glyph: App.muted ? "×" : "◖"; text: dashboard.compact ? "" : (App.muted ? "Unmute" : "Mute"); onClicked: App.toggleMute() }
                }
            }
        }
    }

    component LibraryPage: Item {
        id: library
        property string title: "Library"
        property string folder: ""
        property string icon: "□"
        GlassPanel {
            anchors.fill: parent
            Column {
                anchors.centerIn: parent; spacing: 16
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: library.icon; color: "#7EA7FF"; font.pixelSize: 48 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: library.title + " are stored locally"; color: "#EEF2FA"; font.pixelSize: 18; font.weight: Font.DemiBold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; width: Math.min(560, library.width - 80); horizontalAlignment: Text.AlignHCenter; elide: Text.ElideMiddle; text: library.folder; color: "#7E899D"; font.pixelSize: 11 }
                ToolButton { anchors.horizontalCenter: parent.horizontalCenter; glyph: "↗"; text: "Open Folder"; onClicked: App.openPath(library.folder) }
            }
        }
    }

    component SettingsPage: ColumnLayout {
        spacing: 14
        GlassPanel {
            Layout.fillWidth: true; Layout.preferredHeight: 410
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 26; spacing: 15
                Text { text: "Receiver & Storage"; color: "#F3F6FC"; font.pixelSize: 18; font.weight: Font.DemiBold }
                Text { text: "Tên hiển thị trên iPhone"; color: "#8F9AAD"; font.pixelSize: 11 }
                TextField { id: receiverNameField; Layout.fillWidth: true; text: App.receiverName; color: "#EEF3FC"; placeholderText: "Receiver name"; background: Rectangle { radius: 12; color: "#66101725"; border.color: parent.activeFocus ? "#687CAFFF" : "#28FFFFFF" } }
                Text { text: "Thư mục ảnh"; color: "#8F9AAD"; font.pixelSize: 11 }
                TextField { id: shotsField; Layout.fillWidth: true; text: App.screenshotsPath; color: "#EEF3FC"; background: Rectangle { radius: 12; color: "#66101725"; border.color: parent.activeFocus ? "#687CAFFF" : "#28FFFFFF" } }
                Text { text: "Thư mục video"; color: "#8F9AAD"; font.pixelSize: 11 }
                TextField { id: recField; Layout.fillWidth: true; text: App.recordingsPath; color: "#EEF3FC"; background: Rectangle { radius: 12; color: "#66101725"; border.color: parent.activeFocus ? "#687CAFFF" : "#28FFFFFF" } }
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Animations"; color: "#DCE2ED"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Switch { id: animationSwitch; checked: App.animationsEnabled }
                }
                ToolButton { glyph: "✓"; text: "Save Settings"; onClicked: App.saveSettings(receiverNameField.text, shotsField.text, recField.text, animationSwitch.checked) }
            }
        }
        GlassPanel {
            Layout.fillWidth: true; Layout.preferredHeight: 130
            Column { anchors.fill: parent; anchors.margins: 22; spacing: 8
                Text { text: "AirPlay security"; color: "#EEF2FA"; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text { width: parent.width; wrapMode: Text.WordWrap; text: "PIN, fixed ports, hardware decoding, recording FPS and UxPlay path are available in the local JSON config. Receiver restart is required after network/audio changes."; color: "#8995A9"; font.pixelSize: 11 }
            }
        }
    }

    Popup {
        id: toastPopup
        x: window.width - width - 30; y: 28
        width: 350; height: 88; padding: 0
        closePolicy: Popup.NoAutoClose
        background: GlassPanel { panelColor: "#EE182035"; panelRadius: 18; strokeColor: "#3F7EA7FF" }
        contentItem: Column {
            leftPadding: 18; rightPadding: 18; topPadding: 15; spacing: 6
            Text { id: toastTitle; color: "#F3F7FF"; font.pixelSize: 13; font.weight: Font.DemiBold }
            Text { id: toastMessage; width: parent.width - 36; elide: Text.ElideMiddle; color: "#9AA7BC"; font.pixelSize: 10 }
        }
        Timer { id: toastTimer; interval: 3600; onTriggered: toastPopup.close() }
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


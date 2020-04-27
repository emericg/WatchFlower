import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

Item {
    // This code should only run for desktop windowed applications.
    enabled: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

    // The ApplicationWindow instance that will be manipulated. MUST be set by the calling application.
    property ApplicationWindow windowInstance: null

    // Name of the setting section. Can be changed by the calling application.
    property string windowName: "ApplicationWindow"

    // Bypass initial visibility state if needed. Can be changed by the calling application.
    property bool windowStartMinimized: false

    // QSettings file. Will use organisation and project name.
    Settings {
        id: s
        category: windowName

        property int x
        property int y
        property int width
        property int height
        property int visibility
    }

    // Restore settings ////////////////////////////////////////////////////////

    Component.onCompleted: restoreSettings()

    function restoreSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        if (s.width && s.height) {
            windowInstance.x = s.x;
            windowInstance.y = s.y;
            windowInstance.width = s.width;
            windowInstance.height = s.height;
            if (!windowStartMinimized) windowInstance.visibility = s.visibility;
        }
    }

    // Save settings ///////////////////////////////////////////////////////////

    Timer {
        id: saveSettingsTimer
        interval: 2000 // 2s is probably good enough...
        repeat: false // started by application geometry changes
        onTriggered: saveSettings()
    }

    Connections {
        target: windowInstance
        function onXChanged() { saveSettingsTimer.restart() }
        function onYChanged() { saveSettingsTimer.restart() }
        function onWidthChanged() { saveSettingsTimer.restart() }
        function onHeightChanged() { saveSettingsTimer.restart() }
        function onVisibilityChanged() { saveSettingsTimer.restart() }
    }

    function saveSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        switch(windowInstance.visibility) {
        case ApplicationWindow.Windowed:
            s.x = windowInstance.x;
            s.y = windowInstance.y;
            s.width = windowInstance.width;
            s.height = windowInstance.height;
            s.visibility = windowInstance.visibility;
            break;
        case ApplicationWindow.Maximized:
            s.visibility = windowInstance.visibility;
            break;
        case ApplicationWindow.FullScreen:
            s.visibility = windowInstance.visibility;
            break;
        }
    }
}

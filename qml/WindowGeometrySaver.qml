import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

Item {
    // MUST be set by the calling application.
    property Window window

    // Can be changed by the calling application.
    property string windowName: "ApplicationWindow"

    ////////////////////////////////////////////////////////////////////////////

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

    Timer {
        id: saveSettingsTimer
        interval: 3333 // 3s is probably good enough...
        repeat: false // started by application geometry changes
        onTriggered: saveSettings()
    }

    Connections {
        target: window
        onXChanged: saveSettingsTimer.restart()
        onYChanged: saveSettingsTimer.restart()
        onWidthChanged: saveSettingsTimer.restart()
        onHeightChanged: saveSettingsTimer.restart()
        onVisibilityChanged: saveSettingsTimer.restart()
    }

    Component.onCompleted: restoreSettings()

    ////////////////////////////////////////////////////////////////////////////

    // Restore settings
    function restoreSettings() {
        if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") {
            // Restore settings from saved settings
            if (s.width && s.height) {
                window.x = s.x;
                window.y = s.y;
                window.width = s.width;
                window.height = s.height;
                window.visibility = s.visibility;
            }
        }
    }

    // Save settings
    function saveSettings() {
        if (Qt.platform.os !== "android" && Qt.platform.os !== "ios") {
            switch(window.visibility) {
            case ApplicationWindow.Windowed:
                s.x = window.x;
                s.y = window.y;
                s.width = window.width;
                s.height = window.height;
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.FullScreen:
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.Maximized:
                s.visibility = window.visibility;
                break;
            }
        }
    }
}

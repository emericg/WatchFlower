import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import Qt.labs.settings 1.0

Item {
    // This code should only run for desktop windowed applications.
    enabled: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

    // The ApplicationWindow instance that will be manipulated. MUST be set by the calling application.
    property ApplicationWindow windowInstance: null

    // Name of the setting section. Can be changed by the calling application.
    property string windowName: "ApplicationWindow"

    // QSettings file. Will use organisation and project name.
    Settings {
        id: st
        category: windowName

        property int x
        property int y
        property int width
        property int height
        property int visibility // https://doc.qt.io/qt-5/qwindow.html#Visibility-enum
    }

    // Restore settings ////////////////////////////////////////////////////////

    Component.onCompleted: restoreSettings()

    function restoreSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        if (st.width && st.height) {
            windowInstance.x = st.x;
            windowInstance.y = st.y;
            windowInstance.width = st.width;
            windowInstance.height = st.height;
            windowInstance.visibility = st.visibility;
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
        onXChanged: { saveSettingsTimer.restart() }
        onYChanged: { saveSettingsTimer.restart() }
        onWidthChanged: { saveSettingsTimer.restart() }
        onHeightChanged: { saveSettingsTimer.restart() }
        onVisibilityChanged: { saveSettingsTimer.restart() }
    }

    function saveSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        switch(windowInstance.visibility) {
            case ApplicationWindow.Windowed:
                st.x = windowInstance.x;
                st.y = windowInstance.y;
                st.width = windowInstance.width;
                st.height = windowInstance.height;
                st.visibility = windowInstance.visibility;
                break;
            case ApplicationWindow.Maximized:
                st.visibility = windowInstance.visibility;
                break;
            case ApplicationWindow.FullScreen:
                st.visibility = windowInstance.visibility;
                break;
        }
    }
}

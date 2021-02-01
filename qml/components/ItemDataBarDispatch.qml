import QtQuick 2.12

Loader {
    id: itemDataBar
    source: (settingsManager.bigIndicator) ? "ItemDataBarCompact.qml" : "ItemDataBarFilled.qml"
}

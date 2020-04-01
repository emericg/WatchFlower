import QtQuick 2.9

Loader {
    id: itemDataBar
    source: (settingsManager.bigIndicator) ? "ItemDataBarCompact.qml" : "ItemDataBarFilled.qml"
}

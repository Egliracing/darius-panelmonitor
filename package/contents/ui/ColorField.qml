import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs

RowLayout {
    id: field
    property string colorValue: "#54c7ec"
    QQC2.Button {
        text: i18n("Choose color…")
        icon.name: "color-picker"
        onClicked: { dialog.selectedColor = field.colorValue; dialog.open(); }
    }
    Rectangle { width: 26; height: 26; radius: 5; color: field.colorValue; border.width: 1; border.color: "#808080" }
    ColorDialog {
        id: dialog
        title: i18n("Choose display color")
        onAccepted: field.colorValue = selectedColor.toString()
    }
}


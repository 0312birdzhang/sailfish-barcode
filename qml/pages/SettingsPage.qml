/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

This page uses code from: https://github.com/kimmoli/paint/blob/master/qml/pages/penSettingsDialog.qml

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import QtQuick 2.1
import Sailfish.Silica 1.0

import "../js/Settings.js" as Settings
import "../js/History.js" as History

Page {
    id: settingsPage

    property var colors: [ "#FF0080", "#FF0000", "#FF8000", "#FFFF00", "#00FF00",
                           "#8000FF", "#00FFFF", "#0000FF" ]

    property int currentColor: getColorFromSettings()

    function getColorFromSettings() {
        var savedColor = Settings.get(Settings.keys.MARKER_COLOR)
        for	(var i = 0; i < colors.length; i++) {
            if (savedColor === colors[i]) {
                return i
            }
        }
        return 0
    }

    SilicaFlickable {
        id: settingsPageFlickable
        anchors.fill: parent
        contentHeight: col.height

    Column {
        id: col
        width: parent.width
        height: childrenRect.height + 2 * Theme.paddingLarge
        spacing: Theme.paddingLarge

        anchors {
            left: parent.left;
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge * 2
        }

        /*
        anchors {
            fill: parent
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
        }
        */

        PageHeader {
            title: qsTr("Settings")
        }

        IconTextSwitch {
            checked: Settings.getBoolean(Settings.keys.SOUND)
            text: qsTr("Detection sound")
            icon.source: "image://theme/icon-m-speaker"
            onCheckedChanged: {
                Settings.setBoolean(Settings.keys.SOUND, checked)
            }
        }

        IconTextSwitch {
            checked: Settings.getBoolean(Settings.keys.SCAN_ON_START)
            text: qsTr("Scan on start")
            icon.source: "image://theme/icon-m-play"
            onCheckedChanged: {
                Settings.setBoolean(Settings.keys.SCAN_ON_START, checked)
            }
        }

        Slider {
            width: parent.width
            minimumValue: 5.0
            maximumValue: 60.0
            value: Settings.get(Settings.keys.SCAN_DURATION)
            stepSize: 5
            label: qsTr("Scan duration")
            valueText: qsTr("%1 seconds").arg(value)
            onSliderValueChanged: {
                Settings.set(Settings.keys.SCAN_DURATION, value)
            }
        }

        SectionHeader {
            property int count: History.getHistorySize()
            id: headerHistory
            text: qsTr("History settings (count: %1)").arg(count)
        }

        Slider {
            id: historySizeSlider
            width: parent.width
            minimumValue: 0
            maximumValue: 100
            value: Settings.get(Settings.keys.HISTORY_SIZE)
            stepSize: 10
            label: qsTr("History size")
            valueText: value === 0 ? qsTr("deactivated") : qsTr("%1 items").arg(value)
            onSliderValueChanged: {
                var currentSize = History.getHistorySize()
                if (value < currentSize) {
                    historyConfirmButtons.visible = true
                }
                else {
                    historyConfirmButtons.visible = false
                    Settings.set(Settings.keys.HISTORY_SIZE, value)
                }
            }
        }

        Row {
            id: historyConfirmButtons
            width: parent.width
            visible: false

            Button {
                width: parent.width / 2
                text: qsTr("Confirm resize")
                onClicked: {
                    History.applyNewHistorySize(historySizeSlider.value)
                    Settings.set(Settings.keys.HISTORY_SIZE, historySizeSlider.value)
                    historyConfirmButtons.visible = false
                    headerHistory.count = History.getHistorySize()
                }
            }

            Button {
                width: parent.width / 2
                text: qsTr("Cancel")
                onClicked: {
                    historyConfirmButtons.visible = false
                }
            }
        }

        SectionHeader {
            text: qsTr("Select marker color")
        }

        Grid {
            id: colorSelector
            columns: 4

            Repeater {
                model: colors

                Rectangle {
                    width: col.width/colorSelector.columns
                    height: col.width/colorSelector.columns
                    radius: Theme.paddingLarge
                    color: (index == currentColor) ? colors[index] : "transparent"

                    Rectangle {
                        width: parent.width - 2 * Theme.paddingLarge
                        height: parent.height - 2 * Theme.paddingLarge
                        radius: Theme.paddingLarge
                        color: colors[index]
                        anchors.centerIn: parent
                    }

                    BackgroundItem {
                        anchors.fill: parent
                        onClicked: {
                            currentColor = index
                            Settings.set(Settings.keys.MARKER_COLOR, colors[index])
                        }
                    }
                }
            }
        }

        Slider {
            width: parent.width
            minimumValue: 0
            maximumValue: 15
            value: Settings.get(Settings.keys.RESULT_VIEW_DURATION)
            stepSize: 1
            label: qsTr("Mark detected code")
            valueText: value === 0 ? qsTr("deactivated") : qsTr("%1 seconds").arg(value)
            onSliderValueChanged: {
                Settings.set(Settings.keys.RESULT_VIEW_DURATION, value)
            }
        }

    }

    }

    VerticalScrollDecorator { flickable: settingsPageFlickable }
}

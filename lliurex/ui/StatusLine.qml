/*
    Lliurex Sddm theme

    Copyright (C) 2019  Enrique Medina Gremaldos <quiqueiii@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

import QtQuick 2.0
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.15


RowLayout {
    id: root

    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Layout.fillWidth:true

    property alias text: label.text
    property int stage: 1
    property int currentStage: -1

    PlasmaCore.IconItem {
        Layout.alignment: Qt.AlignVCenter

        source: {
            if (root.stage>root.currentStage) {
                return "choice-rhomb";
            }

            if (root.stage == root.currentStage) {
                return "arrow-right";
            }

            if (root.stage < root.currentStage) {
                return "checkbox";
            }
        }

        implicitWidth: 22
        implicitHeight:22
    }

    PlasmaComponents.Label {
        id: label
        Layout.alignment: Qt.AlignVCenter
    }
}

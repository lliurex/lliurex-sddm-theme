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

import QtQuick 2.0
import QtQuick.Controls 2.0 as Controls

Controls.Button {
    id: control
    
    property Gradient colorNormal :  Gradient {
        GradientStop { position: 0.0; color: "#f1f2f3" }
        GradientStop { position: 1.0; color: "#e8e9ea" }
    }
    
    palette.highlight: "#3daee9"
    
    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        visible: !control.flat || control.down || control.checked || control.highlighted
        gradient: colorNormal
        border.color: control.visualFocus ? control.palette.highlight : control.palette.mid
        border.width: control.visualFocus ? 2 : 1
    }
}
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
    hoverEnabled: true
    
    property Gradient colorNormal :  Gradient {
        GradientStop { position: 0.0; color: "#f1f2f3" }
        GradientStop { position: 1.0; color: "#e8e9ea" }
    }
    
    property Gradient colorHighlight :  Gradient {
        GradientStop { position: 0.0; color: "#3daee9" }
        GradientStop { position: 1.0; color: "#1894d4" }
    }
    
    palette.highlight: "#3daee9"
    palette.highlightedText: "#fafafa"
    
    contentItem: Text {
        text: control.text
        font: control.font
        color: control.visualFocus ? palette.highlightedText : palette.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    
    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        visible: !control.flat || control.down || control.checked || control.highlighted

        gradient: control.visualFocus ? colorHighlight : colorNormal
        border.color: control.hovered ? control.palette.highlight : control.palette.mid
        
    }
}
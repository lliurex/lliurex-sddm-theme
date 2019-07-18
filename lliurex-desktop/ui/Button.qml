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
import QtQuick.Controls 2.0

Rectangle {
    
    id: button
    
    signal clicked();
    property string text: ""
    property int minWidth:0
    
    property Gradient colorNormal :  Gradient {
        GradientStop { position: 0.0; color: "#f1f2f3" }
        GradientStop { position: 1.0; color: "#e8e9ea" }
    }
    
    property Gradient colorPressed :  Gradient {
        GradientStop { position: 0.0; color: "#c2e0f5" }
        GradientStop { position: 1.0; color: "#b0d9f5" }
    }
    
    states: [
        State {
            name: "normal"
            when: enabled && mouseArea.containsPress==false && mouseArea.containsMouse==false
            PropertyChanges { target: button; gradient: colorNormal ; border.color: "#b3b5b6" }
            PropertyChanges { target: label; color: "#0e0e0e" }
        }
        ,
        State {
            name: "hover"
            when: enabled && mouseArea.containsPress==false && mouseArea.containsMouse==true
            PropertyChanges { target: button; gradient: colorNormal ; border.color: "#c2e0f5" }
            PropertyChanges { target: label; color: "#0e0e0e" ; }
        }
        ,
        State {
            name: "pressed"
            when: enabled && mouseArea.containsPress==true && mouseArea.containsMouse==true
            PropertyChanges { target: button; gradient: colorPressed ; border.color: "#c2e0f5"}
            PropertyChanges { target: label; color: "#0e0e0e" }
        }
        ,
        State {
            name: "disabled"
            when: enabled==false
            PropertyChanges { target: button; gradient: colorNormal ; border.color: "#b3b5b6"}
            PropertyChanges { target: label; color: "#8e8e8e" }
        }
    ]
    
    radius: 3
    border.width: 2
    
    width: ((label.width*1.6)>minWidth) ? (label.width*1.6) : minWidth
    height:label.height*2.0
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        
        onClicked: parent.clicked()
        
    }
    
    Text {
        id: label
        text:button.text
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
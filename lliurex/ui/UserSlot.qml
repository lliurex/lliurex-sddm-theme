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

Rectangle {
    id: userSlot
    
    property string filter : ""
    property alias image: userImage.source
    property alias name: userName.text
    property bool highlight: false
    
    signal selected (string name)
    
    width: 128
    height: 128
    color: highlight ? "#3daee9":"transparent"
    
    visible : filter.length==0 || (filter.length>0 && name.startsWith(filter))
    
    Column {
        id: column
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        
        Image {
            id: userImage
            width: 64
            height: 64
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            id:userName
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            //color="#bfdcf1"
            border.color= "#3daee9"
            border.width=1
        }
        onExited: {
            border.color="transparent"
            border.width=0
        }
        
        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                selected(name)
            }
        }
    }
}
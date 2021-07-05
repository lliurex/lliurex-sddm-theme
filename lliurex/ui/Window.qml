/*
    Lliurex Sddm theme

    Copyright (C) 2021  Enrique Medina Gremaldos <quiqueiii@gmail.com>

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

import QtQuick 2.6
import QtQuick.Controls 2.6 as QQC2
import QtQuick.Layouts 1.15

Item {
    
    id: root
    default property Item contentItem: null
    property int margin: 12
    property int shadowMargin: 6
    property int roundRadius: 5
    property alias title: lblTitle.text
    
    Rectangle {
        id: shadow
        color: "#40000000"
        radius:roundRadius
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
    }
    
    Rectangle {
        id: background
        color: "#eff0f1"
        radius:roundRadius
        anchors.centerIn: parent
        width:shadow.width-shadowMargin
        height:shadow.height-shadowMargin
        
        ColumnLayout {
            anchors.leftMargin: root.margin
            anchors.rightMargin: root.margin
            anchors.bottomMargin: root.margin
            anchors.topMargin: 8
            anchors.centerIn: parent
            anchors.fill:parent
            
            
            Text {
                id: lblTitle
                Layout.alignment: Qt.AlignHCenter
            }
            
            Item {
                id: container
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                //width: background.width-margin
                //height: background.height-margin-y
            }
        }
        
    }
    
    onContentItemChanged: {
        if(root.contentItem !== null) {
            root.contentItem.parent = container;
        }
    }
    
}

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

FocusScope {
    id: userGrid
    
    property alias model: grid.model
    property string filter : ""
    signal selected(string name)
    signal cancel()
    
    focus: true
    
    Keys.onPressed: {
        var code = event.text.charCodeAt(0)
        
        if (code<32) {
            if (event.key == Qt.Key_Backspace) {
                filter=filter.substring(0, filter.length - 1);
            }
            if (event.key == Qt.Key_Return) {
                console.log("Boom")
                //ToDo
            }
            if (event.key == Qt.Key_Escape) {
                cancel()
            }
        }
        else {
            console.log("[",event.text,"]")
            filter+=event.text
            console.log(filter)
        }
        
    }
    
    onFilterChanged: {
        for (var i = 0; i < grid.children.length; i++) {
            grid.children[i].filter=filter
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            parent.focus = true
        }
    }
    
    Grid {
        id: grid
        rows: 16
        columns: width/128
        spacing: 4
        
        anchors.fill: parent
        
        property var model
        
        onModelChanged: {
            
            var component=Qt.createComponent("UserSlot.qml")
            
            for (var n=0;n< model.count;n++) {
                var index=model.index(n,0)
                var name=model.data(index,0x0100+1)
                var home=model.data(index,0x0100+3)
                var icon=model.data(index,0x0100+4)
                console.log(name)
                console.log(icon)
                var o = component.createObject(grid,{name:name,image:icon})
                
                o.selected.connect(selected)
            }
            
            //TEST
            for (var n=0;n<64;n++) {
                var o = component.createObject(grid,{name:"alu"+n,image:"file:///usr/share/sddm/faces/.face.icon"})
                
                o.selected.connect(selected)
            }
        }
    }
    
    onSelected: {
        console.log("Selected ",name)
    }
    
    Rectangle {
        id: nameFilter
        color: "#07000000"
        
        z:grid.z+10
        visible: parent.filter!=""
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
            
        width: text.width+20
        height: text.height+10
        
        Text {
            id: text
            text: userGrid.filter
            anchors.centerIn: parent
        }
    }
}
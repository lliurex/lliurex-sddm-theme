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

import "." as Lliurex
import QtQuick 2.0
import QtQuick.Layouts 1.1 as Layouts
import QtQuick.Controls 2.5 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore


FocusScope {
    id: userGrid
    
    property alias model: grid.model
    property string filter : ""
    signal selected(string name)
    signal cancel()
    
    Keys.onPressed: {
        if (event.key == Qt.Key_Return) {
            for (var n = 0; n < grid.children.length; n++) {
                if (grid.children[n].visible) {
                    selected(grid.children[n].name);
                    break;
                }
            }
            
        }
        
        if (event.key == Qt.Key_Escape) {
            cancel();
        }
    }
    
    onFilterChanged: {
        var hl=filter.length>0;
        var first=true;
        var visibles=0;
        
        for (var i = 0; i < grid.children.length; i++) {
            grid.children[i].filter=filter;
        }
        
        for (var n=0;n<grid.children.length;n++) {
            if (grid.children[n].visible) {
                visibles++;
            }
            if (hl && first && grid.children[n].visible) {
                first=false;
                grid.children[n].highlight=true;
            }
            else {
                grid.children[n].highlight=false;
            }
        }
        
        scroll.Controls.ScrollBar.vertical.position=0;
        grid.rows=(visibles/grid.columns)+0.5;
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            parent.focus = true
        }
    }
    
    Layouts.ColumnLayout {
        anchors.fill:parent
        
        Controls.TextField {
            height:32
            width: 200
            focus:true
            
            onTextChanged: {
                userGrid.filter=text
            }
            
            placeholderText: i18nd("lliurex-sddm","Search...")
            palette.highlight: "#3daee9"
        }
        
        Controls.ScrollView {
            id: scroll
            Layouts.Layout.fillHeight: true
            Layouts.Layout.fillWidth: true
            clip:true
            Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
            Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AlwaysOn
            contentWidth: width
            
            Grid {
                id: grid
                rows: 4
                columns: width/128
                spacing: 4
                
                anchors.fill: parent
                
                property var model
                
                Component.onCompleted: {
                    rows = (model.count/columns)+0.5;
                }
                
                onModelChanged: {
                    
                    var component=Qt.createComponent("UserSlot.qml");
                    
                    for (var n=0;n< model.count;n++) {
                        var index=model.index(n,0);
                        var name=model.data(index,0x0100+1);
                        var icon=model.data(index,0x0100+4);
                        var o = component.createObject(grid,{name:name,image:icon});
                        
                        o.selected.connect(selected);
                    }
                    
                    //TEST
                    /*
                    for (var n=0;n<96;n++) {
                        var o = component.createObject(grid,{name:"alu"+n,image:"file:///usr/share/sddm/faces/.face.icon"})
                        
                        o.selected.connect(selected)
                    }
                    */
                }
            }
        }
        
        Lliurex.Button {
            Layouts.Layout.alignment: Qt.AlignRight
            text: i18nd("lliurex-sddm","Cancel")
            
            onClicked: {
                cancel();
            }
            
        }
        
    }
    
    onSelected: {
        console.log("Selected ",name);
    }
    
}
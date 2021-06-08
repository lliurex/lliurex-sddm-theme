/*
    Lliurex Live Sddm theme

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

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as Sddm
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.10 as Kirigami

Rectangle {
    id: theme
    
    property variant geometry: screenModel.geometry(screenModel.primary)
    x: geometry.x
    y: geometry.y
    width: geometry.width
    height: geometry.height
    
    color: "#2980b9"
    
    ListModel {
        id: langs
            ListElement {
                displayName: "Spanish"
                name: "es"
            }
            
            ListElement {
                displayName: "Valencia"
                name: "ca@valencia"
            }
            
            ListElement {
                displayName: "English"
                name: "en"
            }
    }
    
    QQC2.Pane {
        width:700
        height:500
        anchors.centerIn:parent
        
        RowLayout {
            anchors.fill:parent
            ColumnLayout {
                Text {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    text: "Language"
                }
                QQC2.Frame {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 300
                    
                    ListView {
                        id: layoutsView
                        //Layout.fillWidth: true
                        //Layout.fillHeight: true
                        anchors.fill:parent
                        
                        highlightFollowsCurrentItem: true
                        
                        model: langs
                        
                        delegate: Kirigami.BasicListItem {
                            label: displayName + ": " + name
                        }
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    text: "Layout"
                }
                QQC2.ComboBox {
                    Layout.preferredWidth: 200
                    model: ["es","en"]
                }
        
            }
            QQC2.Pane {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill:parent
                    //Layout.fillWidth: true
                    //Layout.fillHeight: true
                    //Layout.alignment: Qt.AlignBottom
                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: "Welcome to Lliurex 21 live"
                    }
                    
                    QQC2.Button {
                        Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                        text: "Ok"
                    }
                }
            }
            
        }
    }
}

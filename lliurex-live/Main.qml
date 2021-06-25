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

import Lliurex.Locale 1.0 as LLX
import Edupals.N4D 1.0 as N4D

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as Sddm
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.16 as Kirigami
Kirigami.BasicThemeDefinition{
Rectangle {
    id: theme
    
    property variant geometry: screenModel.geometry(screenModel.primary)
    x: geometry.x
    y: geometry.y
    width: geometry.width
    height: geometry.height
    
    color: "#2980b9"
    
    property var call0: 0;
    property var call1: 0;
    
    N4D.Client {
        id: n4dLocal
        address: "https://localhost:9779"
        credential: N4D.Client.LocalKey
    }
    
    N4D.Proxy {
        id: n4d_set_locale
        client: n4dLocal
        plugin: "LocaleManager"
        method: "set_locale"
        
        onError: {
            console.log(what);
            call0 = -1;
        }
        
        onResponse: {
            call0 = 1;
        }
    }
    
    N4D.Proxy {
        id: n4d_set_keyboard
        client: n4dLocal
        plugin: "LocaleManager"
        method: "set_keyboard"
        
        onError: {
            console.log(what);
            call1 = -1;
        }
        
        onResponse: {
            call1 = 1;
        }
    }
    
    LLX.Locale {
        id: llx
    }
    
    Timer {
        id: timer
        interval:500
        repeat: true
        
        onTriggered: {
            
            if (call0 == -1 || call1 == -1) {
                stop();
                btnOk.enabled=true;
            }
            
            if (call0 == 1 && call1 == 1) {
                console.log("log in...");
                sddm.login("lliurex","",0);
            }
        }
    }
    
    QQC2.Pane {
        id: paneMain
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
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 300
                    
                    ListView {
                        id: languagesView
                        //Layout.fillWidth: true
                        //Layout.fillHeight: true
                        anchors.fill:parent
                        
                        highlightFollowsCurrentItem: true
                        
                        model: llx.languagesModel
                        
                        delegate: Kirigami.BasicListItem {
                            label: modelData.longName
                        }
                        
                        onCurrentIndexChanged: {
                            var tmp = model[currentIndex].name;
                            var lang = tmp.split("_")[0];
                            console.log("lang:",tmp);
                            console.log("lang:",lang);
                            
                            var x = llx.findBestLayout(tmp);
                            console.log("find:",x);
                            
                            for (var n=0;n<llx.layoutsModel.length;n++) {
                                //console.log(llx.layoutsModel[n].name);
                                if (llx.layoutsModel[n].name==x) {
                                    cmbLayout.currentIndex = n;
                                    break;
                                }
                            }
                            
                        }
                        
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    text: "Layout"
                }
                QQC2.ComboBox {
                    id: cmbLayout
                    Layout.preferredWidth: 250
                    model: llx.layoutsModel
                    
                    displayText: model[currentIndex].longName
                    
                    delegate: Kirigami.BasicListItem {
                        label: modelData.longName
                    }
                    
                }
        
            }
            QQC2.Pane {
                Layout.preferredWidth: 300
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
                    
                    RowLayout {
                        Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                        
                        QQC2.Button {
                            Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
                            text: "Shutdown"
                            
                            onClicked: {
                                paneMain.visible=false;
                                paneShutdown.visible=true;
                            }
                        }
                        QQC2.Button {
                            id: btnOk
                            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                            text: "Ok"
                            
                            onClicked: {
                                btnOk.enabled=false;
                                
                                console.log("setting environment...");
                                console.log(llx.languagesModel[languagesView.currentIndex].name);
                                console.log(llx.layoutsModel[cmbLayout.currentIndex].name);
                                
                                call0 = 0;
                                call1 = 0;
                                
                                n4d_set_locale.call([llx.languagesModel[languagesView.currentIndex].name]);
                                var tmp = llx.layoutsModel[cmbLayout.currentIndex].name.split(":");
                                n4d_set_keyboard.call([tmp[0],tmp[1]]);
                                
                                timer.start();
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    QQC2.Pane {
        id: paneShutdown
        visible:false
        width:400
        height:200
        anchors.centerIn:parent
        
        ColumnLayout {
            anchors.fill:parent
            
            RowLayout {
                Layout.fillWidth:true
                Layout.fillHeight:true
                
                Layout.alignment: Qt.AlignCenter
                
                QQC2.Button {
                    text: "Power off"
                    
                    enabled:sddm.canPowerOff
                        onClicked: {
                            sddm.powerOff()
                        }
                }
                
                QQC2.Button {
                    text: "Reboot"
                    
                    enabled: sddm.canReboot
                        onClicked: {
                            sddm.reboot()
                        }
                }
                
            }
            
            QQC2.Button {
                Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                text: "cancel"
                
                onClicked: {
                    paneMain.visible=true;
                    paneShutdown.visible=false;
                }
            }
        }
    }
}
}

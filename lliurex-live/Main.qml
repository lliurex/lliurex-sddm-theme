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

import net.lliurex.locale 1.0 as Locale
import net.lliurex.ui 1.0 as LLX
import Edupals.N4D 1.0 as N4D

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as Sddm
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.20 as Kirigami

import org.kde.breeze as Breeze

Item {
    id: theme
    
    property string lliurexType:""
    property string lliurexFullVersion:""
    property string lliurexVersion:""
    
    property variant geometry: screenModel.geometry(screenModel.primary)
    x: geometry.x
    y: geometry.y
    width: geometry.width
    height: geometry.height
    
    property var call0: 0;
    property var call1: 0;
    
    property var plasmaIndex: 0;
    
    property var ts : [ 
    //      0           1                       2                   3       4       5           6   
    ["C",["Language","Keyboard layout","Welcome to LliureX 25 live","Ok","Cancel","Shutdown","Reboot"]],
    ["ca_ES.UTF-8@valencia",["Idioma","Teclat","Benvingut a LliureX 25 live","Accepta","Cancel·la","Atura","Reinicia"]] ,
    ["es_ES.UTF-8",["Lenguaje","Teclado","Bienvenido a LliureX 25 live","Aceptar","Cancelar","Apagar","Reiniciar"]],
    ["ca_ES.UTF-8",["Idioma","Teclat","Benvingut a LliureX 25 live","Accepta","Cancel·la","Atura","Reinicia"]] ,
        ];
    property var strings : ts[0][1];
    
    function retranslate(lang) {
        var index = -1;
        for (var n=0;n<ts.length;n++) {
            //console.log(ts[n][0]," versus ",lang);
            if (ts[n][0]===lang) {
                index=n;
                break;
            }
        }
        
        if (index == -1) {
            //try again
            var index = -1;
            for (var n=0;n<ts.length;n++) {
                //console.log(ts[n][0]," versus ",lang);
                if (ts[n][0].substring(0,2)===lang.substring(0,2)) {
                    index=n;
                    break;
                }
            }
        }
        
        if (index == -1) {
            index = 0;
        }

        var tmp = []
        for (var n=0;n<ts[index][1].length;n++) {
            tmp.push(ts[index][1][n]);
        }
        
        strings = tmp;
    }
    
    Component.onCompleted: {
        lliurex_version.call([]);
        
        for (var n=0;n<sessionModel.rowCount();n++) {
            var name = sessionModel.data(sessionModel.index(n,0),Qt.UserRole+4);
            if (name==="Plasma (Wayland)") {
                plasmaIndex=n;
            }
        }
    }
    
    N4D.Client {
        id: n4dLocal
        address: "https://localhost:9779"
        user: "sddm"
        credential: N4D.Client.LocalKey
    }
    
    N4D.Client {
        id: n4dLocalAnonymous
        address: "https://localhost:9779"
    }
    
    N4D.Proxy
    {
        id: lliurex_version
        client: n4dLocalAnonymous
        plugin: "LliurexVersion"
        method: "lliurex_version"
        
        onError: {
            console.log("failed to request lliurex version");
            theme.lliurexType="unknown";
        }
        
        onResponse: {
            console.log("version:",value);
            
            theme.lliurexFullVersion=value;
            var tmp = value.split(",");
            theme.lliurexVersion = tmp[tmp.length-1];
            
            theme.lliurexType="unknown";
            for (var n=0;n<tmp.length;n++) {
                if (tmp[n]==="client" || tmp[n]==="client-lite") {
                    theme.lliurexType="client";
                }
            }
            
            console.log("Lliurex type:",theme.lliurexType);
            
        }
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
    
    Locale.Locale {
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
                stop();
                sddm.login("lliurex","",plasmaIndex);
            }
        }
    }
    
    LLX.Background {

        anchors.fill: parent
        isWallpaper:false
        rats:false
        
    }
    
    LLX.Window {
        id: paneMain
        width:700
        height:500
        title: "LliureX 25 Live"
        focus: true
        anchors.centerIn:parent
        
        RowLayout {
            anchors.fill:parent
            spacing: 12
            
            ColumnLayout {
                spacing: 12
                
                RowLayout {
                    Layout.alignment: Qt.AlignCenter
                    
                    Kirigami.Icon {
                        source:"folder-language"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                    }
                    
                    PC3.Label {
                        //Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        text: strings[0]
                    }
                }
                
                QQC2.Frame {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 300
                    padding: 24
                    focus: true
                    //activeFocusOnTab: true

                    ListView {
                        id: languagesView
                        anchors.fill:parent
                        focus: true

                        highlightFollowsCurrentItem: true
                        activeFocusOnTab: true

                        model: llx.languagesModel

                        delegate: QQC2.ItemDelegate {
                            text: modelData.longName
                            highlighted: (languagesView.currentIndex == index)
                            MouseArea {
                                anchors.fill: parent
                                onClicked: languagesView.currentIndex = index
                            }
                        }

                        onCurrentIndexChanged: {
                            var tmp = model[currentIndex].name;
                            var lang = tmp.split("_")[0];

                            var x = llx.findBestLayout(tmp);

                            for (var n=0;n<llx.layoutsModel.length;n++) {
                                //console.log(llx.layoutsModel[n].name);
                                if (llx.layoutsModel[n].name==x) {
                                    cmbLayout.currentIndex = n;
                                    break;
                                }
                            }

                            retranslate(model[currentIndex].name);
                        }
                    }
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignCenter
                    
                    Kirigami.Icon {
                        source: "input-keyboard"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                    }
                    
                    PC3.Label {
                        //Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        text: strings[1]
                    }
                }
                PC3.ComboBox {
                    id: cmbLayout
                    Layout.preferredWidth: 300
                    model: llx.layoutsModel
                    
                    displayText: model[currentIndex].longName
                    
                    delegate: QQC2.MenuItem {
                        text: modelData.longName
                        highlighted: cmbLayout.highlightedIndex === index
                        hoverEnabled: cmbLayout.hoverEnabled
                    }
                    
                }
        
            }
            
            ColumnLayout {
                //anchors.fill:parent
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 400
                
                Layout.alignment:Qt.AlignRight | Qt.AlignBottom
                
                Item {
                    height:100
                }
                
                PC3.Label {
                    Layout.alignment: Qt.AlignCenter
                    text: strings[2]
                }
                
                Kirigami.Icon {
                    Layout.alignment: Qt.AlignCenter
                    source: "drive-removable-media"
                    implicitWidth : 128
                    implicitHeight: 128
                }
                
                PC3.Label {
                    Layout.alignment: Qt.AlignCenter
                    //text: theme.lliurexType+":"+theme.lliurexVersion
                    text: theme.lliurexFullVersion
                }
                
                Item {
                    Layout.fillHeight: true
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    
                    PC3.Button {
                        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
                        text: strings[5]
                        icon.name: "system-shutdown"
                        display: QQC2.AbstractButton.TextBesideIcon
                        width: Kirigami.Units.gridUnit*6
                        
                        onClicked: {
                            paneMain.visible=false;
                            paneShutdown.visible=true;
                        }
                    }
                    PC3.Button {
                        id: btnOk
                        Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                        text: strings[3]
                        icon.name: "dialog-ok"
                        display: QQC2.AbstractButton.TextBesideIcon
                        width: Kirigami.Units.gridUnit*6
                        
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
    
    LLX.Window {
        id: paneShutdown
        visible:false
        width:300
        height:180
        title: strings[5]
        
        anchors.centerIn:parent
        
        ColumnLayout {
            anchors.fill:parent
            
            RowLayout {
                Layout.fillWidth:true
                Layout.fillHeight:true
                
                Layout.alignment: Qt.AlignCenter
                
                PC3.Button {
                    text: strings[5]
                    icon.name: "system-shutdown"
                    display: QQC2.AbstractButton.TextUnderIcon
                    width: Kirigami.Units.gridUnit*6
                    
                    enabled:sddm.canPowerOff
                        onClicked: {
                            sddm.powerOff()
                        }
                }
                
                PC3.Button {
                    text: strings[6]
                    
                    icon.name: "system-reboot"
                    display: QQC2.AbstractButton.TextUnderIcon
                    width: Kirigami.Units.gridUnit*6
                    
                    enabled: sddm.canReboot
                        onClicked: {
                            sddm.reboot()
                        }
                }
                
            }
            
            PC3.Button {
                Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                text: strings[4]
                width: Kirigami.Units.gridUnit*6
                icon.name: "dialog-cancel"
                display: QQC2.AbstractButton.TextBesideIcon
                        
                onClicked: {
                    paneMain.visible=true;
                    paneShutdown.visible=false;
                }
            }
        }
    }
}

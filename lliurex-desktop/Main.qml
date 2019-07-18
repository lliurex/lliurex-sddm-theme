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
import SddmComponents 2.0 as Sddm
import "ui" as Lliurex

Rectangle {
    
    id: theme
    property int checkTime:0
    property int programmedCheck:0
    property bool loginStatus: true
    property bool serverStatus: true
    
    property variant geometry: screenModel.geometry(screenModel.primary)
    x: geometry.x
    y: geometry.y
    width: geometry.width
    height: geometry.height
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Sddm.TextConstants { id: textConstants }
    
    /* catch login events */
    Connections {
        target: sddm
        
        onLoginSucceeded: {
            theme.loginStatus=true;
            
            message.text=""
        }
        
        onLoginFailed: {
            theme.loginStatus=false;
            
            txtPass.text = ""
            txtPass.focus = true
            
            txtPass.borderColor="red"
        }
    }
    
    Sddm.Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }
    
    function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if(myxhr.readyState === 4) { callback(myxhr); }
            }
        })(xhr);

        xhr.open("GET", url);
        xhr.send();
    }
    
    /* Clock refresh timer */
    Timer {
        id: timerClock
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            txtDate.text = Qt.formatDateTime(new Date(), "ddd d MMMM yyyy");
            txtClock.text = Qt.formatDateTime(new Date(), "HH:mm");
            
            theme.checkTime+=timerClock.interval
            
            if (config.classroom === 'true'  && theme.programmedCheck>=0 && theme.checkTime>=theme.programmedCheck) {
                
                // avoid trigger another server check
                theme.programmedCheck=-1;
                
                request(config.server, function (o) {
                    if (o.status === 200) {
                        console.log("Connected to server!");
                        // two minutes
                        theme.serverStatus=true;
                        theme.programmedCheck=theme.checkTime+120000;
                    }
                    else {
                        console.log("Some error has occurred");
                        
                        //program another check in 5 seconds
                        theme.serverStatus=false;
                        theme.programmedCheck=theme.checkTime+5000;
                    }
                    });
            }
        }
    }

    /* Clock aand date */
    Column {
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        x: parent.width*0.7
        
        visible: (theme.width>=1024)
        
        Text {
            id: txtHostname
            text: sddm.hostName
            anchors.horizontalCenter: parent.horizontalCenter
            
            color:"white"
            font.pointSize: 32
            style:Text.Outline
            styleColor: "#40000000"
        }
        
        Text {
            id: txtDate
            text: "--"
            anchors.horizontalCenter: parent.horizontalCenter
            
            color:"white"
            font.pointSize: 32
            style:Text.Outline
            styleColor: "#40000000"
        }
        
        Text {
            id: txtClock
            text: "--"
            anchors.horizontalCenter: parent.horizontalCenter
            
            color:"white"
            font.pointSize: 96
            style:Text.Outline
            styleColor: "#40000000"
        }
    }
    
    Image {
        source: "images/shutdown.svg"
        
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin:40
        anchors.bottomMargin: 40
        
        MouseArea {
            anchors.fill: parent
            
            acceptedButtons: Qt.LeftButton
            
            onClicked: {
                loginFrame.visible=false
                shutdownFrame.visible=true
            }
        }
    }
    
    /* login frame */
    Item {
        id: loginFrame
        width: loginShadow.width
        height: loginShadow.height
        
        x: (theme.width>=1024) ? (200) : ((theme.width*0.5)-(width*0.5))
        
        anchors.verticalCenter: theme.verticalCenter
        
        Rectangle {
            id: loginShadow
            color: "#40000000"
            
            width: loginTop.width+6
            height: loginTop.height+6
            radius:5
            
            anchors.horizontalCenter: loginTop.horizontalCenter
            anchors.verticalCenter: loginTop.verticalCenter
        }
        
        Rectangle {
            id: loginTop
            color: "#eff0f1"
            radius: 5
            width: 400
            height: 400
            
            Column {
                
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                
                Image {
                    source: "images/lliurex.svg"
                }
                
                Rectangle {
                    color: "#7f8c8d"
                    height: 5
                    width: 320
                }
                
                TextField {
                    id: txtUser
                    width: 200
                    placeholderText: qsTr("User name")
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    onEditingFinished: theme.loginStatus=true;
                }
                
                TextField {
                    id: txtPass
                    width: 200
                    echoMode: TextInput.Password
                    placeholderText: qsTr("Password")
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Keys.onReturnPressed: {
                        sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex)
                    }
                    
                    Image {
                        source: "images/upcase.svg"
                        anchors.right: parent.right
                        anchors.rightMargin:5
                        anchors.verticalCenter: parent.verticalCenter
                        
                        visible: keyboard.capsLock
                    }
                }
                
                Text {
                    id: message
                    color: "red"
                    height: 32

                    text: (theme.loginStatus==false) ? qsTr("Login failed") : ((theme.serverStatus==false) ? qsTr("No connection to server") : "")
                    
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Lliurex.Button {
                    text: qsTr("Login");
                    minWidth: 200
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    onClicked: {
                        sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex)
                    }
                }
                
                ComboBox {
                    id: cmbSession
                    flat: true
                    anchors.left:parent.left
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    textRole: "name"
                    
                    indicator: Item {}
                    
                    Component.onCompleted: {
                        
                        for (var n=0;n<count;n++) {
                            var index=model.index(n,0)
                            /*
                             * Ok, lets explain this crap
                             * Role is an enum (integer) with quite a
                             * bit of predefined role types. 0x0100 is the equivalent
                             * for Qt::UserRole, from the docs:
                             * The first role that can be used for application-specific purposes.
                             * 
                             * The +4 is the "name" offset
                             * 
                             * Warning! this may break easily!
                            */
                            var name=model.data(index,0x0100+4)
                            
                            if (name==="Plasma") {
                                currentIndex=n
                            }
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
    /* Shutdown frame */
    Item {
        id: shutdownFrame
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
            
         Rectangle {
            color: "#40000000"
            
            width: shutdownTop.width+5
            height: shutdownTop.height+5
            radius:5
            
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Rectangle {
            id: shutdownTop
            color: "#eff0f1"
            width: 480
            height: 180
            
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            
            Column {
                spacing: 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                
                Row {
                    spacing: 10
                    
                    Lliurex.Button {
                        text: qsTr("Power off")
                        enabled:sddm.canPowerOff
                        onClicked: {
                            sddm.powerOff()
                        }
                    }
                    
                    Lliurex.Button {
                        text: qsTr("Reboot")
                        enabled: sddm.canReboot
                        onClicked: {
                            sddm.reboot()
                        }
                    }
                    
                    Lliurex.Button {
                        text: qsTr("Suspend")
                        enabled: sddm.canSuspend
                        onClicked: {
                            sddm.suspend()
                        }
                    }
                    
                    Lliurex.Button {
                        text: qsTr("Hibernate")
                        enabled: sddm.canHibernate
                        onClicked: {
                            sddm.hibernate()
                        }
                    }
                }

                Lliurex.Button {
                    text: qsTr("Cancel")
                    anchors.right: parent.right
                    onClicked: {
                        loginFrame.visible=true
                        shutdownFrame.visible=false
                    }
                }
                
            }
            
        }
    }
    
}

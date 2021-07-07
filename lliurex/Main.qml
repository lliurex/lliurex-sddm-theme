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

import "ui" as Lliurex

import Edupals.N4D 1.0 as N4D
import Lliurex.Noise 1.0 as Noise

import SddmComponents 2.0 as Sddm
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.16 as Kirigami

import QtQuick 2.6
import QtQuick.Controls 2.6 as QQC2
import QtQuick.Layouts 1.15

Rectangle {
    
    id: theme
    property int checkTime:0
    property int programmedCheck:0
    property bool loginStatus: true
    property bool serverStatus: true
    
    property string lliurexVersion: ""
    property string lliurexType: ""
    
    //property bool compact: (loginFrame.width+dateFrame.width+60) > theme.width
    
    property variant geometry: screenModel.geometry(screenModel.primary)
    x: geometry.x
    y: geometry.y
    width: geometry.width
    height: geometry.height
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Sddm.TextConstants { id: textConstants }
    
    N4D.Client
    {
        id: n4dLocal
        address: "https://localhost:9779"
        credential: N4D.Client.Anonymous
    }
    
    N4D.Client
    {
        id: n4dServer
        address: "https://server:9779"
        credential: N4D.Client.Anonymous
    }

    N4D.Proxy
    {
        id: local_lliurex_version
        client: n4dLocal
        plugin: "LliurexVersion"
        method: "lliurex_version"
        
        onError: {
            console.log("failed to request lliurex version");
            theme.lliurexType="unknown";
        }
        
        onResponse: {
            if (value[0]==true) {
                var version = value[1];
                theme.lliurexVersion=version;
                var tmp = version.split(",");
                console.log(tmp);
                
                theme.lliurexType="unknown";
                for (var n=0;n<tmp.length;n++) {
                    if (tmp[n]==="client" || tmp[n]==="client-lite") {
                        theme.lliurexType="client";
                    }
                }
                
                console.log("Lliurex type:",theme.lliurexType);
                
                widgetHost.version=theme.lliurexVersion;
                widgetHost.type=theme.lliurexType;
            }
            
        }
    }
    
    N4D.Proxy
    {
        id: server_lliurex_version
        client: n4dServer
        plugin: "LliurexVersion"
        method: "lliurex_version"
        
        onError: {
            theme.serverStatus=false;
            theme.programmedCheck=3000;
        }
        
        onResponse: {
            console.log("server:",value);
            theme.serverStatus=true;
        }
    }
    
    Component.onCompleted: {
        console.log("looking for lliurex version...");
        local_lliurex_version.call([]);
    }
    
    /* catch login events */
    Connections {
        target: sddm
        
        function onLoginSucceeded() {
            theme.loginStatus=true;
            loginFrame.enabled=true;
            message.text="";
        }
        
        function onLoginFailed() {
            theme.loginStatus=false;
            loginFrame.enabled=true;
            txtPass.text = "";
            txtPass.focus = true;
        }
    }
    
    Rectangle {
        anchors.fill: parent
        //color: "#3498db"
        color: "#2980b9"
        
        Noise.UniformSurface
        {
            opacity: 0.025
            
            anchors.fill: parent
            
            //frequency:0.01
            //depth:4
        }
    }
    
    /* Clock refresh timer */
    Timer {
        id: timerClock
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            
            var date = Qt.formatDateTime(new Date(), "ddd d MMMM yyyy");
            var time = Qt.formatDateTime(new Date(), "HH:mm");
            widgetClock.date = date;
            widgetClock.time = time;
            
            theme.checkTime+=timerClock.interval;
            
            if (theme.lliurexType=="client"  && theme.programmedCheck>=0 && theme.checkTime>=theme.programmedCheck) {
                
                // avoid trigger another server check
                theme.programmedCheck=-1;
                console.log("checking server...")
                server_lliurex_version.call([])
            }
        }
    }
    
    /* user frame */
    Lliurex.Window {
        id: userFrame
        visible: false
        title: "User selection"
        width: theme.width*0.8
        height: theme.height*0.8
            
        anchors.centerIn: parent
        
        Lliurex.UserGrid {
            //anchors.fill : parent
            width:parent.width*0.95
            height:parent.height*0.95
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            
            model: userModel
            focus: true
            
            onCancel: {
                userFrame.visible = false
                loginFrame.visible = true
            }
            
            onSelected: {
                userFrame.visible = false
                loginFrame.visible = true
                txtUser.text = name
                txtPass.focus = true
            }
        }
    }
    
    /* login frame */
    Lliurex.Window {
        id: loginFrame
        width: 400
        height: 340
        visible: true
        margin:24
        
        //x: theme.compact ? ((theme.width*0.5)-(width*0.5)) : ((dateFrame.x-width)<200 ? (dateFrame.x-width) : 200)
        
        anchors.centerIn: parent
        
        ColumnLayout {
            id: loginColumn
            spacing: 8
            anchors.fill: parent
            
            Image {
                source: "images/lliurex.svg"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                color: "#7f8c8d"
                height: 5
                width: 320
                Layout.alignment: Qt.AlignHCenter
            }
            
            Item {
                Layout.fillHeight:true
            }
            
            RowLayout {
                //anchors.horizontalCenter: parent.horizontalCenter
                //anchors.right: btnLogin.right
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                
                Rectangle {
                    id: btnUserSelector
                    color: "transparent"
                    width:imgUsername.width
                    height: imgUsername.height
                    //anchors.verticalCenter: parent.verticalCenter
                    
                    Image {
                        id: imgUsername
                        source: "images/username.svg"
                        
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onEntered: {
                            parent.border.color= "#3daee9"
                            parent.border.width=1
                        }
                        onExited: {
                            parent.border.color= "transparent"
                            parent.border.width=0

                        }
                        
                        onClicked: {
                            if (mouse.button == Qt.LeftButton) {
                                loginFrame.visible=false
                                userFrame.visible=true
                            }
                        }
                    }
                }
                
                QQC2.TextField {
                    id: txtUser
                    width: 200
                    placeholderText: i18nd("lliurex-sddm","User name")
                    //anchors.verticalCenter: parent.verticalCenter
                    //anchors.horizontalCenter: parent.horizontalCenter
                    onEditingFinished: {
                        theme.loginStatus=true
                        txtPass.focus=true
                    }
                    //palette.highlight: "#3daee9"
                    
                    Component.onCompleted: focus=true;
                    
                }
                
                Item {
                    width: btnUserSelector.width
                }
            }
            
            RowLayout {
                //anchors.horizontalCenter: parent.horizontalCenter
                //anchors.right: btnLogin.right
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                
                Image {
                    id: imgPassword
                    source: "images/password.svg"
                    //anchors.verticalCenter: parent.verticalCenter
                }
                
                QQC2.TextField {
                    id: txtPass
                    width: 200
                    echoMode: TextInput.Password
                    placeholderText: i18nd("lliurex-sddm","Password")
                    //anchors.horizontalCenter: parent.horizontalCenter
                    //anchors.verticalCenter: parent.verticalCenter
                    //palette.highlight: "#3daee9"
                    
                    Keys.onReturnPressed: {
                        loginFrame.enabled=false
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
                
                Item {
                    width: imgPassword.width
                }
            }
            
            Item {
                Layout.fillWidth:true;
                height:32
                
                Kirigami.InlineMessage {
                    id: message
                    anchors.fill:parent
                    type: Kirigami.MessageType.Error
                    //width:parent.width
                    
                    
                    text: (theme.loginStatus==false) ? i18nd("lliurex-sddm","Login failed") : ((theme.serverStatus==false) ? i18nd("lliurex-sddm","No connection to server") : "")
                    
                    visible: text.length>0
                }
            }
            
            QQC2.Button {
                id: btnLogin
                text: i18nd("lliurex-sddm","Login");
                implicitWidth: 200
                //anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignHCenter
                
                onClicked: {
                    loginFrame.enabled=false
                    sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex)
                }
            }
            
        }
        

        /* Guest User Panels */
/*
        Item {
                width: loginTop.width
                height: loginTop.height
                anchors.bottom: loginTop.bottom
                anchors.right: loginTop.right
                visible: {
                        var x=false
                        for (var n=0;n< userModel.count;n++) {
                                var index=userModel.index(n,0);
                                var name=userModel.data(index,0x0100+1);
                                if ( name === "guest-user" )
                                {
                                        x=true
                                        break
                                }
                        }
                        return x

                }

                Rectangle {
                        id: guestImageHighlight
                        width: guestImage.width+2
                        height: guestImage.height+2
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: 30
                        anchors.bottomMargin: 30
                        border.color:"#3daee9"
                        border.width:0
                        color:"transparent"
                }

                Text {
                        id: tooltipGuest
                        text:  i18nd("lliurex-sddm","Guest User")
                        visible: false
                        color: "#3daee9"
                        anchors.verticalCenter: guestImage.verticalCenter
                        anchors.right: guestImage.left
                        anchors.rightMargin: 10
                }

                Image {
                        id: guestImage
                        source: "images/guest_32.svg"
                        anchors.horizontalCenter: guestImageHighlight.horizontalCenter
                        anchors.verticalCenter: guestImageHighlight.verticalCenter

                        MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton

                                onEntered: {
                                        tooltipGuest.visible = true
                                        guestImageHighlight.border.width=1
                                }

                                onExited: {
                                        tooltipGuest.visible = false
                                        guestImageHighlight.border.width=0
                                }

                                onClicked: {
                                        if (loginColumn.visible) {
                                                loginColumn.visible = false
                                                guestLoginRectangle.visible = true
                                                parent.source= "images/go-back.svg"
                                                tooltipGuest.text = i18nd("lliurex-sddm","Go back")
                                        }
                                        else {
                                                loginColumn.visible = true
                                                guestLoginRectangle.visible = false
                                                parent.source= "images/guest_32.svg"
                                                tooltipGuest.text = i18nd("lliurex-sddm","Guest User")
                                        }
                                }
                        }

                }

                Item {
                        id: guestLoginRectangle
                        width: loginColumn.width
                        height: loginColumn.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        Image {
                                id: guestLogo
                                source: "images/guest.svg"
                                anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                                id: guestTitle
                                text: i18nd("lliurex-sddm","Guest User")
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: guestLogo.bottom
                                anchors.topMargin: 5
                                 font.pointSize: 18
                        }

                        Text {
                                id: guestDescription
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignJustify
                                width:300
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: guestTitle.bottom
                                anchors.topMargin: 5
                                text: i18nd("lliurex-sddm","Access this computer using a guest account. Everything stored with this account will be deleted after you log out.")
                                font.pointSize: 10
                                color: "#444444"
                        }

                        Lliurex.Button {
                                id: guestLoginButton
                                text: i18nd("lliurex-sddm","Enter")
                                width: 250
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: guestDescription.bottom
                                anchors.topMargin: 25

                                onClicked: {
                                        loginFrame.enabled=false
                                        sddm.login("guest-user","",cmbSession.currentIndex)
                                }
                        }
                }
        } // Guest Panels
        */
    }
    
    /* Shutdown frame */
    Lliurex.Window {
        id: shutdownFrame
        title: "Shutdown"
        visible: false
        anchors.centerIn: parent
        
        width: 460
        height: 200
            
        Column {
            spacing: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            
            Row {
                spacing: 10
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Power off")
                    enabled:sddm.canPowerOff
                    onClicked: {
                        sddm.powerOff()
                    }
                }
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Reboot")
                    enabled: sddm.canReboot
                    onClicked: {
                        sddm.reboot()
                    }
                }
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Suspend")
                    enabled: sddm.canSuspend
                    onClicked: {
                        sddm.suspend()
                    }
                }
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Hibernate")
                    enabled: sddm.canHibernate
                    onClicked: {
                        sddm.hibernate()
                    }
                }
            }

            QQC2.Button {
                text: i18nd("lliurex-sddm","Cancel")
                anchors.right: parent.right
                onClicked: {
                    loginFrame.visible=true
                    shutdownFrame.visible=false
                }
            }
            
        }
        
    }
    
    QQC2.Pane {
        
        padding:2
        width:parent.width
        height:50
        
        x:0
        y:parent.height-height
        
        RowLayout {
            anchors.fill: parent
            spacing: 12
            
            QQC2.ComboBox {
                id: cmbSession
                flat: true
                
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                //palette.highlight: "#3daee9"
                
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
                        var name=model.data(index,Qt.UserRole+4)
                        
                        if (name==="Plasma (X11)") {
                            currentIndex=n
                        }
                    }
                    
                }
                    
            }
            
            Item {
                Layout.fillWidth:true
            }
            
            QQC2.Label {
                id: widgetHost
                property string version:""
                property string type:""
                Layout.alignment: Qt.AlignCenter
                
                text: sddm.hostName + " "+version+" "+type
                
            }
            
            ColumnLayout {
                id: widgetClock
                Layout.alignment: Qt.AlignRight
                
                property alias time: wTime.text
                property alias date: wDate.text
                
                QQC2.Label {
                    id: wTime
                    Layout.alignment: Qt.AlignCenter
                }
                QQC2.Label {
                    id: wDate
                    Layout.alignment: Qt.AlignCenter
                }
            }
            
            QQC2.Button {
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 40
                flat:true
                
                icon.name: "system-shutdown"
                icon.width:32
                
                onClicked: {
                    loginFrame.visible=false
                    userFrame.visible=false
                    shutdownFrame.visible=true
                }
            }
        }
    }
    
}

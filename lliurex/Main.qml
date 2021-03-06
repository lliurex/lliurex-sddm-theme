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
            console.log("version:",value);
            
            theme.lliurexVersion=value;
            var tmp = value.split(",");
            
            theme.lliurexType="unknown";
            for (var n=0;n<tmp.length;n++) {
                if (tmp[n]==="client" || tmp[n]==="client-lite") {
                    theme.lliurexType="client";
                }
            }
            
            console.log("Lliurex type:",theme.lliurexType);
            
        }
    }
    
    N4D.Proxy
    {
        id: server_lliurex_version
        client: n4dServer
        plugin: "LliurexVersion"
        method: "lliurex_version"
        
        onError: {
            message.type=Kirigami.MessageType.Warning;
            message.text=i18nd("lliurex-sddm","No connection to server");
            message.visible=true;
            theme.programmedCheck=3000;
        }
        
        onResponse: {
            console.log("server:",value);
            message.visible=false;
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
            
            loginFrame.enabled=true;
            message.visible=false;
        }
        
        function onLoginFailed() {
            message.type=Kirigami.MessageType.Error;
            message.text=i18nd("lliurex-sddm","Login failed");
            message.visible=true;
            
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
        
    }
    
    /* guest frame */
    Lliurex.Window {
        id: guestFrame
        width: 400
        height: 340
        visible: false
        margin:24
        title: i18nd("lliurex-sddm","Guest User")
        anchors.centerIn: parent
        
        ColumnLayout {
            anchors.fill:parent
            
            Image {
                Layout.alignment: Qt.AlignCenter
                source: "images/guest.svg"
            }
            
            QQC2.Label {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth:true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignJustify
                
                text: i18nd("lliurex-sddm","Access this computer using a guest account. Everything stored with this account will be deleted after you log out.")
                
            }
            
            QQC2.Button {
                Layout.alignment: Qt.AlignCenter
                text: i18nd("lliurex-sddm","Enter")
                implicitWidth: PlasmaCore.Units.gridUnit*6
                
                onClicked: {
                    guestFrame.enabled=false;
                    sddm.login("guest-user","",cmbSession.currentIndex)
                }
            }
            
            Item {
                implicitHeight:PlasmaCore.Units.gridUnit*2
            }
            
            QQC2.Button {
                text: i18nd("lliurex-sddm","Cancel")
                implicitWidth: PlasmaCore.Units.gridUnit*6
                icon.name: "dialog-cancel"
                display: QQC2.AbstractButton.TextBesideIcon
                
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                
                onClicked: {
                    loginFrame.visible=true;
                    guestFrame.visible=false;
                }
            }
        }
    }
    
    /* Shutdown frame */
    Lliurex.Window {
        id: shutdownFrame
        title: "Shutdown"
        visible: false
        anchors.centerIn: parent
        
        width: 500
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
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-shutdown"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.powerOff()
                    }
                }
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Reboot")
                    enabled: sddm.canReboot
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-reboot"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.reboot()
                    }
                }
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Suspend")
                    enabled: sddm.canSuspend
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-suspend"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.suspend()
                    }
                }
                
                QQC2.Button {
                    text: i18nd("lliurex-sddm","Hibernate")
                    enabled: sddm.canHibernate
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-suspend-hibernate"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.hibernate()
                    }
                }
            }

            QQC2.Button {
                text: i18nd("lliurex-sddm","Cancel")
                anchors.right: parent.right
                implicitWidth: PlasmaCore.Units.gridUnit*6
                icon.name: "dialog-cancel"
                display: QQC2.AbstractButton.TextBesideIcon
                
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
            spacing: PlasmaCore.Units.largeSpacing
            
            QQC2.ComboBox {
                id: cmbSession
                //flat: true
                Layout.alignment: Qt.AlignLeft
                
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
            QQC2.Button {
                Layout.alignment: Qt.AlignLeft
                icon.source:"images/guest_32.svg"
                icon.width:24
                icon.height:24
                display: QQC2.AbstractButton.TextBesideIcon
                text: i18nd("lliurex-sddm","Guest User")
                
                visible: {
                    for (var n=0;n< userModel.count;n++) {
                        var index=userModel.index(n,0);
                        var name=userModel.data(index,Qt.UserRole+1);
                        if ( name === "guest-user" ) {
                            console.log("Guest user found");
                            return true;
                        }
                    }
                    return false;

                }
                onClicked: {
                    loginFrame.visible=false;
                    guestFrame.visible=true;
                }
            }
            
            Item {
                Layout.fillWidth:true
            }
            
            
            QQC2.Label {
                id: widgetHost
                Layout.alignment: Qt.AlignRight
                //Layout.fillWidth: true
                
                horizontalAlignment: Text.AlignHCenter
                
                text: sddm.hostName + " "+theme.lliurexVersion
                
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
                
                flat:true
                implicitWidth: 32
                icon.name: "system-shutdown"
                icon.width:32
                icon.height:32
                
                onClicked: {
                    loginFrame.visible=false
                    userFrame.visible=false
                    shutdownFrame.visible=true
                }
            }
        }
    }
    
}

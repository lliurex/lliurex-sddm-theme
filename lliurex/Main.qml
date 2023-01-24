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
import net.lliurex.ui 1.0 as LLX

import Edupals.N4D 1.0 as N4D

import SddmComponents 2.0 as Sddm
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.16 as Kirigami

import QtQuick 2.6
import QtQuick.Controls 2.6 as QQC2
import QtQuick.Layouts 1.15
import QtQuick.VirtualKeyboard 2.1

Item {
    
    id: root

    enum EscolesConectades {
        VendorEnabled = 1,
        Enabled = 2,
        Mode = 4,   // 1 Manual, 0 Auto
        Wifi = 8    // 1 Prof, 0 Alu
    }


    readonly property int autoLoginTimeout: 10000 //10 seconds

    property Item topWindow: loginFrame

    property int checkTime:0
    property int programmedCheck:0
    
    property string lliurexVersion: ""
    property string lliurexType: ""
    property int escolesLogin: 0
    property string escolesTarget: "WIFI_ALU"
    property var networks
    property int escolesStage: -1
    
    //property bool compact: (loginFrame.width+dateFrame.width+60) > theme.width
    
    property variant geometry: screenModel.geometry(screenModel.primary)
    x: geometry.x
    y: geometry.y
    width: geometry.width
    height: geometry.height
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Sddm.TextConstants { id: textConstants }
    
    function showError(msg)
    {
        message.type=Kirigami.MessageType.Error;
        message.text=msg;
        message.visible=true;
        root.topWindow = loginFrame;
    }

    function showWarning(msg)
    {
        message.type=Kirigami.MessageType.Warning;
        message.text=msg;
        message.visible=true;
        root.topWindow = loginFrame;
    }

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
            root.lliurexType="unknown";
        }
        
        onResponse: {
            console.log("version:",value);
            
            root.lliurexVersion=value;
            var tmp = value.split(",");
            
            root.lliurexType="unknown";
            for (var n=0;n<tmp.length;n++) {
                if (tmp[n]==="client" || tmp[n]==="client-lite") {
                    root.lliurexType="client";
                }
            }
            
            console.log("Lliurex type:",root.lliurexType);
            
        }
    }
    
    N4D.Proxy
    {
        id: server_lliurex_version
        client: n4dServer
        plugin: "LliurexVersion"
        method: "lliurex_version"
        
        onError: {
            showWarning(i18nd("lliurex-sddm-theme","No connection to server"));
            root.programmedCheck=3000;
        }
        
        onResponse: {
            console.log("server:",value);
            message.visible=false;
        }
    }

    N4D.Proxy
    {
        id: local_check_wired_connection
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "check_wired_connection"

        onError: {
            local_scan_network.call([]);
            // TODO: show error here?
        }

        onResponse: {
            if (value) {
                sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex);
            }
            else {
                local_scan_network.call([]);
            }
        }
    }

    N4D.Proxy
    {
        id: local_scan_network
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "scan_network"

        onError: {
            console.log("failed to retrieve networks:",what,"\n",details);
            showError(i18nd("lliurex-sddm-theme","Failed to retrieve networks"));
        }

        onResponse: {
            if ((escolesLogin & Main.EscolesConectades.Wifi) > 0) {
                escolesTarget = "WIFI_PROF"
            }
            else {
                escolesTarget = "WIFI_ALU"
            }
            console.log("Using target:",escolesTarget);
            console.log("networks:",value);
            networks = value;
            var found = false;
            for (var n in networks) {
                console.log(networks[n]);
                if (networks[n][0] == escolesTarget) {
                    found = true;
                    break;
                }
            }

            if (found) {
                escolesStage = 1;
                local_disconnect_all.call([]);
            }
            else {
                console.log("Escoles target not found!");
                showError(i18nd("lliurex-sddm-theme","Wifi network not found:") + escolesTarget);
            }
        }
    }

    N4D.Proxy
    {
        id: local_disconnect_all
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "disconnect_all"

        onError: {
            console.log("failed to turn down all connections:",what,"\n",details);
            showError(i18nd("lliurex-sddm-theme","Failed to turn down connections"));
        }

        onResponse: {
            escolesStage = 2;
            local_create_connection.call(["EscolesConectades",escolesTarget,txtUser.text,txtPass.text,""]);
        }
    }

    N4D.Proxy
    {
        id: local_create_connection
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "create_connection"
        /* name,ssid,user,password */

        onError: {
            console.log("failed to create connection:",what,"\n",details);
            showError(i18nd("lliurex-sddm-theme","Failed to create connection"));
        }

        onResponse: {
            escolesStage = 3;
            local_wait_for_domain.call([]);
        }
    }

    N4D.Proxy
    {
        id: local_get_settings
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "get_settings"

        onError: {
            console.log("Failed to get EscolesConectades settings");
        }

        onResponse: {
            escolesLogin = value;
            console.log("escolesLogin:",escolesLogin);
            console.log("VendorEnabled:", (escolesLogin & Main.EscolesConectades.VendorEnabled > 0) ? "yes" : "no" );
            console.log("Enabled:", (escolesLogin & Main.EscolesConectades.Enabled > 0) ? "yes" : "no");
            console.log("Mode:", (escolesLogin & Main.EscolesConectades.Mode > 0) ? "Manual" : "Autologin");
            console.log("Wifi:", (escolesLogin & Main.EscolesConectades.WiFi > 0) ? "WIFI_PROF" : "WIFI_ALU");
        }
    }

    N4D.Proxy
    {
        id: local_set_settings
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "set_settings"

        onError: {
            console.log("Failed to set EscolesConectades settings");
        }

        onResponse: {
        }
    }

    N4D.Proxy
    {
        id: local_wait_for_domain
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "wait_for_domain"

        onError: {
            console.log("Failed waiting to GVA domain");
        }

        onResponse: {
            escolesStage = 4;
            sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex)
        }
    }
    
    Component.onCompleted: {
        console.log("looking for lliurex version...");
        local_lliurex_version.call([]);
        //escolesLogin = n4dLocal.getVariable("SDDM_ESCOLES_CONECTADES");
        local_get_settings.call([]);
    }
    
    /* catch login events */
    Connections {
        target: sddm
        
        function onLoginSucceeded() {
            
            loginFrame.enabled=true;
            message.visible=false;
        }
        
        function onLoginFailed() {
            showError(i18nd("lliurex-sddm-theme","Login failed"));
            
            loginFrame.enabled=true;
            txtPass.text = "";
            txtPass.focus = true;
        }
    }
    
    LLX.Background {
        anchors.fill: parent
    }

    InputPanel {
        id: vkey
        width: 3.0 * ((panel.y - (topWindow.y+topWindow.height)))

        y: (topWindow.y+topWindow.height+4)

        //anchors.bottom : panel.top
        anchors.horizontalCenter: parent.horizontalCenter

        active: chkVkey.checked

        visible: active && Qt.inputMethod.visible
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
            
            root.checkTime+=timerClock.interval;
            
            if (root.lliurexType=="client"  && root.programmedCheck>=0 && root.checkTime>=root.programmedCheck) {
                
                // avoid trigger another server check
                root.programmedCheck=-1;
                console.log("checking server...")
                server_lliurex_version.call([])
            }
        }
    }

    /* setup frame */
    LLX.Window {
        id: settingsFrame
        visible: root.topWindow == this
        title: i18nd("lliurex-sddm-theme","Settings")
        width: 512
        height:512

        anchors.centerIn: parent

        ColumnLayout {
            anchors.fill: parent

            QQC2.GroupBox {
                //Layout.fillHeight:true
                Layout.fillWidth:true

                title: i18nd("lliurex-sddm-theme","Escoles Conectades")
                ColumnLayout {
                    anchors.fill: parent
                    PlasmaComponents.CheckBox {
                        id: chkEscoles
                        checked: (escolesLogin & Main.EscolesConectades.Enabled) > 0
                        text: i18nd("lliurex-sddm-theme","Enable")

                        onClicked: {
                            btnSettingsAccept.enabled = true;
                        }
                    }
                    PlasmaComponents.RadioButton {
                        id: rb1
                        enabled: chkEscoles.checked
                        checked: !((escolesLogin & Main.EscolesConectades.Wifi) > 0)
                        text: i18nd("lliurex-sddm-theme","WiFi Alumnos")

                        onClicked: {
                            btnSettingsAccept.enabled = true;
                        }
                    }
                    PlasmaComponents.RadioButton {
                        id: rb2
                        enabled: chkEscoles.checked
                        checked: (escolesLogin & Main.EscolesConectades.Wifi) > 0
                        text: i18nd("lliurex-sddm-theme","WiFi Profesores")

                        onClicked: {
                            btnSettingsAccept.enabled = true;
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight:true
            }

            RowLayout {
                Layout.fillWidth:true
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                PlasmaComponents.Button {
                    id: btnSettingsAccept
                    text: i18nd("lliurex-sddm-theme","Accept")
                    enabled: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                    onClicked: {
                        escolesLogin = Main.EscolesConectades.VendorEnabled;
                        escolesLogin = escolesLogin | chkEscoles.checked ? Main.EscolesConectades.Enabled : 0;
                        escolesLogin = escolesLogin | Main.EscolesConectades.Mode;
                        escolesLogin = escolesLogin | (rb1.checked ? Main.EscolesConectades.Wifi : 0);

                        console.log("Setting:",escolesLogin);
                        //n4dLocal.setVariable("SDDM_ESCOLES_CONECTADES",escolesLogin);
                        local_set_settings.call([escolesLogin]);
                        enabled = false;
                        root.topWindow = loginFrame;
                    }
                }

                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Cancel")
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                    onClicked: {
                        btnSettingsAccept.enabled = false;
                        root.topWindow = loginFrame;
                    }
                }
            }
        }

    }

    /* user frame */
    LLX.Window {
        id: userFrame
        visible: root.topWindow == this
        title: i18nd("lliurex-sddm-theme","User selection")
        width: 512
        height:400
            
        anchors.horizontalCenter: parent.horizontalCenter
        y: {
            if (vkey.active) {
                return (parent.height*0.3)-(height*0.5);
            }
            else {
                return (parent.height*0.5)-(height*0.5);
            }
        }
        
        Lliurex.UserGrid {
            anchors.fill : parent
            //width:parent.width*0.80
            //height:parent.height*0.80
            //anchors.horizontalCenter: parent.horizontalCenter
            //anchors.bottom: parent.bottom
            
            model: userModel
            focus: true
            
            onCancel: {
                root.topWindow = loginFrame;
            }
            
            onSelected: {
                root.topWindow = loginFrame;
                txtUser.text = name
                txtPass.focus = true
            }
        }
    }
    
    /* login frame */
    LLX.Window {
        id: loginFrame
        visible: root.topWindow == this
        width: 400
        height: 340
        margin:24
        
        //x: theme.compact ? ((theme.width*0.5)-(width*0.5)) : ((dateFrame.x-width)<200 ? (dateFrame.x-width) : 200)
        
        anchors.horizontalCenter: parent.horizontalCenter
        y: {
            if (vkey.active) {
                return (parent.height*0.3)-(height*0.5);
            }
            else {
                return (parent.height*0.5)-(height*0.5);
            }
        }
        
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
                                root.topWindow = userFrame;
                            }
                        }
                    }
                }
                
                PlasmaComponents.TextField {
                    id: txtUser
                    implicitWidth: 200
                    placeholderText: i18nd("lliurex-sddm-theme","User name")
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
                
                PlasmaComponents.TextField {
                    id: txtPass
                    implicitWidth: 200
                    echoMode: TextInput.Password
                    placeholderText: i18nd("lliurex-sddm-theme","Password")
                    //anchors.horizontalCenter: parent.horizontalCenter
                    //anchors.verticalCenter: parent.verticalCenter
                    //palette.highlight: "#3daee9"
                    
                    Keys.onReturnPressed: {
                        if ( (escolesLogin & EscolesConectades.Enabled) > 0) {
                            root.escolesStage = 0;
                            root.topWindow = escolesFrame;
                            local_check_wired_connection.call([]);
                        }
                        else {
                            loginFrame.enabled=false
                            sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex)
                        }
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
                
            PlasmaComponents.Button {
                id: btnLogin
                text: i18nd("lliurex-sddm-theme","Login");
                implicitWidth: 200
                //anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignHCenter
                
                onClicked: {
                    if (escolesLogin & EscolesConectades.Enabled > 0) {
                        root.escolesStage = 0;
                        root.topWindow = escolesFrame;
                        local_check_wired_connection.call([]);
                    }
                    else {
                        loginFrame.enabled=false;
                        sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex);
                    }
                }
            }
            
        }
        
    }

    Timer {
        id: timerAutoLogin
        running:false
        interval: 50
        repeat:true

        onTriggered: {
            progressAutoLogin.value = progressAutoLogin.value - (interval/autoLoginTimeout);

            if (progressAutoLogin.value <= 0.0) {
                stop();
                console.log("Autologin!");
            }
        }
    }

    LLX.Window {
        id: escolesAutoLoginFrame
        width: 400
        height: 340

        visible: root.topWindow == this
        margin: 24

        title: i18nd("lliurex-sddm-theme","Escoles Conectades")
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                timerAutoLogin.start();
                progressAutoLogin.value =  1.0;
            }
        }

        ColumnLayout {
            anchors.fill: parent

            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: i18nd("lliurex-sddm-theme","Login as Student in:")
            }

            PlasmaComponents.ProgressBar {
                id: progressAutoLogin
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                value: 1.0
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter | Qt.AlignBottom

                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Login");

                    onClicked: {
                        timerAutoLogin.stop();

                        // Login goes here
                    }
                }

                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Cancel");

                    onClicked: {
                        timerAutoLogin.stop();
                        root.topWindow = loginFrame;
                    }

                }
            }

        }
    }

    /* escoles login window */
    LLX.Window {
        id: escolesFrame
        width: 400
        height: 340
        visible: root.topWindow == this
        margin:24
        title: i18nd("lliurex-sddm-theme","Escoles Conectades")
        anchors.centerIn: parent

        ColumnLayout {
            anchors.fill:parent

            Lliurex.StatusLine {
                stage: 0
                currentStage: root.escolesStage
                text: i18nd("lliurex-sddm-theme","Scanning networks")
            }

            Lliurex.StatusLine {
                stage: 1
                currentStage: root.escolesStage
                text: i18nd("lliurex-sddm-theme","Turning down connections")
            }

            Lliurex.StatusLine {
                stage: 2
                currentStage: root.escolesStage
                text: i18nd("lliurex-sddm-theme","Creating connection")
            }

            Lliurex.StatusLine {
                stage: 3
                currentStage: root.escolesStage
                text: i18nd("lliurex-sddm-theme","Waiting for GVA server")
            }

            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Cancel")
                implicitWidth: PlasmaCore.Units.gridUnit*6
                icon.name: "dialog-cancel"
                display: QQC2.AbstractButton.TextBesideIcon

                Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                onClicked: {
                    root.topWindow = loginFrame;
                }
            }
        }

    }
    
    /* guest frame */
    LLX.Window {
        id: guestFrame
        width: 400
        height: 340
        visible: root.topWindow == this
        margin:24
        title: i18nd("lliurex-sddm-theme","Guest User")
        anchors.centerIn: parent
        
        ColumnLayout {
            anchors.fill:parent
            
            Image {
                Layout.alignment: Qt.AlignCenter
                source: "images/guest.svg"
            }
            
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth:true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignJustify
                
                text: i18nd("lliurex-sddm-theme","Access this computer using a guest account. Everything stored with this account will be deleted after you log out.")
                
            }
            
            PlasmaComponents.Button {
                Layout.alignment: Qt.AlignCenter
                text: i18nd("lliurex-sddm-theme","Enter")
                implicitWidth: PlasmaCore.Units.gridUnit*6
                
                onClicked: {
                    guestFrame.enabled=false;
                    sddm.login("guest-user","",cmbSession.currentIndex)
                }
            }
            
            Item {
                implicitHeight:PlasmaCore.Units.gridUnit*2
            }
            
            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Cancel")
                implicitWidth: PlasmaCore.Units.gridUnit*6
                icon.name: "dialog-cancel"
                display: QQC2.AbstractButton.TextBesideIcon
                
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                
                onClicked: {
                    root.topWindow = loginFrame;
                }
            }
        }
    }
    
    /* Shutdown frame */
    LLX.Window {
        id: shutdownFrame
        title: i18nd("lliurex-sddm-theme","Power off")
        visible: root.topWindow == this
        anchors.centerIn: parent
        
        width: 500
        height: 200
            
        Column {
            spacing: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            
            Row {
                spacing: 10
                
                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Power off")
                    enabled:sddm.canPowerOff
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-shutdown"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.powerOff()
                    }
                }
                
                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Reboot")
                    enabled: sddm.canReboot
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-reboot"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.reboot()
                    }
                }
                
                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Suspend")
                    enabled: sddm.canSuspend
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-suspend"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.suspend()
                    }
                }
                
                PlasmaComponents.Button {
                    text: i18nd("lliurex-sddm-theme","Hibernate")
                    enabled: sddm.canHibernate
                    implicitWidth: PlasmaCore.Units.gridUnit*6
                    icon.name: "system-suspend-hibernate"
                    display: QQC2.AbstractButton.TextUnderIcon
                    
                    onClicked: {
                        sddm.hibernate()
                    }
                }
            }

            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Cancel")
                anchors.right: parent.right
                implicitWidth: PlasmaCore.Units.gridUnit*6
                icon.name: "dialog-cancel"
                display: QQC2.AbstractButton.TextBesideIcon
                
                onClicked: {
                    root.topWindow = loginFrame;
                }
            }
            
        }
        
    }
    
    QQC2.Pane {
        id: panel
        padding:2
        width:parent.width
        height:50
        
        x:0
        y:parent.height-height
        
        RowLayout {
            anchors.fill: parent
            spacing: PlasmaCore.Units.largeSpacing
            
            PlasmaComponents.ComboBox {
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
            PlasmaComponents.Button {
                Layout.alignment: Qt.AlignLeft
                icon.source:"images/guest_32.svg"
                icon.width:24
                icon.height:24
                display: QQC2.AbstractButton.TextBesideIcon
                text: i18nd("lliurex-sddm-theme","Guest User")
                
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
                    root.topWindow = guestFrame;
                }
            }
            
            PlasmaComponents.Button {
                id: chkVkey
                Layout.alignment: Qt.AlignLeft
                icon.name:"input-keyboard-virtual"
                checkable: true
                display: AbstractButton.IconOnly
                icon.width:24
                icon.height:24
            }

            PlasmaComponents.Button {
                id: btnSettings
                Layout.alignment: Qt.AlignLeft
                icon.name:"system-users"
                display: AbstractButton.IconOnly
                icon.width:24
                icon.height:24
                visible: (escolesLogin & Main.EscolesConectades.VendorEnabled) > 0

                onClicked: {
                    local_get_settings.call([]);
                    root.topWindow = settingsFrame;
                }
            }

            PlasmaComponents.Button {
                id: btnEscolesAutoLogin
                Layout.alignment: Qt.AlignLeft
                icon.name:"smiley"
                display: AbstractButton.IconOnly
                icon.width:24
                icon.height:24
                visible:false //TODO

                onClicked: {

                    root.topWindow = escolesAutoLoginFrame;
                }
            }

            Item {
                Layout.fillWidth:true
            }
            
            PlasmaComponents.Label {
                id: widgetHost
                Layout.alignment: Qt.AlignRight
                
                horizontalAlignment: Text.AlignHCenter
                
                text: sddm.hostName
                
            }

            PlasmaComponents.Label {
                id: widgetVersion
                Layout.alignment: Qt.AlignRight
                
                horizontalAlignment: Text.AlignHCenter
                
                text: root.lliurexVersion
                
            }

            ColumnLayout {
                id: widgetClock
                Layout.alignment: Qt.AlignRight
                
                property alias time: wTime.text
                property alias date: wDate.text
                
                PlasmaComponents.Label {
                    id: wTime
                    Layout.alignment: Qt.AlignCenter
                }
                PlasmaComponents.Label {
                    id: wDate
                    Layout.alignment: Qt.AlignCenter
                }
            }
            
            PlasmaComponents.Button {
                Layout.alignment: Qt.AlignRight
                
                flat:true
                implicitWidth: 32
                icon.name: "system-shutdown"
                icon.width:32
                icon.height:32
                
                onClicked: {
                    root.topWindow = shutdownFrame;
                }
            }
        }
    }
    
}

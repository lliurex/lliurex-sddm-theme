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

    enum LoginMode {
        Local = 0,
        Guest,
        EscolesTeacher,
        EscolesStudent,
        AutoStudent
    }

    enum EscolesConectades {
        Disabled = 0,
        Teacher = 1,
        Student = 2,
        Auto = 3
    }

    readonly property int autoLoginTimeout: 10000 //10 seconds

    property Item topWindow: loginFrame
    property bool firstBoot: true
    property int loginMode : Main.LoginMode.Local

    property int checkTime:0
    property int programmedCheck:0
    
    property string lliurexVersion: ""
    property string lliurexType: ""

    property bool localEnabled : true
    property bool guestEnabled : false
    property bool escolesEnabled : false
    property bool escolesAutoEnabled: false

    property int escolesLogin: 0
    property int escolesLoginManual: 0
    property string escolesAutoLoginSettings: ""
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
        root.topWindow.enabled = true;
    }

    function showWarning(msg)
    {
        message.type=Kirigami.MessageType.Warning;
        message.text=msg;
        message.visible=true;
        root.topWindow = loginFrame;
        root.topWindow.enabled = true;
    }

    function login()
    {
        if (root.loginMode == Main.LoginMode.Local) {
            console.log("performing a local login...");
            sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex);
        }

        if (root.loginMode == Main.LoginMode.EscolesTeacher ||
                    root.loginMode == Main.LoginMode.EscolesStudent) {
            console.log("performing a EscolesConectades login...");
            root.escolesStage = 0;
            root.topWindow = escolesFrame;
            local_check_wired_connection.call([]);
        }

        if (root.loginMode == Main.LoginMode.Guest) {
            console.log("performing a guest login...");
            sddm.login("guest-user","",cmbSession.currentIndex)
        }

        if (root.loginMode == Main.LoginMode.AutoStudent) {
            console.log("performing an autologin...");
            root.escolesStage = 0;
            root.topWindow = escolesFrame;
            local_check_wired_connection.call([]);
        }
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
                if (root.loginMode == Main.LoginMode.EscolesStudent ||
                        root.loginMode == Main.LoginMode.EscolesTeacher) {
                    sddm.login(txtUser.text,txtPass.text,cmbSession.currentIndex);
                }

                if (root.loginMode == Main.LoginMode.AutoStudent) {
                    sddm.login("alumnat",root.escolesAutoLoginSettings,cmbSession.currentIndex);
                }
            }
            else {
                console.log("no cable found");
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

            if (root.loginMode == Main.LoginMode.EscolesStudent ||
                    root.loginMode == Main.LoginMode.AutoStudent) {
                root.escolesTarget = "WIFI_ALU";
            }

            if (root.loginMode == Main.LoginMode.EscolesTeacher) {
                root.escolesTarget = "WIFI_PROF";
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

            if (root.loginMode == Main.LoginMode.EscolesStudent ||
                    root.loginMode == Main.LoginMode.EscolesTeacher) {
                local_create_connection.call(["EscolesConectades",escolesTarget,txtUser.text,txtPass.text,""]);
            }

            if (root.loginMode == Main.LoginMode.AutoStudent) {
                local_create_connection.call(["EscolesConectades",escolesTarget,"alumnat",root.escolesAutoLoginSettings,""]);
            }

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
            if (root.loginMode == Main.LoginMode.EscolesStudent ||
                    root.loginMode == Main.LoginMode.EscolesTeacher) {
                local_wait_for_domain.call([]);
            }

            if (root.loginMode == Main.LoginMode.AutoStudent) {
                sddm.login("alumnat",root.escolesAutoLoginSettings,cmbSession.currentIndex);
            }
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

            if (value > 0 ) {
                escolesEnabled = true;
            }

            switch (value) {
                case Main.EscolesConectades.Teacher:
                    loginMode = Main.LoginMode.EscolesTeacher;
                break;
                case Main.EscolesConectades.Student:
                    loginMode = Main.LoginMode.EscolesStudent;
                break;
                case Main.EscolesConectades.Auto:
                    loginMode = Main.LoginMode.AutoStudent;
                    escolesAutoEnabled = true;
                break;

            }

            if (firstBoot) {
                firstBoot = false;
                if (escolesAutoEnabled) {
                    root.topWindow = escolesAutoLoginFrame;
                }
            }
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
    
    N4D.Proxy
    {
        id: local_get_autologin
        client: n4dLocal
        plugin: "EscolesConectades"
        method: "get_autologin"

        onError: {
            console.log("Failed to get EscolesConectades Autologin settings");
        }

        onResponse: {
            root.escolesAutoLoginSettings = value;
        }
    }

    Component.onCompleted: {
        console.log("looking for lliurex version...");

        for (var n=0;n< userModel.count;n++) {
            var index=userModel.index(n,0);
            var name=userModel.data(index,Qt.UserRole+1);
            if ( name === "guest-user" ) {
                console.log("Guest user found");
                    guestEnabled = true;
                    break;
            }
        }

        local_get_settings.call([]);
        local_get_autologin.call([]);
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

    LLX.Window {
        id: loginSelectorFrame
        visible: root.topWindow == this
        title: i18nd("lliurex-sddm-theme","Log in mode")
        width: 620
        height:128

        anchors.centerIn: parent

        RowLayout {
            anchors.fill: parent

            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Local")
                visible: root.localEnabled
                implicitWidth: PlasmaCore.Units.gridUnit*8
                icon.name: "computer"
                display: QQC2.AbstractButton.TextUnderIcon

                onClicked: {
                    root.loginMode = Main.LoginMode.Local;
                    root.topWindow=loginFrame;
                }
            }

            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Guest User")
                visible: root.guestEnabled
                implicitWidth: PlasmaCore.Units.gridUnit*8
                icon.name:"im-invisible-user"
                display: QQC2.AbstractButton.TextUnderIcon

                onClicked: {
                    root.loginMode = Main.LoginMode.Guest;
                    root.topWindow=guestFrame;
                }
            }

            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Escoles Conectades")
                visible: root.escolesEnabled
                implicitWidth: PlasmaCore.Units.gridUnit*8
                icon.name:"folder-cloud"
                display: QQC2.AbstractButton.TextUnderIcon

                onClicked: {

                    switch (root.escolesLogin) {
                        case Main.EscolesConectades.Teacher:
                            root.loginMode = Main.LoginMode.EscolesTeacher;
                        break;
                        case Main.EscolesConectades.Student:
                        case Main.EscolesConectades.Auto:
                            root.loginMode = Main.LoginMode.EscolesStudent;
                        break;
                        default:
                            root.loginMode = Main.LoginMode.EscolesStudent;
                        break;
                    }

                    root.topWindow = loginFrame;

                }
            }

            PlasmaComponents.Button {
                text: i18nd("lliurex-sddm-theme","Alumnat")
                visible: root.escolesAutoEnabled
                implicitWidth: PlasmaCore.Units.gridUnit*8
                icon.name:"smiley"
                display: QQC2.AbstractButton.TextUnderIcon

                onClicked: {
                    root.loginMode = Main.LoginMode.AutoStudent;
                    root.topWindow = escolesAutoLoginFrame;
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }

    /* setup frame */
    LLX.Window {
        id: settingsFrame
        visible: root.topWindow == this
        title: i18nd("lliurex-sddm-theme","Settings")
        width: 256
        height:256

        property int mode : Main.EscolesConectades.Teacher

        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                if (loginMode == Main.LoginMode.EscolesTeacher) {
                    settingsFrame.mode = Main.EscolesConectades.Teacher;
                }

                if (loginMode == Main.LoginMode.EscolesStudent || loginMode == Main.LoginMode.AutoStudent) {
                    settingsFrame.mode = Main.EscolesConectades.Student;
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent

            QQC2.GroupBox {
                //Layout.fillHeight:true
                Layout.fillWidth:true

                //title: i18nd("lliurex-sddm-theme","Escoles Conectades")
                ColumnLayout {
                    anchors.fill: parent
                    PlasmaComponents.RadioButton {
                        id: rb1
                        //enabled: chkEscoles.checked
                        checked: settingsFrame.mode == Main.EscolesConectades.Student
                        text: i18nd("lliurex-sddm-theme","WiFi Alumnos")

                        onClicked: {
                            btnSettingsAccept.enabled = true;
                        }
                    }
                    PlasmaComponents.RadioButton {
                        id: rb2
                        //enabled: chkEscoles.checked
                        checked: settingsFrame.mode == Main.EscolesConectades.Teacher
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

                        root.loginMode = (rb2.checked) ? Main.LoginMode.EscolesTeacher : Main.LoginMode.EscolesStudent;
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
                
                PlasmaComponents.Button {
                    id: btnUserSelector
                    //implicitWidth: PlasmaCore.Units.gridUnit*1
                    enabled: root.loginMode == Main.LoginMode.Local
                    icon.name:"user"
                    icon.width: 22
                    icon.height:22
                    flat: true

                    onClicked: {
                        root.topWindow=userFrame;
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
                
                PlasmaCore.IconItem {
                    id: imgPassword
                    source: "lock"
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
                        loginFrame.enabled = false;
                        login();
                    }
                    
                    PlasmaCore.IconItem {
                        source: "input-caps-on"
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

            RowLayout {
                visible: root.loginMode == Main.LoginMode.EscolesStudent || root.loginMode == Main.LoginMode.EscolesTeacher || root.loginMode == Main.LoginMode.AutoStudent
                //anchors.horizontalCenter: parent.horizontalCenter
                //anchors.right: btnLogin.right
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                PlasmaCore.IconItem {
                    id:imgEC
                    //width:16
                    //height:16
                    source: "network-wireless"
                    //anchors.verticalCenter: parent.verticalCenter
                }

                PlasmaComponents.ComboBox {
                    implicitWidth: 200
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        {value: Main.LoginMode.EscolesStudent, text: i18nd("lliurex-sddm-theme","Student")},
                        {value: Main.LoginMode.EscolesTeacher, text: i18nd("lliurex-sddm-theme","Teacher")}]

                    onActivated: {
                        root.loginMode = currentValue;
                    }

                    onVisibleChanged: {
                        if (visible) {
                            if (root.loginMode == Main.LoginMode.EscolesStudent || Main.LoginMode.AutoStudent) {
                                currentIndex = 0;
                            }
                            else {
                                currentIndex = 1;
                            }
                        }
                    }
                }
            
                Item {
                    width:imgEC.width
                }
            }
            
            Item {
                Layout.fillWidth:true;
                height:32
                
                Kirigami.InlineMessage {
                    id: message
                    anchors.fill:parent
                    showCloseButton: true
                    
                }
            }
                
            PlasmaComponents.Button {
                id: btnLogin
                text: i18nd("lliurex-sddm-theme","Login");
                implicitWidth: 200
                //anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignHCenter
                
                onClicked: {
                    loginFrame.enabled = false;
                    login();
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
                login();
            }
        }
    }

    LLX.Window {
        id: escolesAutoLoginFrame
        width: 400
        height: 200

        visible: root.topWindow == this

        margin: 24

        title: i18nd("lliurex-sddm-theme","Escoles Conectades")
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {

                timerAutoLogin.start();
                progressAutoLogin.value =  1.0;
                //btnForceEscolesAutoLogin.forceActiveFocus();
            }
        }

        ColumnLayout {
            anchors.fill: parent

            Item {
                height:32
            }

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

            Item {
                height:32
            }

            RowLayout {
                Layout.fillWidth: true
                //Layout.alignment: Qt.AlignCenter | Qt.AlignBottom

                PlasmaComponents.Button {

                    //text: i18nd("lliurex-sddm-theme","Cancel");
                    icon.name: "arrow-left"

                    onClicked: {
                        root.loginMode = Main.LoginMode.EscolesStudent;
                        timerAutoLogin.stop();
                        root.topWindow = loginFrame;
                    }

                }

                Item {
                    width:32
                }

                PlasmaComponents.Button {
                    id: btnForceEscolesAutoLogin
                    text: i18nd("lliurex-sddm-theme","Login");
                    implicitWidth: 200

                    onClicked: {
                        timerAutoLogin.stop();
                        login();
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
                    root.topWindow.enabled = true;
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
                implicitWidth: 200
                text: i18nd("lliurex-sddm-theme","Login")

                onClicked: {
                    guestFrame.enabled = false;
                    login();
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
                id: chkVkey
                Layout.alignment: Qt.AlignLeft
                icon.name:"input-keyboard-virtual"
                checkable: true
                display: QQC2.AbstractButton.IconOnly
                icon.width:24
                icon.height:24
            }

            PlasmaComponents.Button {
                id: btnModeSelector
                Layout.alignment: Qt.AlignLeft
                icon.name:"system-users"
                display: QQC2.AbstractButton.IconOnly
                icon.width:24
                icon.height:24
                visible: root.guestEnabled | root.escolesEnabled


                onClicked: {
                    root.topWindow = loginSelectorFrame;
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

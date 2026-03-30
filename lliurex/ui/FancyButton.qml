import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

QQC2.Button {
    id: btn

    Layout.preferredWidth: 64
    Layout.preferredHeight: 64

    property string theme: "animals"
    property int code : ((Layout.row * 3) + Layout.column)
    property alias image:img.source

    signal pushCode(code: int, source: string)

    Image {
        id: img
        anchors.fill:parent
        source: "../easy-login/themes/"+btn.theme+"/" + btn.code +".png"

        width:48
        height:48
        mipmap: true
    }

    onClicked: {
        btn.pushCode(btn.code,img.source);
    }
}

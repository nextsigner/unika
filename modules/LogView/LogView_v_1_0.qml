import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle{
    id: r
    width: 300
    height: 500
    color: apps.backgroundColor
    border.width: 2
    border.color: apps.fontColor
    clip: true
    //y: xDataBar.state==='show'?xDataBar.height:0
    //y: zoolDataView.state==='show'?zoolDataView.height:0
    property bool ww: true
    MouseArea{
        anchors.fill: parent
        onClicked: apps.showLog=false
    }
    Flickable{
        id: flLog
        width: parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: taLog.contentHeight
        clip: true
        Item{
            id: xTaLog
            width: r.width-app.fs
            height: taLog.contentHeight
            anchors.horizontalCenter: parent.horizontalCenter
            TextArea{
                id: taLog
                width: parent.width//-app.fs*2//*0.5
                //height: contentHeight
                wrapMode: r.ww?Text.WordWrap:Text.WrapAnywhere
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.top: parent.top
                //anchors.topMargin: app.fs*0.5
                font.pixelSize: app.fs*0.5
                color: apps.fontColor
                background: Rectangle{color: apps.backgroundColor}
                clip: true
            }
        }
    }
    Rectangle{
        width: app.fs*0.5
        height: width
        color: apps.fontColor
        anchors.right: parent.right
        anchors.rightMargin: app.fs*0.1
        anchors.top: parent.top
        anchors.topMargin: app.fs*0.1
        Text{
            text: 'X';
            anchors.centerIn: parent
            color: apps.backgroundColor
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                //apps.showLog=false
                //r.visible=apps.showLog
            }
        }
    }
    Rectangle{
        anchors.fill: r
        border.width: r.border.width
        border.color: r.border.color
        color: 'transparent'
    }
    function l(d){
        taLog.text+=d+'\n'
        flLog.contentY=taLog.contentHeight-r.height
    }
    function ls(d, x, w){
        taLog.text+=d+'\n'
        flLog.contentY=taLog.contentHeight-r.height
        r.visible=true
        r.width=w
        r.x=x
    }
    function lv(d){
        r.visible=true
        ls(d, r.x, r.width)
    }
    function lvc(d){
        clear()
        r.visible=true
        ls(d, r.x, r.width)
    }
    function clear(){
        taLog.clear()
    }
}

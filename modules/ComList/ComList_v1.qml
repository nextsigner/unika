import QtQuick 2.0

Rectangle{
    id: r
    width: 500
    height: 500
    //anchors.fill: parent
    color: 'transparent'
    ListView{
        id: lv
        anchors.fill: parent
        model: lm
        delegate: compItemList
    }
    ListModel{
        id: lm
        function add(c, s){
            return {
                vcom: c,
                vscript: s
            }
        }
    }

    Component{
        id: compItemList
        Rectangle{
            width: r.width
            height: col.height+app.fs
            color: apps.backgroundColor
            border.width: 1
            border.color: apps.fontColor
            Column{
                id: col
                spacing: app.fs*0.5
                anchors.centerIn: parent
                Text{
                    text: '<b>Comando: </b>'+vcom
                    font.pixelSize: app.fs*0.5
                    color: apps.fontColor
                    width: r.width-app.fs
                    wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text{
                    text: vscript
                    font.pixelSize: app.fs*0.5
                    color: apps.fontColor
                    width: r.width-app.fs
                    wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    Component.onCompleted: {


    }
    function loadComs(jsonFilePath){
        lm.clear()
        let j=JSON.parse(u.getFile(jsonFilePath))
        //log.lv(JSON.stringify(j, null, 2))
        for(var i=0;i<j.commands.length;i++){
            lm.append(lm.add(j.commands[i].com, j.commands[i].script))
        }
    }
    function proc(com){
        let indexCmd=searchCmd(com)//>=0?true:false
        if(indexCmd>=0){
            if(apps.dev)log.lv('Ejecutando comando '+com)
            if(apps.dev)log.lv('Script: '+lm.get(indexCmd).vscript)
            runScript(lm.get(indexCmd).vscript)
        }else{
            if(apps.dev)log.lv('NO es comando ['+com+']: searchCmd('+com+')')
        }
    }
    function searchCmd(com){
        let ret=-1
        for(var i=0;i<lm.count;i++){
            //log.lv('lm.get(i).com: '+lm.get(i).vcom)
            if(""+com===""+lm.get(i).vcom){
                ret=i
                break
            }
        }
        return ret
    }
}

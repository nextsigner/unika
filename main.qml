import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import unik.UnikQProcess 1.0
import LogView 1.0
import UniKey 1.0

import ComList 1.0

ApplicationWindow{
    id: app
    visible: true
    visibility: 'Maximized'
    color: apps.backgroundColor
    width: Screen.width
    height: Screen.height
    property int fs: Screen.width*0.02
    UniKey{id: u}
    onClosing: {
        uqp.kill()
        close.accepted = true;
    }

    Settings{
        id: apps
        fileName: './unika.cfg'
        property string nombreReceptor: 'pantalla'
        property string jsonFilePath: './command_examples.json'
        property bool dev: false
        property color backgroundColor: 'black'
        property color fontColor: 'white'
        property string audioFrom

        onDevChanged: {
            if(dev){
                log.lv('Se activó el modo Desarrollador.')
            }else{
                log.lv('Se desactivó el modo Desarrollador.')
            }
        }
    }
    UnikQProcess{
        id: uqp
        onLogDataChanged: {
            //log.lv(logData)
            if(logData.indexOf('unika::')===0){
                if(apps.dev)log.lv('Recibiendo: '+logData)
                if(logData.indexOf('unika::Parcial')===0){
                    let str=logData.replace('unika::Parcial')
                    log.lv('Capturando '+str)
                    return
                }
                if(logData.indexOf('unika::FINAL')===0){
                    log.lv('Recibiendo: '+logData)
                    //console.log('0['+logData+']')
                    let c=logData.replace(/[\r\n]+/g, '').replace('unika::FINAL: ', '')
                    //log.lv('0['+c+']')
                    if(apps.dev)log.lv('proc('+c+')')
                    //log.lv('1['+c+']')
                    comList.proc(c)
                    //proc(c)
                }
            }
        }
        onFinished: {
            log.lv('Proceso terminado.')
        }
        Component.onCompleted: {
            init()
        }
    }
    Item{
        id: xApp
        anchors.fill: parent
        Column{
            anchors.centerIn: parent
            Rectangle{
                id: xTop
                width: xApp.width
                height: app.fs*3
                color: 'transparent'
                border.width: 1
                border.color: apps.fontColor
                Row{
                    spacing: app.fs*0.5
                    anchors.centerIn: parent
                    Text{
                        text: '<b>Archivo de Comandos:</b>'
                        color: apps.fontColor
                        font.pixelSize: app.fs*0.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle{
                        width: app.fs*20
                        height: app.fs
                        color: 'transparent'
                        border.width: 2
                        border.color: apps.fontColor
                        clip: true
                        TextInput{
                            id: tiJsonFilePath
                            text: apps.jsonFilePath
                            width: parent.width-app.fs*0.25
                            color: apps.fontColor
                            font.pixelSize: app.fs*0.5
                            anchors.centerIn: parent
                            onTextChanged: {
                                apps.jsonFilePath=text
                                comList.loadComs(apps.jsonFilePath)
                            }
                        }
                    }
                }
            }
            Row{

                ComList{
                    id: comList
                    width: xApp.width*0.5
                    height: xApp.height-app.fs*3
                }
                LogView{
                    id: log
                    width: xApp.width*0.5
                    height: xApp.height-app.fs*3
                    color: apps.backgroundColor
                    border.width: 2
                    border.color: apps.fontColor
                    //                Rectangle{
                    //                    anchors.fill: parent
                    //                }
                }
            }
        }

    }
    Item{id: xuqps}
    Component.onCompleted: {
        comList.loadComs(apps.jsonFilePath)
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: {
            uqp.kill()
            Qt.quit()
        }
    }
    Shortcut{
        sequence: 'Ctrl+d'
        onActivated: apps.dev=!apps.dev
    }
    Shortcut{
        sequence: 'Ctrl+r'
        onActivated: comList.loadComs(apps.jsonFilePath)
    }
    Shortcut{
        sequence: 'Ctrl+i'
        onActivated: tiJsonFilePath.focus=true
    }
    Shortcut{
        sequence: 'Ctrl+f'
        onActivated: {
            uqp.kill()
            if(apps.audioFrom==='rtmp'){
                apps.audioFrom='mic'
            }else{
                apps.audioFrom='rtmp'
            }
            init()
        }
    }
    function init(){
        let from='init.sh'
        if(apps.audioFrom==='rtmp'){
            from='initFromRtmp.sh'
        }
        let cmd='sh '+u.currentFolderPath()+'/'+from
        uqp.run(cmd)
    }
    function getUqpCode(idName, cmd, onLogDataCode, onFinishedCode, onCompleteCode){
        let c='import QtQuick 2.0\n'
        c+='import unik.UnikQProcess 1.0\n'
        c+='Item{\n'
        c+='        id: item'+idName+'\n'
        c+='    UnikQProcess{\n'
        c+='        id: '+idName+'\n'
        c+='        onFinished:{\n'
        c+='        '+onFinishedCode
        c+='        '+idName+'.destroy(0)\n'
        c+='        }\n'
        c+='        onLogDataChanged:{\n'
        c+='        '+onLogDataCode
        c+='        }\n'
        c+='        Component.onCompleted:{\n'
        c+='        '+onCompleteCode
        c+='            let cmd=\''+cmd+'\'\n'
        c+='            run(cmd)\n'
        c+='        }\n'
        c+='    }\n'
        c+='}\n'
        return c
    }
    function runScript(commandLine){
        let c=''

        c='log.lv("Ejecutando ['+commandLine+']...")\n'
        let onCompleteCode=c

        c='uqpRunScript'
        let idName=c

        c=''+commandLine
        let cmd=c

        c='        log.lv("Salida de ['+commandLine+']:"+logData)\n'
        let onLogDataCode=c


        c='        log.lv("Finalizó ['+commandLine+']")\n'
        c='        item'+idName+'.destroy(0)\n'
        let onFinishedCode=c

        let cf=getUqpCode(idName, cmd, onLogDataCode, onFinishedCode, onCompleteCode)

        if(apps.dev)log.lv('cf '+idName+': '+cf)

        let comp=Qt.createQmlObject(cf, xuqps, 'uqp-code-'+idName)
    }
}

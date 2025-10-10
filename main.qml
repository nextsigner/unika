import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import unik.UnikQProcess 1.0
import LogView 1.0
import UniKey 1.0
ApplicationWindow{
    id: app
    visible: true
    visibility: 'Maximized'
    color: apps.backgroundColor
    width: Screen.width
    height: Screen.height
    property int fs: Screen.width*0.02
    UniKey{id: u}
    Settings{
        id: apps
        property color backgroundColor: 'black'
        property color fontColor: 'white'
    }
    UnikQProcess{
        id: uqp
        onLogDataChanged: {
            log.lv(logData)
            if(logData.indexOf('unika::')===0){
                log.lv('Recibiendo: '+logData)
            }
        }
        Component.onCompleted: {
            let cmd='sh '+u.currentFolderPath()+'/init.sh'
            run(cmd)
        }
    }
    Item{
        id: xApp
        anchors.fill: parent
        Row{
            anchors.centerIn: parent
            Rectangle{
                width: xApp.width*0.5
                height: xApp.height
                color: apps.backgroundColor
                border.width: 2
                border.color: apps.fontColor
            }
            LogView{
                id: log
                width: xApp.width*0.5
                height: xApp.height
                color: apps.backgroundColor
                border.width: 2
                border.color: apps.fontColor
//                Rectangle{
//                    anchors.fill: parent
//                }
            }
        }

    }
    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}

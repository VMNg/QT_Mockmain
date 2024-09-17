import QtQuick 2.11
import QtQuick.Window 2.11
import QtApplicationManager.SystemUI 2.0

Window {
    title: "MOCKDEV2"
    width: 1280
    height: 720
    color: "whitesmoke"

    Text {
        anchors.bottom: parent.bottom
        text: (ApplicationManager.singleProcess ? "Single" : "Multi") + "-Process Mode"
    }

    Row {
        z: 9998
        id: topNavBar
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
         // Add spacing between buttons

        Repeater {
            model: ApplicationManager  // Keep the model

            delegate: Rectangle {
                width: 1280/3
                height: 100
                color: "#1E3A5F"  // Change to match your design
                Text {
                    anchors.centerIn: parent
                    text: application.name("en")  
                    font.bold: true
                    color: "grey"
                    font.pixelSize: 19
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Logic to switch to the corresponding application
                        if (isRunning) {
                            application.stop();
                        } else {
                            application.start();
                        }
                    }
                }
            }
        }
    }

    Repeater {
        model: ListModel { id: topLevelWindowsModel }

        delegate: Rectangle {
            id: chrome
            anchors {
                top: topNavBar.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }
            color: "transparent"
            border.width: 3
            border.color: "grey"
            z: model.index


            WindowItem {
                anchors.fill: parent
                window: model.window

                Connections {
                    target: window
                    function onContentStateChanged() {
                        if (window.contentState === WindowObject.NoSurface)
                            topLevelWindowsModel.remove(model.index, 1);
                    }
                }
            }

        }
    }

    Repeater {
        model: ListModel { id: popupsModel }
        delegate: WindowItem {
            z: 9999 + model.index
            anchors.centerIn: parent
            window: model.window
            Connections {
                target: model.window
                function onContentStateChanged() {
                    if (model.window.contentState === WindowObject.NoSurface)
                        popupsModel.remove(model.index, 1);
                }
            }
        }
    }

    Text {
        z: 9999
        font.pixelSize: 46
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: NotificationManager.count > 0 ? NotificationManager.get(0).summary : ""
    }

    Connections {
        target: WindowManager
        function onWindowAdded(window) {
            var model = window.windowProperty("type") === "pop-up" ? popupsModel : topLevelWindowsModel;
            model.append({"window":window});
        }
    }

    Connections {
        target: ApplicationManager
        function onApplicationRunStateChanged(id, runState) {
            if (runState === Am.NotRunning
                && ApplicationManager.application(id).lastExitStatus === Am.CrashExit) {
                ApplicationManager.startApplication(id);
            }
        }
    }
}

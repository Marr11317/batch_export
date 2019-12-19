import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2 // FileDialogs
import Qt.labs.folderlistmodel 2.2
import Qt.labs.settings 1.0
import QtQml 2.8
import MuseScore 3.0
import FileIO 3.0

RowLayout {
    id: mainRow
    GroupBox {
        id: inFormats
        title: " " + qsTr("Input Formats") + " "
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        //flat: true // no effect?!
        //checkable: true // no effect?!
        property var extensions: new Array
        Column {
            spacing: 1
            CheckBox {
                id: inMscz
                text: "*.mscz"
                checked: true
                //exclusiveGroup: mscz  // doesn't work?!
                onClicked: {
                    if (checked && outMscz.checked)
                        outMscz.checked = false
                }
            }
            CheckBox {
                id: inMscx
                text: "*.mscx"
                //exclusiveGroup: mscx
                onClicked: {
                    if (checked && outMscx.checked)
                        outMscx.checked = false
                }
            }
            CheckBox {
                id: inMsc
                text: "*.msc"
                enabled: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                visible: enabled // hide if not enabled
            }
            CheckBox {
                id: inXml
                text: "*.xml"
                //exclusiveGroup: xml
                onClicked: {
                    if (checked && outXml.checked)
                        outXml.checked = !checked
                }
            }
            CheckBox {
                id: inMusicXml
                text: "*.musicxml"
                //exclusiveGroup: musicxml
                enabled: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                visible: enabled // hide if not enabled
                onClicked: {
                    if (checked && outMusicXml.checked)
                        outMusicXml.checked = !checked
                }
            }
            CheckBox {
                id: inMxl
                text: "*.mxl"
                //exclusiveGroup: mxl
                onClicked: {
                    if (checked && outMxl.checked)
                        outMxl.checked = false
                }
            }
            CheckBox {
                id: inMid
                text: "*.mid"
                //exclusiveGroup: mid
                onClicked: {
                    if (checked && outMid.checked)
                        outMid.checked = false
                }
            }
            CheckBox {
                id: inPdf
                text: "*.pdf"
                enabled: false // needs OMR, MuseScore > 2.0?
                visible: enabled // hide if not enabled
                //exclusiveGroup: pdf
                onClicked: {
                    if (checked && outPdf.checked)
                        outPdf.checked = false
                }
            }
            CheckBox {
                id: inMidi
                text: "*.midi"
            }
            CheckBox {
                id: inKar
                text: "*.kar"
            }
            CheckBox {
                id: inCap
                text: "*.cap"
            }
            CheckBox {
                id: inCapx
                text: "*.capx"
            }
            CheckBox {
                id: inBww
                text: "*.bww"
            }
            CheckBox {
                id: inMgu
                text: "*.mgu"
            }
            CheckBox {
                id: inSgu
                text: "*.sgu"
            }
            CheckBox {
                id: inOve
                text: "*.ove"
            }
            CheckBox {
                id: inScw
                text: "*.scw"
            }
            CheckBox {
                id: inGtp
                text: "*.gtp"
            }
            CheckBox {
                id: inGp3
                text: "*.gp3"
            }
            CheckBox {
                id: inGp4
                text: "*.gp4"
            }
            CheckBox {
                id: inGp5
                text: "*.gp5"
            }
            CheckBox {
                id: inGpx
                text: "*.gpx"
            }
        } // Column
    } // inFormats
    ColumnLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignRight
        RowLayout {
            Label {
                text: " ===> "
                Layout.fillWidth: true // left align (?!)
            }
            GroupBox {
                id: outFormats
                title: " " + qsTr("Output Formats") + " "
                property var extensions: new Array
                Column {
                    spacing: 1
                    CheckBox {
                        id: outMscz
                        text: "*.mscz"
                        //exclusiveGroup: mscz
                        onClicked: {
                            if (checked && inMscz.checked)
                                inMscz.checked = false
                        }
                    }
                    CheckBox {
                        id: outMscx
                        text: "*.mscx"
                        //exclusiveGroup: mscx
                        onClicked: {
                            if (checked && inMscx.checked)
                                inMscx.checked = false
                        }
                    }
                    CheckBox {
                        id: outXml
                        text: "*.xml"
                        enabled: (mscoreMajorVersion == 2 && mscoreMinorVersion <= 1) ? true : false // MuseScore <= 2.1
                        //could also export to musicxml and then rename that to xml in versions after 2.1
                        visible: enabled // hide if not enabled
                        //exclusiveGroup: xml
                        onClicked: {
                            if (checked && inXml.checked)
                                inXml.checked = false
                        }
                    }
                    CheckBox {
                        id: outMusicXml
                        text: "*.musicxml"
                        enabled: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                        //could also export to musicxml and then rename that to xml in versions after 2.1
                        visible: enabled // hide if not enabled
                        //exclusiveGroup: musicxml
                        onClicked: {
                            if (checked && inMusicXml.checked)
                                inMusicXml.checked = false
                        }
                    }
                    CheckBox {
                        id: outMxl
                        text: "*.mxl"
                        //exclusiveGroup: mxl
                        onClicked: {
                            if (checked && inMxl.checked)
                                inMxl.checked = false
                        }
                    }
                    CheckBox {
                        id: outMid
                        text: "*.mid"
                        //exclusiveGroup: mid
                        onClicked: {
                            if (checked && inMid.checked)
                                inMid.checked = false
                        }
                    }
                    CheckBox {
                        id: outPdf
                        text: "*.pdf"
                        checked: true
                        //exclusiveGroup: pdf
                        onClicked: {
                            if (checked && inPdf.checked)
                                inPdf.checked = false
                        }
                    }
                    CheckBox {
                        id: outPs
                        text: "*.ps"
                        enabled: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                        visible: enabled // hide if not enabled
                    }
                    CheckBox {
                        id: outPng
                        text: "*.png"
                    }
                    CheckBox {
                        id: outSvg
                        text: "*.svg"
                    }
                    CheckBox {
                        id: outLy
                        text: "*.ly"
                        enabled: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0, or via xml2ly?
                        visible: enabled // hide if not enabled
                    }
                    CheckBox {
                        id: outWav
                        text: "*.wav"
                    }
                    CheckBox {
                        id: outFlac
                        text: "*.flac"
                    }
                    CheckBox {
                        id: outOgg
                        text: "*.ogg"
                    }
                    CheckBox { // needs lame_enc.dll
                        id: outMp3
                        text: "*.mp3"
                    }
                } //Column
            } //outFormats
        } // RowLayout
        CheckBox {
            id: exportExcerpts
            text: /*qsTr("Export linked parts")*/ qsTranslate("action", "Export parts")
            enabled: (mscoreMajorVersion == 3 && mscoreMinorVersion > 0 || (mscoreMinorVersion == 0 && mscoreUpdateVersion > 2)) ? true : false // MuseScore > 3.0.2
            visible: enabled //  hide if not enabled
        } // exportExcerpts
        CheckBox {
            id: traverseSubdirs
            text: qsTr("Process\nSubdirectories")
        } // traverseSubdirs
        CheckBox {
            id: differentExportPath
            // Only allow different export path if not traversing subdirs. 
            // Would be better disabled than invisible, but couldn't find the way to change to disabled color, 
            // and having the same enabled and disabled is very confusing.
            visible: !traverseSubdirs.checked 
            text: qsTr("Different Export\nPath")
        } // differentExportPath
        Button {
            id: reset
            text: /*qsTr("Reset to Defaults")*/ qsTranslate("QPlatformTheme", "Restore Defaults")
            onClicked: {
                resetDefaults()
            } // onClicked
        } // reset
        GroupBox {
            id: cancelOk
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Row {
                Button {
                    id: ok
                    text: /*qsTr("Ok")*/ qsTranslate("QPlatformTheme", "OK")
                    //isDefault: true // needs more work
                    onClicked: {
                        if (collectInOutFormats())
                            sourceFolderDialog.open()
                    } // onClicked
                } // ok
                Button {
                    id: cancel
                    text: /*qsTr("Cancel")*/ qsTranslate("QPlatformTheme", "Cancel")
                    onClicked: {
                        Qt.quit()
                    }
                } // Cancel
            } // Row
        } // cancelOk
    } // ColumnLayout
}

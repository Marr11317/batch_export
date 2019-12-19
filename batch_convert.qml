import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2 // FileDialogs
import Qt.labs.folderlistmodel 2.2
import Qt.labs.settings 1.0
import QtQml 2.8
import MuseScore 3.0
import FileIO 3.0
import "./" as Buts

MuseScore {
  menuPath: "Plugins." + qsTr("Batch Convert")
  version: "3.0"
  requiresScore: false
  description: qsTr("This plugin converts mutiple files from various formats"
    + " into various formats")
  pluginType: "dialog"

  MessageDialog {
    id: versionError
    visible: false
    title: qsTr("Unsupported MuseScore Version")
    text: qsTr("This plugin needs MuseScore 3")
    onAccepted: {
      window.visible = false
      Qt.quit()
      }
    }

  onRun: {
    // check MuseScore version
    if (mscoreMajorVersion < 3) { // we should really never get here, but fail at the imports above already
      window.visible = false
      versionError.open()
      }
    else
      window.visible = true // needed for unknown reasons
    }

//Window {
    id: window

    width: mainRow.childrenRect.width
    height: mainRow.childrenRect.height

    // Mutally exclusive in/out formats, doesn't work properly
    ExclusiveGroup { id: mscz }
    ExclusiveGroup { id: mscx }
    ExclusiveGroup { id: xml }
    ExclusiveGroup { id: mxl }
    ExclusiveGroup { id: mid }
    ExclusiveGroup { id: pdf }

    Buts.MainRow {
        id: mainRow
    } // RowLayout
  //} // Window
  // remember settings
  Settings {
    id: settings
    category: "BatchConvertPlugin"
    // in options
    property alias inMscz:  inMscz.checked
    property alias inMscx:  inMscx.checked
    property alias inMsc:   inMsc.checked
    property alias inXml:   inXml.checked
    property alias inMusicXml:   inMusicXml.checked
    property alias inMxl:   inMxl.checked
    property alias inMid:   inMid.checked
    property alias inPdf:   inPdf.checked
    property alias inMidi:  inMidi.checked
    property alias inKar:   inKar.checked
    property alias inCap:   inCap.checked
    property alias inCapx:  inCapx.checked
    property alias inBww:   inBww.checked
    property alias inMgu:   inMgu.checked
    property alias inSgu:   inSgu.checked
    property alias inOve:   inOve.checked
    property alias inScw:   inScw.checked
    property alias inGtp:   inGtp.checked
    property alias inGp3:   inGp3.checked
    property alias inGp4:   inGp4.checked
    property alias inGp5:   inGp5.checked
    property alias inGpx:   inGpx.checked
    // out options
    property alias outMscz: outMscz.checked
    property alias outMscx: outMscx.checked
    property alias outXml:  outXml.checked
    property alias outMusicXml:  outMusicXml.checked
    property alias outMxl:  outMxl.checked
    property alias outMid:  outMid.checked
    property alias outPdf:  outPdf.checked
    property alias outPs:   outPs.checked
    property alias outPng:  outPng.checked
    property alias outSvg:  outSvg.checked
    property alias outLy:   outLy.checked
    property alias outWav:  outWav.checked
    property alias outFlac: outFlac.checked
    property alias outOgg:  outOgg.checked
    property alias outMp3:  outMp3.checked
    // other options
    property alias exportE: exportExcerpts.checked
    property alias travers: traverseSubdirs.checked
    property alias diffEPath: differentExportPath.checked  // different export path
    }

  FileDialog {
    id: sourceFolderDialog
    title: traverseSubdirs.checked ?
      qsTr("Select Sources Startfolder") :
      qsTr("Select Sources Folder")
    selectFolder: true
    
    onAccepted: {
      if (differentExportPath.checked && !traverseSubdirs.checked)
        targetFolderDialog.open(); // work we be called from within the target folder dialog
      else
        work() 
      }
    onRejected: {
      console.log("No source folder selected")
      Qt.quit()
      }
    } // sourceFolderDialog
    
  FileDialog {
    id: targetFolderDialog
    title: qsTr("Select Target Folder")
    selectFolder: true
    
    onAccepted: {
      // remove the file:/// at the beginning of the return value of targetFolderDialog.folder
      // However, what needs to be done depends on the platform.
      // See this stackoverflow post for more details:
      // https://stackoverflow.com/questions/24927850/get-the-path-from-a-qml-url
      if (folder.toString().indexOf("file:///") != -1) // startsWith is EcmaScript6, so not for now
        folderPath = folder.toString().substring(folder.toString().charAt(9) === ':' ? 8 : 7)
      else
        folderPath = folder
      work()
    }

    onRejected: {
      console.log("No target folder selected")
      Qt.quit()
      }
    } // targetFolderDialog

  function resetDefaults() {
    inMscx.checked = inXml.checked = inMusicXml.checked = inMxl.checked = inMid.checked =
      inPdf.checked = inMidi.checked = inKar.checked = inCap.checked =
      inCapx.checked = inBww.checked = inMgu.checked = inSgu.checked =
      inOve.checked = inScw.checked = inGtp.checked = inGp3.checked =
      inGp4.checked = inGp5.checked = inGpx.checked = false
    outMscz.checked = outMscx.checked = outXml.checked = outMusicXml.checked = outMxl.checked =
      outMid.checked = outPdf.checked = outPs.checked = outPng.checked =
      outSvg.checked = outLy.checked = outWav.checked = outFlac.checked =
      outOgg.checked = outMp3.checked = false
    traverseSubdirs.checked = false
    exportExcerpts.checked = false
    // 'uncheck' everything, then 'check' the next few
    inMscz.checked = outPdf.checked = true
    differentExportPath.checked = false
    } // resetDefaults

  function collectInOutFormats() {
    if (inMscz.checked) inFormats.extensions.push("mscz")
    if (inMscx.checked) inFormats.extensions.push("mscx")
    if (inXml.checked)  inFormats.extensions.push("xml")
    if (inMusicXml.checked)  inFormats.extensions.push("musicxml")
    if (inMxl.checked)  inFormats.extensions.push("mxl")
    if (inMid.checked)  inFormats.extensions.push("mid")
    if (inPdf.checked)  inFormats.extensions.push("pdf")
    if (inMidi.checked) inFormats.extensions.push("midi")
    if (inKar.checked)  inFormats.extensions.push("kar")
    if (inCap.checked)  inFormats.extensions.push("cap")
    if (inCapx.checked) inFormats.extensions.push("capx")
    if (inBww.checked)  inFormats.extensions.push("bww")
    if (inMgu.checked)  inFormats.extensions.push("mgu")
    if (inSgu.checked)  inFormats.extensions.push("sgu")
    if (inOve.checked)  inFormats.extensions.push("ove")
    if (inScw.checked)  inFormats.extensions.push("scw")
    if (inGtp.checked)  inFormats.extensions.push("gtp")
    if (inGp3.checked)  inFormats.extensions.push("gp3")
    if (inGp4.checked)  inFormats.extensions.push("gp4")
    if (inGp5.checked)  inFormats.extensions.push("gp5")
    if (inGpx.checked)  inFormats.extensions.push("gpx")
    if (!inFormats.extensions.length)
      console.log("No input format selected")

    if (outMscz.checked) outFormats.extensions.push("mscz")
    if (outMscx.checked) outFormats.extensions.push("mscx")
    if (outXml.checked)  outFormats.extensions.push("xml")
    if (outMusicXml.checked)  outFormats.extensions.push("musicxml")
    if (outMxl.checked)  outFormats.extensions.push("mxl")
    if (outMid.checked)  outFormats.extensions.push("mid")
    if (outPdf.checked)  outFormats.extensions.push("pdf")
    if (outPs.checked)   outFormats.extensions.push("ps")
    if (outPng.checked)  outFormats.extensions.push("png")
    if (outSvg.checked)  outFormats.extensions.push("svg")
    if (outLy.checked)   outFormats.extensions.push("ly")
    if (outWav.checked)  outFormats.extensions.push("wav")
    if (outFlac.checked) outFormats.extensions.push("flac")
    if (outOgg.checked)  outFormats.extensions.push("ogg")
    if (outMp3.checked)  outFormats.extensions.push("mp3")
    if (!outFormats.extensions.length)
      console.log("No output format selected")

    return (inFormats.extensions.length && outFormats.extensions.length)
    } // collectInOutFormats

  // flag for abort request
  property bool abortRequested: false

  // dialog to show progress
  Dialog {
    id: workDialog
    modality: Qt.ApplicationModal
    visible: false
    width: 720
    standardButtons: StandardButton.Abort

    Label {
      id: currentStatus
      width: 600
      text: qsTr("Running...")
      }

    TextArea {
      id: resultText
      width: 700
      height: 250
      anchors {
        top: currentStatus.bottom
        topMargin: 5
        }
      }

    onAccepted: {
      Qt.quit()
      }

    onRejected: {
      abortRequested = true
      Qt.quit()
      }
    }

  function inInputFormats(suffix) {
    var found = false

    for (var i = 0; i < inFormats.extensions.length; i++) {
      if (inFormats.extensions[i].toUpperCase() === suffix.toUpperCase()) {
        found = true
        break
        }
      }
    return found
    }

  // createDefaultFileName
  // remove some special characters in a score title
  // when creating a file name
  function createDefaultFileName(fn) {
    fn = fn.trim()
    fn = fn.replace(/ /g,"_")
    fn = fn.replace(/\n/g,"_")
    fn = fn.replace(/[\\\/:\*\?\"<>|]/g,"_")
    return fn
    }

  // global list of folders to process
  property var folderList
  // global list of files to process
  property var fileList
  // global list of linked parts to process
  property var excerptsList

  // variable to remember current parent score for parts
  property var curBaseScore

  // FolderListModel can be used to search the file system
  FolderListModel {
    id: files
    }

  FileIO {
    id: fileExcerpt
    }
    
  FileIO {
    id: fileScore // We need two because they they are used from 2 different processes, 
                   // which could cause threading problems
    }

  Timer {
    id: excerptTimer
    interval: 1
    running: false

    // this function processes one linked part and
    // gives control back to Qt to update the dialog
    onTriggered: {
      var curScoreInfo = excerptsList.shift()
      var thisScore = curScoreInfo[0].partScore
      var partTitle = curScoreInfo[0].title
      var filePath = curScoreInfo[1]
      var fileName = curScoreInfo[2]
      var srcModifiedTime = curScoreInfo[3]

      // create full file path for part
      var targetBase;
      if (differentExportPath.checked && !traverseSubdirs.checked)
        targetBase = targetFolderDialog.folderPath + "/" + fileName 
                                    + "-" + createDefaultFileName(partTitle) + "." 
      else
        targetBase = filePath + fileName + "-" + createDefaultFileName(partTitle) + "." 

      // write for all target formats
      for (var j = 0; j < outFormats.extensions.length; j++) {
        // get modification time of destination file (if it exists)
        // modifiedTime() will return 0 for non-existing files
        // if src is newer than existing write this file
        fileExcerpt.source = targetBase + outFormats.extensions[j]
        if (srcModifiedTime > fileExcerpt.modifiedTime()) {
          var res = writeScore(thisScore, fileExcerpt.source, outFormats.extensions[j])
          if (res) 
            resultText.append("%1 → %2".arg(fileExcerpt.source).arg(outFormats.extensions[j]))
          else
            resultText.append("Error: %1 → %2 not exported".arg(fileExcerpt.source).arg(outFormats.extensions[j]))
          }
        else // file already up to date
          resultText.append(qsTr("%1 is up to date").arg(fileExcerpt.source))
        }

      // check if more files
      if (!abortRequested && excerptsList.length > 0)
        excerptTimer.running = true
      else {
        // close base score
        closeScore(curBaseScore)
        processTimer.running = true
        }
      }
    }

  Timer {
    id: processTimer
    interval: 1
    running: false

    // this function processes one file and then
    // gives control back to Qt to update the dialog
    onTriggered: {
      if (fileList.length === 0) {
        // no more files to process
        workDialog.standardButtons = StandardButton.Ok
        if (!abortRequested)
          currentStatus.text = /*qsTr("Done.")*/ qsTranslate("QWizzard", "Done") + "."
        else
          console.log("abort!")
        return
      }

      var curFileInfo = fileList.shift()
      var filePath = curFileInfo[0]
      var fileName = curFileInfo[1]
      var fileExt = curFileInfo[2]
      
      var fileFullPath = filePath + fileName + "." + fileExt

      // read file
      var thisScore = readScore(fileFullPath, true)

      // make sure we have a valid score
      if (thisScore) {
        // get modification time of source file
        fileScore.source = fileFullPath
        var srcModifiedTime = fileScore.modifiedTime()
        // write for all target formats
        for (var j = 0; j < outFormats.extensions.length; j++) {
          if (differentExportPath.checked && !traverseSubdirs.checked)
            fileScore.source = targetFolderDialog.folderPath + "/" + fileName + "." + outFormats.extensions[j]
          else
            fileScore.source = filePath + fileName + "." + outFormats.extensions[j]

          // get modification time of destination file (if it exists)
          // modifiedTime() will return 0 for non-existing files
          // if src is newer than existing write this file
          if (srcModifiedTime > fileScore.modifiedTime()) {
            var res = writeScore(thisScore, fileScore.source, outFormats.extensions[j])
             
            if (res)
              resultText.append("%1 → %2".arg(fileFullPath).arg(outFormats.extensions[j]))
            else
              resultText.append("Error: %1 → %2 not exported".arg(fileFullPath).arg(outFormats.extensions[j]))
            } 
          else
            resultText.append(qsTr("%1 is up to date").arg(fileFullPath))
          }
        // check if we are supposed to export parts
        if (exportExcerpts.checked) {
          // reset list
          excerptsList = []
          // do we have excertps?
          var excerpts = thisScore.excerpts
          for (var ex = 0; ex < excerpts.length; ex++) {
            if (excerpts[ex].partScore !== thisScore) // only list when not base score
              excerptsList.push([excerpts[ex], filePath, fileName, srcModifiedTime])
            }
          // if we have files start timer
          if (excerpts.length > 0) {
            curBaseScore = thisScore // to be able to close this later
            excerptTimer.running = true
            return
            }
          }
        closeScore(thisScore)
        }
      else
        resultText.append(qsTr("ERROR reading file %1").arg(fileName))
      
      // next file
      if (!abortRequested)
        processTimer.running = true
      }
    }

  // FolderListModel returns what Qt calles the
  // completeSuffix for "fileSuffix" which means everything
  // that follows the first '.' in a file name. (e.g. 'tar.gz')
  // However, this is not what we want:
  // For us the suffix is the part after the last '.'
  // because some users have dots in their file names.
  // Qt::FileInfo::suffix() would get this, but seems not
  // to be available in FolderListModel.
  // So, we need to do this ourselves:
  function getFileSuffix(fileName) {

    var n = fileName.lastIndexOf(".");
    var suffix = fileName.substring(n+1);

    return suffix
    }

  // This timer contains the function that will be called
  // once the FolderListModel is set.
  Timer {
    id: collectFiles
    interval: 25
    running: false

    // Add all files found by FolderListModel to our list
    onTriggered: {
      // to be able to show what we're doing
      // we must create a list of files to process
      // and then use a timer to do the work
      // otherwise, the dialog window will not update

      for (var i = 0; i < files.count; i++) {

        // if we have a directory, we're supposed to
        // traverse it, so add it to folderList
        if (files.isFolder(i))
          folderList.push(files.get(i, "fileURL"))
        else if (inInputFormats(getFileSuffix(files.get(i, "fileName")))) {
          // found a file to process
          // set file names for in and out files
          
          // We need 3 things:
          // 1) The file path: C:/Path/To/
          // 2) The file name:            my_score
          //                                      .
          // 3) The file's extension:              mscz
          
          var fln = files.get(i, "fileName") // returns  "my_score.mscz"
          var flp = files.get(i, "filePath") // returns  "C:/Path/To/my_score.mscz"
          
          var fileExt  = getFileSuffix(fln);  // mscz
          var fileName = fln.substring(0, fln.length - fileExt.length - 1)
          var filePath = flp.substring(0, flp.length - fln.length)
          
          /// in doubt uncomment to double check
          // console.log("fln", fln)
          // console.log("flp", flp)
          // console.log("fileExt", fileExt)
          // console.log("fileName", fileName)
          // console.log("filePath", filePath)
          
          fileList.push([filePath, fileName, fileExt])
          }
        }

      // if folderList is non-empty we need to redo this for the next folder
      if (folderList.length > 0) {
        files.folder = folderList.shift()
        // restart timer for folder search
        collectFiles.running = true
      } else if (fileList.length > 0) {
        // if we found files, start timer do process them
        processTimer.running = true
        } 
      else {
        // we didn't find any files
        // report this
        resultText.append(qsTr("No files found"))
        workDialog.standardButtons = StandardButton.Ok
        currentStatus.text = /*qsTr("Done.")*/ qsTranslate("QWizzard", "Done") + "."
        }
      }
    }

  function work() {
    console.log((traverseSubdirs.checked? "Sources Startfolder: ":"Sources Folder: ")
      + sourceFolderDialog.folder)
      
    if (differentExportPath.checked && !traverseSubdirs.checked)
      console.log("Export folder: " + targetFolderDialog.folderPath)

    // initialize global variables
    fileList = []
    folderList = []

    // set folder and filter in FolderListModel
    files.folder = sourceFolderDialog.folder

    if (traverseSubdirs.checked) {
      files.showDirs = true
      files.showFiles = true
      } 
    else {
      // only look for files
      files.showFiles = true
      files.showDirs = false
      }

    // wait for FolderListModel to update
    // therefore we start a timer that will
    // wait for 25 millis and then start working
    collectFiles.running = true
    workDialog.visible = true
    } // work
  } // MuseScore

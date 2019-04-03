//  Copy the script to the local storage on the vessel's CPU.
function loadScript {
  parameter archivePath.
  parameter scriptName.

  set fullScriptPath to archivePath + scriptName.
  if exists(fullScriptPath) {
    copypath(fullScriptPath, "1:").
    wait 1.
  } else {
    print "Warning: File not in archive " + fullScriptPath.
  }
}

//  Delete the script from the local storage.
function deleteLocalScript {
  parameter scriptName.

  if exists(scriptName) {
    deletepath(scriptName).
  } else {
    print "Warning: Could not delete " + scriptName.
  }
}

//  Function for staging when needed during burns
//  gotten from Nuggreat https://www.reddit.com/r/Kos/comments/8cl7l5/need_help_with_staging/
function stageCheck {
  parameter enableStage IS TRUE.
  local needStage IS FALSE.
  if enableStage AND STAGE:READY {
    if MaxThrust = 0 {
      set needStage TO TRUE.
    } else {
      LOCAL engineList IS LIST().
      LIST ENGINES IN engineList.
      FOR engine IN engineList {
        IF engine:IGNITION and engine:FLAMEOUT {
          SET needStage TO TRUE.
          BREAK.
        }
      }
    }
    IF needStage {
      Stage.
    }
  }
  RETURN needStage.
}

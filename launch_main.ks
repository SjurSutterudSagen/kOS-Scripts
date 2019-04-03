//  Main launch script
//  Checks wether the planet you're on has an atmosphere or not, and loads the
//  corresponding script

//CLEARSCREEN.

//  Parameters
parameter desiredApo is FALSE.

//  Declaring variables
set status to STATUS.
set atmo to BODY:ATM:EXISTS.
set archiveScriptsPath to "0:/launch/".
set atmoScriptName to "basic_ascent_atmo.ks".
set vacScriptName to "basic_ascent_vac.ks".

if (status = "LANDED") or (status = "PRELAUNCH") {

  //  Copy the library to local storage and then run it
  copypath("0:/libs/library.ks", "1:").
  runoncepath("library.ks").

  //  Check wether the current planet has an atmosphere, and run the corresponding
  //  launch script
  if atmo {
    print "The current planet is " + BODY:NAME + " which has an atmosphere.".
    loadScript(archiveScriptsPath, atmoScriptName).
    runoncepath(atmoScriptName, desiredApo).
    deleteLocalScript(atmoScriptName).
  } else {
    print "The current planet is " + BODY:NAME + " which does not have an
    atmosphere.".
    loadScript(archiveScriptsPath, vacScriptName).
    runoncepath(vacScriptName, desiredApo).
    deleteLocalScript(vacScriptName).
    }

    deleteLocalScript("library.ks").
} else {
  Print "Ship is not landed, aborting the launch script.".
}
print "Main program ended.".

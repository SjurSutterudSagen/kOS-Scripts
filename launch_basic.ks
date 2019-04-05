//  Basic launch script
//  Does not checks wether the planet you're on has an atmosphere or not
//  Simply launches to a 75k orbit
//  Warning: Requires connection to KSC throughout.

//  Declaring variables
set status to STATUS.
set archivePath to "0:/".
set localStorage to "1:/".
set archiveScriptsPath to archivePath + "launch/".
set archiveLibsPath to archivePath + "libs/".
set launchScriptName to "basic_launch_LKO.ks".
set libraryNameScript to "library.ks".
set executeNodeNameScript to "execute_maneuver_nodes.ks".

print "Warning: Requires connection to KSC throughout.".

if (status = "LANDED") or (status = "PRELAUNCH") {

    //  Copy the library to local storage and then run it
    copypath(archiveLibsPath + libraryNameScript, localStorage).
    runoncepath(libraryNameScript).

    //  loads the launch script, runs it, and then deletes it after use
    loadScript(archiveScriptsPath, launchScriptName).
    runoncepath(launchScriptName).
    deleteLocalScript(launchScriptName).

    //  loads the execute maneuver node script, runs it, and then deletes it afterwards
    loadScript(archivePath, executeNodeNameScript).
    runoncepath(executeNodeNameScript).
    deleteLocalScript(executeNodeNameScript).

    //  Delete the local library script
    deleteLocalScript(libraryNameScript).

} else {
  Print "Ship is not landed, aborting the launch script.".
}

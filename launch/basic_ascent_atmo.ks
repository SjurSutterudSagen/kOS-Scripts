//  Basic Ascent from Kerbin Script 0.1
//  Heavily inspired and/or copied from:
//  https://www.reddit.com/r/Kos/comments/705rx2/my_launch_script_a_work_in_progress/
//  Date: 2 April 2019.
//  Thank you to FafnerDeUrsine for sharing his launch script.

//  Parameters
parameter desiredApo.

//  Declaring variables.
set DONE to 0.
set LAUNCH to 1.
set GRAVITYTURN to 2.
set COASTTOAP to 3.
set CIRCULARICE to 4.

set Runmode to LAUNCH.
set TurnRate to 0.5.
set EndTurn to FALSE.
set Pitch to Heading(90, 0).
set Dv_ToCircle to 0.
set FinalAngle to 5.
LOCK Steering to Pitch.
set TurnStart to 0.

//  Check the desired apoapsis. If no desired apoapsis is supplied, 
//  default to 5000 above the hegiht of the atmosphere of the planet. 
//  If the desired apoapsis is lower than the height of the atmosphere
//  of the planet, add the desired apoapsis to the height of the atmosphere.
print "start apo check".
if desiredApo = FALSE {
  set targetApo to (BODY:ATM:HEIGHT + 5000).
  print "No desired Apoapsis provided. Setting the target apo to " + targetapo.
} else if desiredApo < BODY:ATM:HEIGHT {
  set targetApo to (BODY:ATM:HEIGHT + desiredApo).
  print "Desired apo is inside the atmosphere. Setting the target apo to " + targetapo.
} else {
  set TargetApo to desiredApo.
  print "no pblm m8".
}
print "end apo check".
set runmode to DONE.

//  Setting the ship to a known state
SAS off.
RCS off.
LIGHTS on.
LOCK THROTTLE to 0.
GEAR off.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
set steeringmanager:rollts to 8.  //  To reduce roll oscillations

//  Clearing the terminal screen
//CLEARSCREEN.

//
//  The Ascent Script Logic
//

//  Loop for the different phases of the launch
until Runmode = DONE {

  //  Stage when out of liquid fuel
  //  TODO: improve to include solid fuels.
  //  when currentMaxThrust < MaxThrust then stage?
  //WHEN STAGE:LIQUIDFUEL < 0.1 THEN {
  //    STAGE.
  //    PRESERVE.
  //}

  if Runmode = LAUNCH {

    //  This is our countdown loop, which cycles from 10 to 0
    PRINT "Counting down:".
    FROM {local countdown is 10.}
    UNTIL countdown = 0
      STEP {SET countdown to countdown - 1.}
      DO {
        PRINT "..." + countdown.
        WAIT 1. //  pauses the script here for 1 second.
    }

    LOCK THROTTLE to 1.
    set Pitch to Heading(90, 90).
    STAGE.
    //wait until APOAPSIS > 2000.
    wait until VESSEL:VERTICALSPEED > 100.

    if VESSEL:VERTICALSPEED > 100 {
      print "ship is moving up at more than 100m/s. test successfull.".
    }

    set TurnStart to TIME:SECONDS.
    set Runmode to GRAVITYTURN.

  } else if Runmode = GRAVITYTURN {

    

    set Runmode to COASTTOAP.

  } else if Runmode = COASTTOAP {


    set Runmode to CIRCULARICE.

  } else if Runmode = CIRCULARICE {


    set Runmode to DONE.

  }

  wait 0.01.

  //  Runmode launch
  //  Runmode Gravity Turn
  //  Runmode Coast to space(no atmo)
  //  Runmode create new man-node at AP + Circularice

}

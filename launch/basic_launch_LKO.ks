//  Basic Ascent from any planet script.
//  Warning: VERY basic, does not check several things

CLEARSCREEN.

//  Declaring variables
set targetApo to 75000.
set startTurnSpeed to 100.
set shipAlt to SHIP:ALTITUDE.
set shipThrottle to 0.
LOCK THROTTLE to shipThrottle.
set pitchAngle to 0.
LOCK steering to Heading(90, pitchAngle).
set dVToCircle to 0.
set circNode to 0.
set currentOrbit to 0.

//  Setting the ship to a known state
SAS off.
RCS off.
LIGHTS on.
set shipThrottle to 0.
GEAR off.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
set steeringmanager:rollts to 8.  //  To reduce roll oscillations

//
//  The Ascent Script Logic
//
//  This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 3.}
UNTIL countdown = 0
    STEP {SET countdown to countdown - 1.}
    DO {
    PRINT "..." + countdown.
    WAIT 1. //  pauses the script here for 1 second.
}

set pitchAngle to 90.
set shipThrottle to 1.
STAGE.

until APOAPSIS > targetApo {
    CLEARSCREEN.
    stageCheck().
    when SHIP:VERTICALSPEED > startTurnSpeed then {
        set pitchAngle to 85.
    }
    when shipAlt > 2500 then {
        set pitchAngle to 80.
    }
    when shipAlt > 5000 then {
        set pitchAngle to 70.
    }
    when shipAlt > 7500 then {
        set pitchAngle to 65.
    }
    when shipAlt > 10000 then {
        set pitchAngle to 55.
    }
    when shipAlt > 12500 then {
        set pitchAngle to 45.
    }
    when shipAlt > 20000 then {
        set pitchAngle to 35.
    }
    when shipAlt > 30000 then {
        set pitchAngle to 15.
    }
    when shipAlt > 40000 then {
        set pitchAngle to 5.
    }

    print "Pitch is: " + pitchAngle.
    print "Altitude is: " + shipAlt.
    print "Apoapsis is: " + APOAPSIS.
    wait 0. //    Wait for KSP physics tick
}
set shipThrottle to 0.
print "Apoapsis over 75000. Coasting to 70000.".
when shipAlt > 70000 then{
    set currentOrbit to OBT.
    set dVToCircle to sqrt( BODY:MU * ( 1 / ( currentOrbit:APOAPSIS + BODY:RADIUS ) ) )
        - sqrt( BODY:MU * ( (2 / (currentOrbit:APOAPSIS + BODY:RADIUS)) - (1 / currentOrbit:SEMIMAJORAXIS ) )).
    set circNode to NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dVToCircle).
    ADD circNode.
}

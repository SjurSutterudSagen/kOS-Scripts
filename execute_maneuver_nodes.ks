//  Script for executing maneuver nodes, does not account for
//  the changing of mass while performing the burn
//  It Is Crudeish

set nd to nextnode.

//  Print out node's basic parameters - ETA and deltaV
print "Node in: " + round(nd:eta) + ", required DeltaV: " + round(nd:deltav:mag).

//  Calculate the ship's maximum acceleration
set max_acc to ship:maxthrust/ship:mass.

//  Dividing the deltav:mag by the ship's maximum acceleration.
//  This is the "Crude" part.
set burnDuration to nd:deltav:mag/max_acc.
print "Estimated(crudely) burn duration is: " + round(burnDuration) + "s".

wait until nd:ETA <= (burnDuration/2 + 60). // 60 seconds before the burn, to allow slow ships to turn. RESEARCH how to auto-warp and check alignment of ship and node.

set np to nd:deltaV.  //  Points the ship towards the node.
lock steering to np.

//  Wait until the ship and maneuver node are aligned
wait until vang(np, ship:facing:vector) < 0.25.

//  wait until it is time to execute the burn
//  wait until nd:ETA <= (burnDuration/2).

//  Warp to start of burn
kuniverse:timewarp:warpto( nd:ETA <= (burnDuration/2 + 3) ).

set tset to 0.
lock throttle to tset.

set done to False.

//  Initial dV
set dv0 to nd:deltaV.

until done {

  //  recalculate the current max acceleration, because it changes while fuel is
  //  burned
  set max_acc to ship:maxthrust/ship:mass.

  //  The throttle is set to full until there is less than 1 second left of the
  //  burn, then decrease the throttle linearly
  set tset to min(nd:deltaV:mag/max_acc, 1).

  //  Need to cut the throttle as soon as our nd:deltaV and initial deltaV start
  //  facing opposite directions. The check is done via checking the dot product
  //  of those 2 vectors
  if vdot(dv0, nd:deltaV) < 0 {
    print "End of burn, remaining dv " + round(nd:deltaV:mag, 1) + "m/s, vdot: " + round( vdot(dv0, nd:deltaV), 1 ).
    lock throttle to 0.
    break.
  }

  //  Very little left to burn, less than 0.1m/s
  if nd:deltaV:mag < 0.1 {
    print "Finalizing burn, remaining dv: " + round(nd:deltaV:mag, 1) + "m/s, vdot: " + round( vdot(dv0, nd:deltaV), 1 ).

    //  Slow burn until the node vector starts to drift significantly from the
    //  initial vector, this usually means the burn is done.
    wait until vdot(dv0, nd:deltaV) < 0.5.

    lock throttle to 0.
    print "End of burn, remaining dv " + round(nd:deltaV:mag, 1) + "m/s, vdot: " + round( vdot(dv0, nd:deltaV), 1 ).
    set done to True.
  }

  //  Unlocking the ship's controls
  unlock steering.
  unlock throttle.
  wait 1.

  //  The maneuver node is done and can be removed
  remove nd.

  //  Set throttle to 0 just in case
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

}

//Launch program for multistage rocket

			Clearscreen.

			set pilotmainthrottle to 0. //sets throttle to 0 after program is run. 

			//Setting ship to known condidtion. 
			SAS off.
			RCS off.
			lights on.
			lock throttle to 0. 
			gear off.
			SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
			set steeringmanager:rollts to 8. //To reduce roll oscillations

			//Global Vars
			Global RUNMODE to 1.
			Global TurnRate to 0.5.
			Global TargetApo to 200000.
			Global EndTurn to FALSE.
			Global Pitch to Heading (90,0).
			Global Dv_ToCircle to 0.
			Global FinalAngle to 5.
			Lock Steering to Pitch.


			DECLARE function StageBooster  //used to stage boosters
				{
				//STAGING
						LIST ENGINES IN StageTrigger.
						set counteng to 0.
						set activeeng to 0.
							FOR eng IN StageTrigger 
								{
									IF eng:flameout AND eng:ignition //Checks if engines have been ignited and have flameded out. 
										{
											STAGE.
											BREAK.
										}
										//Checks if engines currently on ship have been ignited, if no engines have been ignited then stage.
										//For stageing through couplings and other non engine stages. 
										if not eng:ignition 
											{set activeeng to activeeng + 1.}
										
										set counteng to counteng + 1.
						
								}
					
						if counteng = activeeng
							{Stage.}
				}
				

			//Main Launch Loop

			UNTIL RUNMODE = 0
			{
			//Launch. 

				if runmode = 1
					{
						PRINT "Counting down:".
						FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO { PRINT "..." + countdown. 
								Wait 1.}
						WAIT 1. 
						PRINT "IGNITION!!".
						LOCK Throttle to 1.
						Set Pitch to Heading(90,90).
						STAGE.
						PRINT "Waiting for Max Thrust.".
						WAIT 2.
						STAGE.
						PRINT "Releaseing anchors.".
						PRINT "Waiting to clear tower.".
						Wait until APOAPSIS > 2000.
						CLEARSCREEN. 
						Global TurnStart to TIME:SECONDS.
						set runmode to 2.

					}
					
				
			//Burn to Apo
				
				else if runmode = 2
					{
					//Grav Turn
					StageBooster().
					if EndTurn = FALSE
						{
						Set elapsedTime to (TIME:SECONDS - TurnStart).
						SET Pitch to Heading(90, 90*(1-(SHIP:ALTITUDE/(150000)))).
						PRINT Pitch.
						if Pitch:PITCH < FinalAngle
							{ set EndTurn to TRUE.}
						}
					if EndTurn = TRUE
						{ set Pitch to Heading(90,FinalAngle). } 
						
					if APOAPSIS > TargetApo 
						{
						set runmode to 3.
						}
						
				
					}
					
				else if runmode = 3
					{
					LOCK Throttle to 0.
					WAIT 1.
					STAGE. //To remove booster.
					RCS ON. //Give upper stage attatude control. 
					wait until ALTITUDE > 140000. //Coast to space.
					SET IntOrbit to OBT.
					//Delta V to circlize.
					SET Dv_ToCircle to sqrt(body:mu * (1/(IntOrbit:APOAPSIS + BODY:RADIUS))) - sqrt(body:mu * ((2/(IntOrbit:APOAPSIS + BODY:RADIUS)) - (1/IntOrbit:SEMIMAJORAXIS))).
					SET NODE_1 to NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, Dv_ToCircle).
					ADD NODE_1.
					set runmode to 4.
					}
						
				else if runmode = 4
					{
					UNLOCK Steering.
					SAS ON.
					WAIT 1.
					Set SASMODE to "MANEUVER".
					set CirNODE to NEXTNODE.
					set BurnTime to (CirNODE:deltav:mag * ship:mass)/ship:maxthrust. //Estamating burn time for circlizeing.
					wait until vang(CirNODE:deltav:normalized, facing:vector:normalized) < 5. //Making sure the ship is pointing in the correct direction.
					wait until CirNODE:eta <= (BurnTime/2).
					set ThrottleControl to 1.
					LOCK Throttle to ThrottleControl.
					set CirNODE_INT_DV to CirNODE:deltav.
					set runmode to 5.
					}
					
				else if runmode = 5
					{
					
					StageBooster().

					//Throttle Control for the maneuver node.
					set ThrottleControl to min((CirNODE:deltav:mag * ship:mass)/ship:maxthrust,1).
							
							if vdot(CirNODE_INT_DV, CirNODE:deltav) < 0 
								{
								LOCK Throttle to 0.
						
								}
					
							if CirNODE:deltav:mag < 0.1
								{
								wait until vdot(CirNODE_INT_DV, CirNODE:deltav) < 0.5.
								LOCK Throttle to 0.
								REMOVE NODE_1.
								set runmode to 0.
								}
							
					
					}
					
				
			wait 0.01.	
			}
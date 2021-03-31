// RTLS v0.2
// DEPENDANCIES: KOS, TRAJECTORIES, FALL scripts for kos (https://smoketeer.github.io/fall/)
// models and controllers used were from fall.
// author of FALL: smoketeer
// RTLS author: sushiboi


runOncePath("0:/fall/utilities/importfall").
importFall("landingdatamodel"). // this are the models and controllers used from FALL
importFall("boostbackcontroller").
importFall("hoverslammodel").
importFall("glidecontroller").
importFall("landingcontroller").
// ---------------------------------custom variables----------------------------------------------------------

set landingzone1 to latlng(-0.212961986660957, -74.5141830444336). // target positions
set landingzone2 to latlng(-0.238098815083504, -74.5141677856445).
set targetlocation to landingzone1. // set which target to land on
local ldata is landingdatamodel(targetlocation). // registering final target location upon start-up 
clearScreen.
print "RTLS v0.1".
print "AG10 to begin RTLS sequence".
wait until ag10.
toggle ag10.
toggle ag1. // turns off 2/5 engines

//-------------------------------------------BOOSTBACK--------------------------------------------------------

print "Boostback start-up".
set boostbackdir to facing:yaw + 180.
set boostbackzone to 3.
set boostback to true.
lock steering to heading(targetlocation:heading, 0).
print "reorientating".
wait 15.
lock throttle to 1.
print "boostback burn start". //___________________________ BOOSTBACK BURN __________________________________________
wait until ldata["errorvector"]() < 10000.
lock throttle to 0.7.
print "current impact spot is approaching zone 3".
wait until ldata["errorvector"]() < 5000.
print "boostback close to completion".
until boostback = false {
    //............................................. ZONE 3 .....................................................
    if ldata["errorvector"]() < 3000 and boostbackzone = 3 {
        lock throttle to 0.5.
        set boostbackzone to 2.
        
    } else {
        if ldata["errorvector"]() > 3005 and boostbackzone = 2 {
            lock throttle to 0.
            print "boostback complete, boostback accuracy is fairly accurate".
            set boostback to false.
     }

    }
    //............................................. ZONE 2 ......................................................
    if ldata["errorvector"]() < 2000 and boostbackzone = 2 {
           lock steering to heading(boostbackdir, 0).
           lock throttle to 0.2.
           set boostbackzone to 1.

       } else {
           if ldata["errorvector"]() > 2005 and boostbackzone = 1 {
               lock throttle to 0.
               print "boostback complete, boostback accuracy is accurate".
               set boostback to false.
           }
       }
    //.............................................. ZONE 1 ......................................................
       if ldata["errorvector"]() < 1000 and boostbackzone = 1 {
               lock throttle to 0.
               print "boostback complete, boostback accuracy is very accurate".
               set boostback to false.
           }
    
    // DETECTS IF IMPACT SPOT EXITS ZONE 3
    if ldata["errorvector"]() > 5005. {
        print "boostback error".
        print "boostback abort".
        lock throttle to 0.
        print "boostback accuracy is inaccurate".
        print "switching to glide program".
        set boostback to false.
    }
 }



//------------------------------------------GLIDE-------------------------------------------------------------
// glide prep
set errorscalingglide to 1.
set glidingaoa to 30.
when alt:radar < 6000 then { set glidingaoa to 10. }
when alt:radar < 25000 then { set errorscalingglide to 0.4. }
local glide is glidecontroller(ldata, glidingaoa, errorscalingglide). // max AOA is glidingaoa, errorscaling is errorscalingglide

//gliding
wait until ship:verticalspeed < 0.
when altitude < 70000 then { brakes on. }
rcs on.
when alt:radar < 30000 then { rcs off. print "rcs off". } // grid fins full control
when alt:radar < 1000 then { rcs on. } // RCS restart
when alt:radar < 300 then  { gear on. } // landing legs deploy

lock steering to glide["getsteering"]().
print "gliding".

//------------------------------------------LANDING_BURN-----------------------------------------------------
// landing prep
lock maxacc to maxThrust / mass. // maximum decceleration engines are capable of
lock g to constant:g * body:mass / body:radius^2. // gravity constant
set touchdownvel to 3. // target velocity by the time booster makes contact with landing-zone/barge
set errorscaling to 1.
when alt:radar < 2300 then { set errorscaling to 0.5. }
local hoverslam is hoverslammodel(45).
local landing is landingcontroller(ldata, hoverslam, 20, errorscaling).
lock throttle to landing["getthrottle"]().

// landing
wait until throttle > 0.
print "landing throttle = active".
wait 0.3.
toggle ag1. // 5/5 engines are on
lock steering to landing["getsteering"]().
print "landing steering = active".
when alt:radar < 90 then { lock throttle to (g - (touchdownvel + verticalSpeed)) / maxacc. }
when ship:verticalspeed > -15 then { lock steering to lookDirUp(up:vector, facing:topvector). }

wait until landing["completed"](). // waits until system confirms landing
lock throttle to 0.
rcs on.
print "landed".
print "AGL is " + alt:radar.
hudtext("LEO7 has landed", 10, 2, 25, green, false).
lock steering to up.
print "shutting down in 20 seconds".
wait 20.
shutdown.




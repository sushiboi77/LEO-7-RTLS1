// RTLS v0.1
// DEPENDANCIES: KOS, TRAJECTORIES, FALL Module for kos (https://smoketeer.github.io/fall/)
// models and controllers used were from fall.
// author of FALL: smoketeer
// RTLS author: sushiboi


runOncePath("0:/fall/utilities/importfall").
importFall("landingdatamodel").
importFall("boostbackcontroller").
importFall("hoverslammodel").
importFall("glidecontroller").
importFall("landingcontroller").

set landingzone1 to latlng(-0.212961986660957, -74.5141830444336). // target positions
set landingzone2 to latlng(-0.238098815083504, -74.5141677856445).
local ldata is landingdatamodel(landingzone1). // set which target to land on
clearScreen.
print "RTLS v0.1".
print "AG10 to begin RTLS sequence".
wait until ag10.
ag10 off.
ag1 on.
ag1 off. // turns of 2/5 engines

//-------------------------------------------BOOSTBACK--------------------------------------------------------
//boostback prep
print "pre-boostback".
local boostback is boostbackcontroller(ldata, 0.5).
rcs on.
print "RCS ON".

//boostback
print "boostback".
lock steering to boostback["getsteering"]().
print "re-orieantating".
wait 20.
hudtext("BOOSTBACK", 5, 2, 15, blue, false).
lock throttle to boostback["getthrottle"]().
print "boostback burn starup".

wait until boostback["completed"]().
print "boostback burn shutdown".

//------------------------------------------GLIDE------------------------------------------------------------
// glide prep
set errorscalingglide to 1.5.
when alt:radar < 20000 then { set errorscalingglide to 0.5. }
local glide is glidecontroller(ldata, 25, errorscalingglide).

//gliding
wait until ship:verticalspeed < 0.
brakes on.
rcs on.
when alt:radar < 20000 then { rcs off. print "rcs off". }
when alt:radar < 1000 then { rcs on. }
when alt:radar < 100 then  { gear on. }

lock steering to glide["getsteering"]().
print "gliding".

//------------------------------------------LANDING_BURN-----------------------------------------------------
// landing prep
set errorscaling to 1.
when alt:radar < 600 then { set errorscaling to 0.5. }
local hoverslam is hoverslammodel(35).
local landing is landingcontroller(ldata, hoverslam, 30, errorscaling).
lock throttle to landing["getthrottle"]().
print "landing throttle = active".

// landing
wait until throttle > 0 and alt:radar < 7000.
lock steering to landing["getsteering"]().
print "landing steering = active".

wait until landing["completed"]().
lock throttle to 0.
rcs on.
print "landed".
hudtext("LEO7 has landed", 5, 2, 15, green, false).
lock steering to up.
print "shutting down in 20 seconds".
wait 20.
shutdown.



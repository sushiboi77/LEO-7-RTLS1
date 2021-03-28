runOncePath("0:/fall/utilities/importfall").
importFall("landingdatamodel").
importFall("boostbackcontroller").
importFall("hoverslammodel").
importFall("glidecontroller").
importFall("landingcontroller").

local ldata is landingdatamodel(latlng(-0.212961986660957, -74.5141830444336)).
sas on.
rcs on.
clearScreen.
print "switched to main flight computer".
print "AG10 to start". // waiting for AG10 to initiate hop
wait until ag10.
hudtext("hop initiated", 5, 2, 15, green, false).
rcs on.
wait 1.
stage.
print "ignition".
lock throttle to 1.
sas off.
lock steering to heading(latlng(-0.212961986660957, -74.5141830444336):heading, 87). // craft is slowly moving towards target
print "craft is translating towards target".
print "AG2 to face up".
when ag2 then { lock steering to up. } // face up
wait 3.
gear off.
print "gear retract".
rcs off.

wait until ship:apoapsis > 20000.
lock throttle to 0.
print "MECO".
ag1 on.
ag1 off. // side engine shutdown

// glide prep
local glide is glidecontroller(ldata, 40, 2). // AOA is 40, errorscaling is 2
print "gliding program startup".

//gliding
print "active gliding".
wait until ship:verticalspeed < 0.
rcs on.
brakes on.
when alt:radar < 1500 then { rcs off. }
when alt:radar < 170 then  { gear on. }

lock steering to glide["getsteering"](). // steering lock to glide controller
print "active steering control".

// landing prep
print "waiting for landing program activation".
wait 3.
local hoverslam is hoverslammodel(35).
local landing is landingcontroller(ldata, hoverslam, 5, 0.4). // AOA is 5, errorscaling is 0.4
lock throttle to landing["getthrottle"]().

// landing
wait until throttle > 0 and alt:radar < 7000. // switches steering control to landing when throttle > 0
lock steering to landing["getsteering"]().
print "landing program initiated".

wait until landing["completed"](). 
lock throttle to 0. // throttle off when landing complete
rcs off.
print "LEO7 hopper has successfully landed".
lock steering to up.
rcs on.
lock throttle to 0.
print "shutdown in 20 sec".
wait 20.
shutdown.

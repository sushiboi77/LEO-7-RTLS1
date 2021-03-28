@lazyglobal off.
// landingPIDController ::
//     landingData ->
//     hoverslam ->
//     float* ->
//     float* ->
//     float* ->
//     float* ->
//     float* ->
//     landingPIDController
function landingPIDController {
    parameter ldata,
              hslam,
              Kp is 0,
              Ki is 0,
              Kd is 0,
              minOut is -10,
              maxOut is 10.

    local yawPid is pidloop(Kp, Ki, Kd, minOut, maxOut).
    local pitchPid is pidloop(Kp, Ki, Kd, minOut, maxOut).
    set yawPid:setpoint to 0.
    set pitchPid:setpoint to 0.

    // private pidOutput :: nothing -> direction
    function pidOutput {
        local yaw is yawPid:update(time:seconds, ldata["lngError"]()).
        local pitch is pitchPid:update(time:seconds, ldata["latError"]()).

        return R(pitch, yaw, 0).
    }

    // public getSteering :: nothing -> direction
    function getSteering {
        local velDir is lookdirup(-velocity:surface, facing:topvector).
        return velDir - pidOutput().
    }

    // public getThrottle :: nothing -> float
    function getThrottle { return hslam["getThrottle"](). }

    // public completed :: nothing -> bool
    function completed {
        return ship:status = "landed" or ship:status = "splashed".
    }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs powered landing maneuver
        parameter isUnlocking is true.

        lock steering to getSteering().
        lock throttle to getThrottle().
        wait until completed().

        if isUnlocking { unlock throttle. unlock steering. }
    }

    // Return Public Fields
    return lexicon(
        "getSteering", getSteering@,
        "getThrottle", getThrottle@,
        "completed", completed@,
        "passControl", passControl@
    ).
}

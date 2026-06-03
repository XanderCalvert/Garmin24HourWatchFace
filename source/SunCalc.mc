// Sun position calculations (LGPL-2.1) — https://github.com/haraldh/SunCalc
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.Time;

//! Indices into the SunCalc TIMES table.
module SunCalcEvents {
    const DAWN = 2;
    const SUNRISE = 4;
    const SUNSET = 10;
    const DUSK = 12;
}

class SunCalc {

    hidden const PI = Math.PI;
    hidden const RAD = Math.PI / 180.0;
    hidden const PI2 = Math.PI * 2.0;
    hidden const DAYS = Time.Gregorian.SECONDS_PER_DAY;
    hidden const J1970 = 2440588;
    hidden const J2000 = 2451545;
    hidden const J0 = 0.0009;
    hidden const NOON = 7;

    hidden const TIMES = [
        -18 * RAD,
        -12 * RAD,
        -6 * RAD,
        -4 * RAD,
        -0.833 * RAD,
        -0.3 * RAD,
        6 * RAD,
        null,
        6 * RAD,
        -0.3 * RAD,
        -0.833 * RAD,
        -4 * RAD,
        -6 * RAD,
        -12 * RAD,
        -18 * RAD
    ];

    var lastD;
    var lastLng;
    var n;
    var ds;
    var M;
    var sinM;
    var C;
    var L;
    var sin2L;
    var dec;
    var Jnoon;

    function initialize() {
        lastD = null;
        lastLng = null;
    }

    function calculate(moment as Time.Moment, pos as [Lang.Double, Lang.Double], what as Number) as Time.Moment or Null {
        var lat = pos[0];
        var lng = pos[1];
        var d = moment.value().toDouble() / DAYS - 0.5 + J1970 - J2000;

        if (lastD != d || lastLng != lng) {
            n = round(d - J0 + lng / PI2);
            ds = J0 - lng / PI2 + n - 1.1574e-5 * 68;
            M = 6.240059967 + 0.0172019715 * ds;
            sinM = Math.sin(M);
            C = (1.9148 * sinM + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M)) * RAD;
            L = M + C + 1.796593063 + PI;
            sin2L = Math.sin(2 * L);
            dec = Math.asin(0.397783703 * Math.sin(L));
            Jnoon = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
            lastD = d;
            lastLng = lng;
        }

        if (what == NOON) {
            return fromJulian(Jnoon);
        }

        var x = (Math.sin(TIMES[what]) - Math.sin(lat) * Math.sin(dec)) / (Math.cos(lat) * Math.cos(dec));

        if (x > 1.0 || x < -1.0) {
            return null;
        }

        ds = J0 + (Math.acos(x) - lng) / PI2 + n - 1.1574e-5 * 68;
        var Jset = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;

        if (what > NOON) {
            return fromJulian(Jset);
        }

        var Jrise = Jnoon - (Jset - Jnoon);
        return fromJulian(Jrise);
    }

    hidden function fromJulian(j as Lang.Double) as Time.Moment {
        return new Time.Moment(((j + 0.5 - J1970) * DAYS).toNumber());
    }

    hidden function round(a as Lang.Double) as Lang.Float {
        if (a > 0) {
            return (a + 0.5).toNumber().toFloat();
        }
        return (a - 0.5).toNumber().toFloat();
    }
}

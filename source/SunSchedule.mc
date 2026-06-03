import Toybox.Activity;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;

//! Sunrise/sunset schedule from GPS and SunCalc (Weather when available).
module SunSchedule {

    const PHASE_UNKNOWN = -1;
    const PHASE_NIGHT = 0;
    const PHASE_DAWN = 1;
    const PHASE_DAY = 2;
    const PHASE_DUSK = 3;

    const STORAGE_DAY = "sunDay";
    const STORAGE_LOC = "sunLoc";
    const STORAGE_DAWN = "dawn";
    const STORAGE_SUNRISE = "sunrise";
    const STORAGE_SUNSET = "sunset";
    const STORAGE_DUSK = "dusk";
    const STORAGE_LAT = "cachedLat";
    const STORAGE_LON = "cachedLon";

    var _sunCalc as SunCalc or Null = null;

    function refresh() as Void {
        var location = resolveLocation();
        if (location == null) {
            return;
        }

        var today = Time.today();
        var dayValue = today.value();
        var locKey = locationKey(location);
        var cachedDay = Storage.getValue(STORAGE_DAY);
        var cachedLoc = Storage.getValue(STORAGE_LOC);
        var cachedDawn = Storage.getValue(STORAGE_DAWN);

        if (cachedLoc != null && !cachedLoc.equals(locKey)) {
            clearSunEventStorage();
            cachedDawn = null;
        }

        if (cachedDay != null && cachedDay == dayValue && cachedDawn != null) {
            return;
        }

        if (!cacheSunEventsFromWeather(location, today)) {
            if (!cacheSunEvents(location, today)) {
                cacheFallbackSunEvents(location, today);
            }
        }
    }

    function ensureSunEvents() as Boolean {
        refresh();
        if (hasSunEvents()) {
            return true;
        }
        var location = resolveLocation();
        if (location != null) {
            cacheFallbackSunEvents(location, Time.today());
        }
        return hasSunEvents();
    }

    function clearSunEventStorage() as Void {
        Storage.deleteValue(STORAGE_DAY);
        Storage.deleteValue(STORAGE_DAWN);
        Storage.deleteValue(STORAGE_SUNRISE);
        Storage.deleteValue(STORAGE_SUNSET);
        Storage.deleteValue(STORAGE_DUSK);
    }

    function hasSunEvents() as Boolean {
        return Storage.getValue(STORAGE_DAWN) != null
            && Storage.getValue(STORAGE_SUNRISE) != null
            && Storage.getValue(STORAGE_SUNSET) != null
            && Storage.getValue(STORAGE_DUSK) != null;
    }

    function getDawn() as Time.Moment or Null {
        return momentFromStorage(STORAGE_DAWN);
    }

    function getSunrise() as Time.Moment or Null {
        return momentFromStorage(STORAGE_SUNRISE);
    }

    function getSunset() as Time.Moment or Null {
        return momentFromStorage(STORAGE_SUNSET);
    }

    function getDusk() as Time.Moment or Null {
        return momentFromStorage(STORAGE_DUSK);
    }

    function getPhase(now as Time.Moment) as Number {
        refresh();

        var phase = phaseFromSunTimes(now);
        if (phase != PHASE_UNKNOWN) {
            return phase;
        }

        return estimatePhaseFromClock(now);
    }

    //! Same 24h dial mapping as the hand: 00:00 at bottom, 12:00 at top.
    function momentToArcDegrees(moment as Time.Moment) as Number {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return minutesToDialArcDegrees(info.hour * 60 + info.min);
    }

    function minutesToDialArcDegrees(minutes as Number) as Number {
        return normalizeDegrees(((minutes * 360) / 1440) + 90);
    }

    function arcSpanDegrees(startDeg as Number, endDeg as Number) as Number {
        if (endDeg >= startDeg) {
            return endDeg - startDeg;
        }
        return (360 - startDeg) + endDeg;
    }

    function phaseFromSunTimes(now as Time.Moment) as Number {
        var dawn = getDawn();
        var sunrise = getSunrise();
        var sunset = getSunset();
        var dusk = getDusk();

        if (dawn == null || sunrise == null || sunset == null || dusk == null) {
            return PHASE_UNKNOWN;
        }

        if (now.lessThan(dawn) || now.greaterThan(dusk)) {
            return PHASE_NIGHT;
        }
        if (now.lessThan(sunrise)) {
            return PHASE_DAWN;
        }
        if (now.lessThan(sunset)) {
            return PHASE_DAY;
        }
        if (now.lessThan(dusk)) {
            return PHASE_DUSK;
        }

        return PHASE_NIGHT;
    }

    function estimatePhaseFromClock(now as Time.Moment) as Number {
        var hour = Gregorian.info(now, Time.FORMAT_SHORT).hour;

        if (hour >= 7 && hour < 9) {
            return PHASE_DAWN;
        }
        if (hour >= 9 && hour < 17) {
            return PHASE_DAY;
        }
        if (hour >= 17 && hour < 20) {
            return PHASE_DUSK;
        }

        return PHASE_NIGHT;
    }

    function cacheSunEvents(location as Position.Location, today as Time.Moment) as Boolean {
        var events = calculateSunEvents(location);
        if (events == null) {
            return false;
        }

        storeSunEvents(today, location, events[0], events[1], events[2], events[3]);
        return true;
    }

    function cacheSunEventsFromWeather(location as Position.Location, today as Time.Moment) as Boolean {
        if (!(Toybox has :Weather)) {
            return false;
        }

        var sunrise = Weather.getSunrise(location, today);
        var sunset = Weather.getSunset(location, today);

        if (sunrise == null || sunset == null) {
            return false;
        }

        var dawn = sunrise;
        var dusk = sunset;
        var calcEvents = calculateSunEvents(location);

        if (calcEvents != null) {
            dawn = calcEvents[0];
            dusk = calcEvents[3];
        }

        storeSunEvents(today, location, dawn, sunrise, sunset, dusk);
        return true;
    }

    function cacheFallbackSunEvents(location as Position.Location, today as Time.Moment) as Void {
        var events = calculateSunEvents(location);
        if (events != null) {
            storeSunEvents(today, location, events[0], events[1], events[2], events[3]);
            return;
        }

        var dawn = momentAtLocalTime(6, 0);
        var sunrise = momentAtLocalTime(7, 0);
        var sunset = momentAtLocalTime(19, 0);
        var dusk = momentAtLocalTime(20, 0);
        storeSunEvents(today, location, dawn, sunrise, sunset, dusk);
    }

    function calculateSunEvents(location as Position.Location) as [Time.Moment, Time.Moment, Time.Moment, Time.Moment] or Null {
        if (_sunCalc == null) {
            _sunCalc = new SunCalc();
        }

        var radians = locationToRadiansArray(location);
        var now = Time.now();
        var dawn = _sunCalc.calculate(now, radians, SunCalcEvents.DAWN);
        var sunrise = _sunCalc.calculate(now, radians, SunCalcEvents.SUNRISE);
        var sunset = _sunCalc.calculate(now, radians, SunCalcEvents.SUNSET);
        var dusk = _sunCalc.calculate(now, radians, SunCalcEvents.DUSK);

        if (dawn == null || sunrise == null || sunset == null || dusk == null) {
            return null;
        }

        return [dawn, sunrise, sunset, dusk] as [Time.Moment, Time.Moment, Time.Moment, Time.Moment];
    }

    function storeSunEvents(
        today as Time.Moment,
        location as Position.Location,
        dawn as Time.Moment,
        sunrise as Time.Moment,
        sunset as Time.Moment,
        dusk as Time.Moment
    ) as Void {
        Storage.setValue(STORAGE_DAY, today.value());
        Storage.setValue(STORAGE_LOC, locationKey(location));
        Storage.setValue(STORAGE_DAWN, dawn.value());
        Storage.setValue(STORAGE_SUNRISE, sunrise.value());
        Storage.setValue(STORAGE_SUNSET, sunset.value());
        Storage.setValue(STORAGE_DUSK, dusk.value());
    }

    function resolveLocation() as Position.Location or Null {
        if (Toybox has :Position) {
            var positionInfo = Position.getInfo();
            if (positionInfo != null && positionInfo.position != null) {
                if (positionInfo.accuracy != Position.QUALITY_NOT_AVAILABLE) {
                    return cacheLocation(positionInfo.position);
                }
            }
        }

        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null && activityInfo.currentLocation != null) {
            return cacheLocation(activityInfo.currentLocation);
        }

        if (Toybox has :Weather) {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null && conditions.observationLocationPosition != null) {
                return cacheLocation(conditions.observationLocationPosition);
            }
        }

        var lat = Storage.getValue(STORAGE_LAT);
        var lon = Storage.getValue(STORAGE_LON);

        if (lat != null && lon != null) {
            return new Position.Location({
                :latitude => lat,
                :longitude => lon,
                :format => :degrees
            });
        }

        return null;
    }

    function cacheLocation(location as Position.Location) as Position.Location {
        var degrees = location.toDegrees();
        Storage.setValue(STORAGE_LAT, degrees[0]);
        Storage.setValue(STORAGE_LON, degrees[1]);
        return location;
    }

    function locationKey(location as Position.Location) as String {
        var degrees = location.toDegrees();
        return degrees[0].format("%.4f") + "," + degrees[1].format("%.4f");
    }

    function locationToRadiansArray(location as Position.Location) as [Lang.Double, Lang.Double] {
        var radians = location.toRadians();
        return [radians[0].toDouble(), radians[1].toDouble()];
    }

    function momentAtLocalTime(hour as Number, minute as Number) as Time.Moment {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return Gregorian.moment({
            :year => today.year,
            :month => today.month,
            :day => today.day,
            :hour => hour,
            :minute => minute,
            :second => 0
        });
    }

    function momentFromStorage(key as String) as Time.Moment or Null {
        var value = Storage.getValue(key);
        if (value == null) {
            return null;
        }
        return new Time.Moment(value);
    }

    function normalizeDegrees(degrees as Number) as Number {
        var normalized = degrees % 360;
        if (normalized < 0) {
            normalized += 360;
        }
        return normalized;
    }
}

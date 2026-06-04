import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.System;

//! Centre digital time and subtle stats (steps, battery).
module DataFields {

    const BATTERY_INDICATOR_NONE = 0;
    const BATTERY_INDICATOR_WARN = 1;
    const BATTERY_INDICATOR_CRITICAL = 2;
    const BATTERY_WARN_PERCENT = 20;
    const BATTERY_CRITICAL_PERCENT = 10;

    function formatDigitalTime(clockTime as System.ClockTime) as String {
        var hour = clockTime.hour;
        var suffix = "";

        if (!Theme.use24HourDigital()) {
            suffix = hour >= 12 ? " PM" : " AM";
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        return Lang.format("$1$:$2$$3$", [
            formatTwoDigits(hour),
            formatTwoDigits(clockTime.min),
            suffix
        ]);
    }

    //! Returns null if ActivityMonitor is unavailable or steps are unknown.
    function getStepCount() as Number or Null {
        if (!(Toybox has :ActivityMonitor)) {
            return null;
        }

        var info = ActivityMonitor.getInfo();
        if (info == null || info.steps == null) {
            return null;
        }

        return info.steps;
    }

    function getBatteryPercent() as Number or Null {
        var stats = System.getSystemStats();
        if (stats == null || stats.battery == null) {
            return null;
        }

        return stats.battery.toNumber();
    }

    function formatBatteryPercent() as String or Null {
        var percent = getBatteryPercent();
        if (percent == null) {
            return null;
        }

        return percent.format("%d") + "%";
    }

    //! Bottom tick hint when battery % is hidden (see PLAN battery awareness).
    function getBatteryIndicatorLevel() as Number {
        if (Theme.showBattery()) {
            return BATTERY_INDICATOR_NONE;
        }

        var percent = getBatteryPercent();
        if (percent == null) {
            return BATTERY_INDICATOR_NONE;
        }
        if (percent <= BATTERY_CRITICAL_PERCENT) {
            return BATTERY_INDICATOR_CRITICAL;
        }
        if (percent <= BATTERY_WARN_PERCENT) {
            return BATTERY_INDICATOR_WARN;
        }
        return BATTERY_INDICATOR_NONE;
    }

    function hasStatsLine() as Boolean {
        return formatStatsLine() != null;
    }

    //! Steps and battery on one line, separated when both are available.
    function formatStatsLine() as String or Null {
        var parts = [] as Array<String>;

        if (Theme.showSteps()) {
            var steps = getStepCount();
            if (steps != null) {
                parts.add(steps.format("%d"));
            }
        }

        if (Theme.showBattery()) {
            var batteryText = formatBatteryPercent();
            if (batteryText != null) {
                parts.add(batteryText);
            }
        }

        if (parts.size() == 0) {
            return null;
        }
        if (parts.size() == 1) {
            return parts[0];
        }

        return parts[0] + "  " + parts[1];
    }

    function formatTwoDigits(value as Number) as String {
        if (value < 10) {
            return "0" + value.format("%d");
        }
        return value.format("%d");
    }
}

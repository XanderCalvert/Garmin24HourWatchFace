import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

//! Light/dark palettes for dial, text, and sun ring (manual or follow device).
module Theme {

    const THEME_DARK = 0;
    const THEME_LIGHT = 1;
    const THEME_AUTO = 2;

    function getThemeId() as Number {
        return Properties.getValue("Theme");
    }

    //! True when the face should use a light background and dark foreground.
    function isLightTheme() as Boolean {
        var themeId = getThemeId();
        if (themeId == THEME_LIGHT) {
            return true;
        }
        if (themeId == THEME_DARK) {
            return false;
        }
        return followsDeviceLightTheme();
    }

    function followsDeviceLightTheme() as Boolean {
        if (!(System has :getDeviceSettings)) {
            return false;
        }

        var settings = System.getDeviceSettings();
        if (settings == null || !(settings has :isNightModeEnabled)) {
            return false;
        }

        // Device night mode uses dark backgrounds; day mode uses light.
        return !settings.isNightModeEnabled;
    }

    function getBackgroundColor() {
        return isLightTheme() ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    }

    function getTickColor() {
        return isLightTheme() ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY;
    }

    function getHandColor() {
        return isLightTheme() ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function getDigitalColor() {
        return isLightTheme() ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function getMutedColor() {
        return isLightTheme() ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY;
    }

    function getStatsColor() {
        return getMutedColor();
    }

    function getTextOutlineColor() {
        return getBackgroundColor();
    }

    function getDigitalTimeMode() as Number {
        return DisplaySettings.readMode(DisplaySettings.PROP_DIGITAL_TIME);
    }

    function getStepsMode() as Number {
        return DisplaySettings.readMode(DisplaySettings.PROP_STEPS);
    }

    function getBatteryMode() as Number {
        return DisplaySettings.readMode(DisplaySettings.PROP_BATTERY);
    }

    function getDateMode() as Number {
        return DisplaySettings.readMode(DisplaySettings.PROP_DATE);
    }

    function showDigitalTime() as Boolean {
        return getDigitalTimeMode() != DisplaySettings.MODE_HIDDEN;
    }

    function use24HourDigital() {
        return Properties.getValue("Use24Hour");
    }

    function showSteps() as Boolean {
        return DataFields.shouldShowSteps();
    }

    function showBattery() as Boolean {
        var mode = getBatteryMode();
        return mode == DisplaySettings.MODE_SMALL || mode == DisplaySettings.MODE_LARGE;
    }

    function showDate() as Boolean {
        return getDateMode() != DisplaySettings.MODE_HIDDEN;
    }

    function hasVisibleHudContent() as Boolean {
        return showDigitalTime()
            || showSteps()
            || showBattery()
            || showDate();
    }

    function showSunBorder() {
        return Properties.getValue("ShowSunBorder");
    }

    function getBatteryIndicatorTickColor() {
        return Graphics.COLOR_RED;
    }

    function getBatteryTextColor() {
        if (DataFields.getBatteryAlertLevel() == DataFields.BATTERY_INDICATOR_CRITICAL) {
            return getBatteryIndicatorTickColor();
        }
        return getStatsColor();
    }

    function getSunBorderColor(phase) {
        if (isLightTheme()) {
            return getSunBorderColorLight(phase);
        }
        return getSunBorderColorDark(phase);
    }

    function getSunBorderColorDark(phase) {
        if (phase == SunSchedule.PHASE_DAY) {
            return Graphics.COLOR_YELLOW;
        }
        if (phase == SunSchedule.PHASE_DAWN || phase == SunSchedule.PHASE_DUSK) {
            return Graphics.COLOR_ORANGE;
        }
        if (phase == SunSchedule.PHASE_NIGHT) {
            return Graphics.COLOR_BLUE;
        }
        return Graphics.COLOR_BLUE;
    }

    function getSunBorderColorLight(phase) {
        if (phase == SunSchedule.PHASE_DAY) {
            return Graphics.COLOR_YELLOW;
        }
        if (phase == SunSchedule.PHASE_DAWN || phase == SunSchedule.PHASE_DUSK) {
            return Graphics.COLOR_ORANGE;
        }
        if (phase == SunSchedule.PHASE_NIGHT) {
            return Graphics.COLOR_DK_BLUE;
        }
        return Graphics.COLOR_DK_BLUE;
    }

}

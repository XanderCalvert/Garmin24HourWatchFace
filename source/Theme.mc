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

    function showDigitalTime() {
        return Properties.getValue("ShowDigitalTime");
    }

    function use24HourDigital() {
        return Properties.getValue("Use24Hour");
    }

    function showSteps() {
        return Properties.getValue("ShowSteps");
    }

    function showBattery() {
        return Properties.getValue("ShowBattery");
    }

    function showDate() {
        return Properties.getValue("ShowDate");
    }

    function showSunBorder() {
        return Properties.getValue("ShowSunBorder");
    }

    function getBatteryIndicatorTickColor() {
        return Graphics.COLOR_RED;
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

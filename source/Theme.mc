import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;

module Theme {

    const THEME_DARK = 0;
    const THEME_LIGHT = 1;

    function getThemeId() {
        return Properties.getValue("Theme");
    }

    function getBackgroundColor() {
        return getThemeId() == THEME_LIGHT ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    }

    function getDialColor() {
        return getThemeId() == THEME_LIGHT ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY;
    }

    function getTickColor() {
        return getThemeId() == THEME_LIGHT ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY;
    }

    function getHandColor() {
        return getThemeId() == THEME_LIGHT ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function getDigitalColor() {
        return getThemeId() == THEME_LIGHT ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function getMutedColor() {
        return Graphics.COLOR_DK_GRAY;
    }

    function showDigitalTime() {
        return Properties.getValue("ShowDigitalTime");
    }

    function use24HourDigital() {
        return Properties.getValue("Use24Hour");
    }

    function showBattery() {
        return Properties.getValue("ShowBattery");
    }

    function showSunBorder() {
        return Properties.getValue("ShowSunBorder");
    }

    function getSunBorderColor(phase) {
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
}

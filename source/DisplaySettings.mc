import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;

//! Display size modes for centre HUD fields (Connect IQ + on-watch settings).
module DisplaySettings {

    const MODE_HIDDEN = 0;
    const MODE_SMALL = 1;
    const MODE_LARGE = 2;
    const STEPS_AUTO_HIDE = 3;
    const BATTERY_WARNING_ONLY = 3;

    const PROP_DIGITAL_TIME = "DigitalTimeMode";
    const PROP_STEPS = "StepsMode";
    const PROP_BATTERY = "BatteryMode";
    const PROP_DATE = "DateMode";

    //! Target rendered width as a fraction of screen width (web-style vw).
    const TIME_WIDTH_VW_SMALL = 0.48;
    const TIME_WIDTH_VW_LARGE = 0.66;

    const HUD_STROKE_SMALL = 1;
    const HUD_STROKE_TIME = 2;

    const VECTOR_FACES = [
        "RobotoCondensedBold",
        "RobotoCondensedRegular",
        "RobotoRegular"
    ] as Array<String>;

    const BITMAP_TIME_FONTS = [
        Graphics.FONT_NUMBER_HOT,
        Graphics.FONT_NUMBER_MEDIUM,
        Graphics.FONT_LARGE,
        Graphics.FONT_MEDIUM,
        Graphics.FONT_SMALL
    ] as Array<Graphics.FontDefinition>;

    var _timeFontSmall = null;
    var _timeFontLarge = null;
    var _cacheScreenWidth = -1;
    var _cacheUse24Hour = false;

    function readMode(propertyKey as String) as Number {
        var mode = Properties.getValue(propertyKey);
        return mode != null ? mode : MODE_SMALL;
    }

    function invalidateTimeFonts() as Void {
        _cacheScreenWidth = -1;
    }

    function refreshTimeFonts(dc as Graphics.Dc) as Void {
        var use24Hour = Theme.use24HourDigital();
        var screenWidth = dc.getWidth();

        if (screenWidth == _cacheScreenWidth && use24Hour == _cacheUse24Hour) {
            return;
        }

        _cacheScreenWidth = screenWidth;
        _cacheUse24Hour = use24Hour;

        var sample = widestTimeSample(use24Hour);
        _timeFontSmall = fitFontToViewportWidth(dc, sample, screenWidth, TIME_WIDTH_VW_SMALL);
        _timeFontLarge = fitFontToViewportWidth(dc, sample, screenWidth, TIME_WIDTH_VW_LARGE);
    }

    function fontForTimeDisplay(dc as Graphics.Dc, mode as Number) as Graphics.FontType {
        refreshTimeFonts(dc);
        if (mode == MODE_LARGE) {
            return _timeFontLarge;
        }
        return _timeFontSmall;
    }

    function fontForFieldMode(mode as Number) {
        return mode == MODE_LARGE ? Graphics.FONT_SMALL : Graphics.FONT_XTINY;
    }

    function labelForDigitalTime(mode as Number) as String {
        if (mode == MODE_HIDDEN) {
            return "Hidden";
        }
        if (mode == MODE_LARGE) {
            return "Large";
        }
        return "Small";
    }

    function labelForSteps(mode as Number) as String {
        if (mode == MODE_HIDDEN) {
            return "Hidden";
        }
        if (mode == MODE_LARGE) {
            return "Large";
        }
        if (mode == STEPS_AUTO_HIDE) {
            return "Auto-hide";
        }
        return "Small";
    }

    function labelForBattery(mode as Number) as String {
        if (mode == MODE_HIDDEN) {
            return "Hidden";
        }
        if (mode == MODE_LARGE) {
            return "Large";
        }
        if (mode == BATTERY_WARNING_ONLY) {
            return "Warning only";
        }
        return "Small";
    }

    function labelForDate(mode as Number) as String {
        if (mode == MODE_HIDDEN) {
            return "Hidden";
        }
        if (mode == MODE_LARGE) {
            return "Large";
        }
        return "Small";
    }

    function widestTimeSample(use24Hour as Boolean) as String {
        return use24Hour ? "88:88" : "12:34 PM";
    }

    function fitFontToViewportWidth(
        dc as Graphics.Dc,
        text as String,
        screenWidth as Number,
        widthVw as Float
    ) as Graphics.FontType {
        var targetWidth = (screenWidth * widthVw).toNumber();
        var vectorFont = fitVectorFontToWidth(dc, text, targetWidth);
        if (vectorFont != null) {
            return vectorFont;
        }
        return fitBitmapFontToWidth(dc, text, targetWidth);
    }

    function fitVectorFontToWidth(
        dc as Graphics.Dc,
        text as String,
        targetWidth as Number
    ) as Graphics.VectorFont or Null {
        if (!(Graphics has :getVectorFont)) {
            return null;
        }

        var minSize = 8;
        var maxSize = targetWidth;
        var bestFont = null;

        while (minSize <= maxSize) {
            var size = (minSize + maxSize) / 2;
            var font = Graphics.getVectorFont({:face => VECTOR_FACES, :size => size});
            if (font == null) {
                break;
            }

            var width = dc.getTextWidthInPixels(text, font);
            if (width <= targetWidth) {
                bestFont = font;
                minSize = size + 1;
            } else {
                maxSize = size - 1;
            }
        }

        return bestFont;
    }

    function fitBitmapFontToWidth(
        dc as Graphics.Dc,
        text as String,
        targetWidth as Number
    ) as Graphics.FontDefinition {
        var bestFont = Graphics.FONT_SMALL;

        for (var i = 0; i < BITMAP_TIME_FONTS.size(); i += 1) {
            var font = BITMAP_TIME_FONTS[i];
            if (dc.getTextWidthInPixels(text, font) <= targetWidth) {
                bestFont = font;
                break;
            }
        }

        return bestFont;
    }

}

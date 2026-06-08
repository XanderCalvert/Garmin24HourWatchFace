import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class TwentyFourClockFaceView extends WatchUi.WatchFace {

    //! Midnight at bottom of dial (6 o'clock on a traditional watch face).
    private const BOTTOM_HOUR_MARKER = 0;
    private const TICK_PEN_NORMAL_MAJOR = 2;
    private const TICK_PEN_NORMAL_MINOR = 1;
    private const TICK_PEN_BATTERY_WARN = 4;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        DisplaySettings.invalidateTimeFonts();
        DialGeometry.initFromDc(dc);
    }

    function onShow() {
        SunSchedule.clearSunEventStorage();
        SunSchedule.refresh();
    }

    function onUpdate(dc) {
        var clockTime = System.getClockTime();
        var now = Time.now();
        var today = Gregorian.info(now, Time.FORMAT_SHORT);

        dc.setColor(Theme.getBackgroundColor(), Theme.getBackgroundColor());
        dc.clear();

        if (Theme.showSunBorder()) {
            drawSunBorder(dc);
        }

        drawHourIndicators(dc);

        HudLayout.compute(dc, clockTime, today);

        drawHand(dc, clockTime);
        drawCenterDot(dc);

        if (Theme.hasVisibleHudContent()) {
            drawCenterHud(dc, clockTime, today);
        }
    }

    function onHide() {
    }

    private function drawHourIndicators(dc) {
        var batteryIndicator = DataFields.getBatteryIndicatorLevel();

        for (var hour = 0; hour < 24; hour += 1) {
            var angleDeg = (hour / 24.0) * 360.0 + 90.0;
            var rad = angleDeg * Math.PI / 180.0;
            var cosA = Math.cos(rad);
            var sinA = Math.sin(rad);
            var isMajor = hour % 6 == 0;
            var innerR = isMajor ? DialGeometry.tickMajorInner : DialGeometry.tickMinorInner;

            var x1 = (DialGeometry.centerX + innerR * cosA).toNumber();
            var y1 = (DialGeometry.centerY + innerR * sinA).toNumber();
            var x2 = (DialGeometry.centerX + DialGeometry.tickOuter * cosA).toNumber();
            var y2 = (DialGeometry.centerY + DialGeometry.tickOuter * sinA).toNumber();

            var penWidth = isMajor ? TICK_PEN_NORMAL_MAJOR : TICK_PEN_NORMAL_MINOR;
            var tickColor = Theme.getTickColor();

            if (hour == BOTTOM_HOUR_MARKER && batteryIndicator != DataFields.BATTERY_INDICATOR_NONE) {
                penWidth = TICK_PEN_BATTERY_WARN;
                if (batteryIndicator == DataFields.BATTERY_INDICATOR_CRITICAL) {
                    tickColor = Theme.getBatteryIndicatorTickColor();
                }
            }

            dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(penWidth);
            dc.drawLine(x1, y1, x2, y2);
        }

        dc.setPenWidth(TICK_PEN_NORMAL_MINOR);
    }

    private function drawHand(dc, clockTime) {
        var minutes = clockTime.hour * 60 + clockTime.min;
        var angleDeg = (minutes / 1440.0) * 360.0 + 90.0;
        var rad = angleDeg * Math.PI / 180.0;
        var cosA = Math.cos(rad);
        var sinA = Math.sin(rad);
        var x1 = (DialGeometry.centerX + DialGeometry.handHubRadius * cosA).toNumber();
        var y1 = (DialGeometry.centerY + DialGeometry.handHubRadius * sinA).toNumber();
        var x2 = (DialGeometry.centerX + DialGeometry.handLength * cosA).toNumber();
        var y2 = (DialGeometry.centerY + DialGeometry.handLength * sinA).toNumber();

        dc.setColor(Theme.getHandColor(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);

        if (Theme.showDigitalTime() && HudLayout.timeY != null) {
            var timeText = DataFields.formatDigitalTime(clockTime);
            var timeFont = DisplaySettings.fontForTimeDisplay(dc, Theme.getDigitalTimeMode());
            var bounds = TextOutline.textBounds(
                dc,
                DialGeometry.centerX,
                HudLayout.timeY,
                timeFont,
                timeText,
                DisplaySettings.HUD_STROKE_TIME
            );
            HandClip.drawLineExcludingRect(dc, x1, y1, x2, y2, bounds[0], bounds[1], bounds[2], bounds[3]);
        } else {
            dc.drawLine(x1, y1, x2, y2);
        }

        dc.setPenWidth(1);
    }

    private function drawCenterDot(dc) {
        dc.setColor(Theme.getHandColor(), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(DialGeometry.centerX, DialGeometry.centerY, DialGeometry.centerDotRadius);
    }

    private function drawCenterHud(dc, clockTime, today) {
        var justify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var outline = Theme.getTextOutlineColor();

        var stepsText = DataFields.formatStepsText();
        if (stepsText != null && HudLayout.stepsY != null) {
            drawHudText(
                dc,
                DialGeometry.centerX,
                HudLayout.stepsY,
                DisplaySettings.fontForFieldMode(Theme.getStepsMode()),
                stepsText,
                Theme.getStatsColor(),
                outline,
                justify,
                DisplaySettings.HUD_STROKE_SMALL
            );
        }

        if (Theme.showDigitalTime() && HudLayout.timeY != null) {
            var timeText = DataFields.formatDigitalTime(clockTime);
            var timeFont = DisplaySettings.fontForTimeDisplay(dc, Theme.getDigitalTimeMode());
            var timeStroke = DisplaySettings.HUD_STROKE_TIME;

            TextOutline.fillBackdrop(
                dc,
                DialGeometry.centerX,
                HudLayout.timeY,
                timeFont,
                timeText,
                justify,
                timeStroke,
                Theme.getBackgroundColor()
            );

            drawHudText(
                dc,
                DialGeometry.centerX,
                HudLayout.timeY,
                timeFont,
                timeText,
                Theme.getDigitalColor(),
                outline,
                justify,
                timeStroke
            );
        }

        var dateText = DataFields.formatDateText(today);
        if (dateText != null && HudLayout.dateY != null) {
            drawHudText(
                dc,
                DialGeometry.centerX,
                HudLayout.dateY,
                DisplaySettings.fontForFieldMode(Theme.getDateMode()),
                dateText,
                Theme.getMutedColor(),
                outline,
                justify,
                DisplaySettings.HUD_STROKE_SMALL
            );
        }

        if (Theme.showBattery() && HudLayout.batteryY != null) {
            var batteryText = DataFields.formatBatteryPercent();
            if (batteryText != null) {
                drawHudText(
                    dc,
                    DialGeometry.centerX,
                    HudLayout.batteryY,
                    DisplaySettings.fontForFieldMode(Theme.getBatteryMode()),
                    batteryText,
                    Theme.getBatteryTextColor(),
                    outline,
                    justify,
                    DisplaySettings.HUD_STROKE_SMALL
                );
            }
        }
    }

    private function drawHudText(
        dc,
        x as Number,
        y as Number,
        font as Graphics.FontType,
        text as String,
        fillColor,
        outlineColor,
        justify as Number,
        strokePx as Number
    ) as Void {
        TextOutline.draw(dc, x, y, font, text, fillColor, outlineColor, justify, strokePx);
    }

    private function drawSunBorder(dc) {
        if (!SunSchedule.ensureSunEvents()) {
            return;
        }

        drawSunBorderRing(dc);
    }

    private function drawSunBorderRing(dc) {
        drawSunBorderSegment(dc, DialGeometry.sunArcRadius, DialGeometry.sunDotRadius, SunSchedule.getDusk(), SunSchedule.getDawn(), Theme.getSunBorderColor(SunSchedule.PHASE_NIGHT));
        drawSunBorderSegment(dc, DialGeometry.sunArcRadius, DialGeometry.sunDotRadius, SunSchedule.getDawn(), SunSchedule.getSunrise(), Theme.getSunBorderColor(SunSchedule.PHASE_DAWN));
        drawSunBorderSegment(dc, DialGeometry.sunArcRadius, DialGeometry.sunDotRadius, SunSchedule.getSunrise(), SunSchedule.getSunset(), Theme.getSunBorderColor(SunSchedule.PHASE_DAY));
        drawSunBorderSegment(dc, DialGeometry.sunArcRadius, DialGeometry.sunDotRadius, SunSchedule.getSunset(), SunSchedule.getDusk(), Theme.getSunBorderColor(SunSchedule.PHASE_DUSK));
    }

    private function drawSunBorderSegment(dc, radius, dotRadius, start as Time.Moment, end as Time.Moment, color) {
        if (start == null || end == null) {
            return;
        }

        var startDeg = SunSchedule.momentToArcDegrees(start);
        var endDeg = SunSchedule.momentToArcDegrees(end);
        var span = SunSchedule.arcSpanDegrees(startDeg, endDeg);
        var step = 1;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        for (var i = 0; i <= span; i += step) {
            var deg = SunSchedule.normalizeDegrees(startDeg + i);
            var rad = (deg - 360) * Math.PI / 180.0;
            var x = (DialGeometry.centerX + radius * Math.cos(rad)).toNumber();
            var y = (DialGeometry.centerY + radius * Math.sin(rad)).toNumber();
            dc.fillCircle(x, y, dotRadius);
        }
    }

}

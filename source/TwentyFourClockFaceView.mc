import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class TwentyFourClockFaceView extends WatchUi.WatchFace {

    private const CENTER_X = 140;
    private const CENTER_Y = 140;
    private const DIAL_RADIUS = 120;
    private const HAND_LENGTH = 95;
    private const TICK_OUTER_RADIUS = DIAL_RADIUS;
    private const TICK_MINOR_INNER_RADIUS = DIAL_RADIUS - 8;
    private const TICK_MAJOR_INNER_RADIUS = DIAL_RADIUS - 14;
    private const BATTERY_RADIUS = DIAL_RADIUS - 14;
    private const SUN_BORDER_INNER_RADIUS = DIAL_RADIUS + 1;
    private const SUN_BORDER_OUTER_RADIUS = DIAL_RADIUS + 9;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
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

        drawDial(dc);
        drawHand(dc, clockTime);
        drawCenterDot(dc);

        if (Theme.showDigitalTime()) {
            drawDigitalTime(dc, clockTime);
        }

        drawDate(dc, today);

        if (Theme.showBattery()) {
            drawBattery(dc);
        }
    }

    function onHide() {
    }

    private function drawDial(dc) {
        dc.setColor(Theme.getDialColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(CENTER_X, CENTER_Y, DIAL_RADIUS);

        drawHourIndicators(dc);
    }

    private function drawHourIndicators(dc) {
        dc.setColor(Theme.getTickColor(), Graphics.COLOR_TRANSPARENT);

        for (var hour = 0; hour < 24; hour += 1) {
            var angleDeg = (hour / 24.0) * 360.0 + 90.0;
            var rad = angleDeg * Math.PI / 180.0;
            var cosA = Math.cos(rad);
            var sinA = Math.sin(rad);
            var isMajor = hour % 6 == 0;
            var innerR = isMajor ? TICK_MAJOR_INNER_RADIUS : TICK_MINOR_INNER_RADIUS;

            var x1 = (CENTER_X + innerR * cosA).toNumber();
            var y1 = (CENTER_Y + innerR * sinA).toNumber();
            var x2 = (CENTER_X + TICK_OUTER_RADIUS * cosA).toNumber();
            var y2 = (CENTER_Y + TICK_OUTER_RADIUS * sinA).toNumber();

            dc.setPenWidth(isMajor ? 2 : 1);
            dc.drawLine(x1, y1, x2, y2);
        }

        dc.setPenWidth(1);
    }

    private function drawHand(dc, clockTime) {
        var minutes = clockTime.hour * 60 + clockTime.min;
        var angleDeg = (minutes / 1440.0) * 360.0 + 90.0;
        var rad = angleDeg * Math.PI / 180.0;
        var x = (CENTER_X + HAND_LENGTH * Math.cos(rad)).toNumber();
        var y = (CENTER_Y + HAND_LENGTH * Math.sin(rad)).toNumber();

        dc.setColor(Theme.getHandColor(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(CENTER_X, CENTER_Y, x, y);
        dc.setPenWidth(1);
    }

    private function drawCenterDot(dc) {
        dc.setColor(Theme.getHandColor(), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(CENTER_X, CENTER_Y, 4);
    }

    private function drawDigitalTime(dc, clockTime) {
        var hour = clockTime.hour;
        var minute = clockTime.min;

        if (!Theme.use24HourDigital()) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        var timeText = Lang.format("$1$:$2$", [ formatTwoDigits(hour), formatTwoDigits(minute) ]);

        dc.setColor(Theme.getDigitalColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            CENTER_X,
            CENTER_Y - 18,
            Graphics.FONT_SMALL,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawDate(dc, today) {
        var dateText = Lang.format("$1$ $2$ $3$", [ today.day_of_week, today.day, today.month ]);

        dc.setColor(Theme.getMutedColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            CENTER_X,
            CENTER_Y + 28,
            Graphics.FONT_XTINY,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawBattery(dc) {
        var stats = System.getSystemStats();
        var batteryText = stats.battery.format("%d") + "%";
        // Bottom of dial (midnight), inside the tick ring.
        var angleDeg = 90.0;
        var rad = angleDeg * Math.PI / 180.0;
        var x = (CENTER_X + BATTERY_RADIUS * Math.cos(rad)).toNumber();
        var y = (CENTER_Y + BATTERY_RADIUS * Math.sin(rad)).toNumber();

        dc.setColor(Theme.getMutedColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            Graphics.FONT_XTINY,
            batteryText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawSunBorder(dc) {
        if (!SunSchedule.ensureSunEvents()) {
            return;
        }

        drawSunBorderRing(dc);
    }

    private function drawSunBorderRing(dc) {
        var arcRadius = (SUN_BORDER_OUTER_RADIUS + SUN_BORDER_INNER_RADIUS) / 2;
        var dotRadius = (SUN_BORDER_OUTER_RADIUS - SUN_BORDER_INNER_RADIUS) / 2;

        drawSunBorderSegment(dc, arcRadius, dotRadius, SunSchedule.getDusk(), SunSchedule.getDawn(), Theme.getSunBorderColor(SunSchedule.PHASE_NIGHT));
        drawSunBorderSegment(dc, arcRadius, dotRadius, SunSchedule.getDawn(), SunSchedule.getSunrise(), Theme.getSunBorderColor(SunSchedule.PHASE_DAWN));
        drawSunBorderSegment(dc, arcRadius, dotRadius, SunSchedule.getSunrise(), SunSchedule.getSunset(), Theme.getSunBorderColor(SunSchedule.PHASE_DAY));
        drawSunBorderSegment(dc, arcRadius, dotRadius, SunSchedule.getSunset(), SunSchedule.getDusk(), Theme.getSunBorderColor(SunSchedule.PHASE_DUSK));
    }

    private function drawSunBorderSegment(dc, radius, dotRadius, start as Time.Moment, end as Time.Moment, color) {
        if (start == null || end == null) {
            return;
        }

        var startDeg = SunSchedule.momentToArcDegrees(start);
        var endDeg = SunSchedule.momentToArcDegrees(end);
        var span = SunSchedule.arcSpanDegrees(startDeg, endDeg);
        var step = 2;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        for (var i = 0; i <= span; i += step) {
            var deg = SunSchedule.normalizeDegrees(startDeg + i);
            var rad = (deg - 360) * Math.PI / 180.0;
            var x = (CENTER_X + radius * Math.cos(rad)).toNumber();
            var y = (CENTER_Y + radius * Math.sin(rad)).toNumber();
            dc.fillCircle(x, y, dotRadius);
        }
    }

    private function formatTwoDigits(value) {
        if (value < 10) {
            return "0" + value.format("%d");
        }
        return value.format("%d");
    }
}

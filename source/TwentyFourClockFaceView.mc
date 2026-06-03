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
    private const LABEL_RADIUS = 102;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var clockTime = System.getClockTime();
        var now = Time.now();
        var today = Gregorian.info(now, Time.FORMAT_SHORT);

        dc.setColor(Theme.getBackgroundColor(), Theme.getBackgroundColor());
        dc.clear();

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

        dc.setColor(Theme.getLabelColor(), Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_XTINY;

        for (var i = 0; i < Theme.HOUR_LABELS.size(); i += 1) {
            var hour = Theme.HOUR_ANGLES[i];
            var angleDeg = (hour / 24.0) * 360.0 - 90.0;
            var rad = angleDeg * Math.PI / 180.0;
            var x = (CENTER_X + LABEL_RADIUS * Math.cos(rad)).toNumber();
            var y = (CENTER_Y + LABEL_RADIUS * Math.sin(rad)).toNumber();
            dc.drawText(x, y, font, Theme.HOUR_LABELS[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawHand(dc, clockTime) {
        var minutes = clockTime.hour * 60 + clockTime.min;
        var angleDeg = (minutes / 1440.0) * 360.0 - 90.0;
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

        dc.setColor(Theme.getMutedColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            CENTER_X,
            dc.getHeight() - 18,
            Graphics.FONT_XTINY,
            batteryText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function formatTwoDigits(value) {
        if (value < 10) {
            return "0" + value.format("%d");
        }
        return value.format("%d");
    }
}

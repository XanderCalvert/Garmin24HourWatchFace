import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

//! Anchors digital time on the dial centre; other HUD rows sit above/below it.
module HudLayout {

    const ROW_GAP_REF = 4;

    var stepsY as Number or Null = null;
    var timeY as Number or Null = null;
    var dateY as Number or Null = null;
    var batteryY as Number or Null = null;

    function compute(dc as Graphics.Dc, clockTime as System.ClockTime, today) as Void {
        stepsY = null;
        timeY = null;
        dateY = null;
        batteryY = null;

        var gap = DialGeometry.hudRowGap;
        var centerY = DialGeometry.centerY;

        var timeText = Theme.showDigitalTime() ? DataFields.formatDigitalTime(clockTime) : null;
        if (timeText == null) {
            layoutWithoutTime(dc, today);
            return;
        }

        var timeFont = DisplaySettings.fontForTimeDisplay(dc, Theme.getDigitalTimeMode());
        var timeHeight = rowHeight(dc, timeFont);
        timeY = centerY;

        var stepsText = DataFields.formatStepsText();
        if (stepsText != null) {
            var stepsHeight = rowHeight(dc, DisplaySettings.fontForFieldMode(Theme.getStepsMode()));
            stepsY = centerY - timeHeight / 2 - gap - stepsHeight / 2;
        }

        var belowCursor = centerY + timeHeight / 2 + gap;

        var dateText = DataFields.formatDateText(today);
        if (dateText != null) {
            var dateHeight = rowHeight(dc, DisplaySettings.fontForFieldMode(Theme.getDateMode()));
            dateY = belowCursor + dateHeight / 2;
            belowCursor += dateHeight + gap;
        }

        if (Theme.showBattery()) {
            var batteryText = DataFields.formatBatteryPercent();
            if (batteryText != null) {
                var batteryHeight = rowHeight(
                    dc,
                    DisplaySettings.fontForFieldMode(Theme.getBatteryMode())
                );
                batteryY = belowCursor + batteryHeight / 2;
            }
        }
    }

    //! When time is hidden, centre the remaining rows as a compact stack.
    function layoutWithoutTime(dc as Graphics.Dc, today) as Void {
        var gap = DialGeometry.hudRowGap;
        var rows = [] as Array<Number>;
        var ids = [] as Array<Symbol>;

        var stepsText = DataFields.formatStepsText();
        if (stepsText != null) {
            rows.add(rowHeight(dc, DisplaySettings.fontForFieldMode(Theme.getStepsMode())));
            ids.add(:steps);
        }

        var dateText = DataFields.formatDateText(today);
        if (dateText != null) {
            rows.add(rowHeight(dc, DisplaySettings.fontForFieldMode(Theme.getDateMode())));
            ids.add(:date);
        }

        if (Theme.showBattery()) {
            var batteryText = DataFields.formatBatteryPercent();
            if (batteryText != null) {
                rows.add(rowHeight(dc, DisplaySettings.fontForFieldMode(Theme.getBatteryMode())));
                ids.add(:battery);
            }
        }

        if (rows.size() == 0) {
            return;
        }

        var totalHeight = sumHeights(rows);
        if (rows.size() > 1) {
            totalHeight += gap * (rows.size() - 1);
        }

        var topY = DialGeometry.centerY - totalHeight / 2;
        for (var i = 0; i < rows.size(); i += 1) {
            assignRowY(ids[i], topY + rows[i] / 2);
            topY += rows[i] + gap;
        }
    }

    function rowHeight(dc as Graphics.Dc, font as Graphics.FontType) as Number {
        return dc.getFontHeight(font);
    }

    function sumHeights(heights as Array<Number>) as Number {
        var total = 0;
        for (var i = 0; i < heights.size(); i += 1) {
            total += heights[i];
        }
        return total;
    }

    function assignRowY(rowId as Symbol, y as Number) as Void {
        if (rowId == :steps) {
            stepsY = y;
        } else if (rowId == :time) {
            timeY = y;
        } else if (rowId == :date) {
            dateY = y;
        } else if (rowId == :battery) {
            batteryY = y;
        }
    }

}

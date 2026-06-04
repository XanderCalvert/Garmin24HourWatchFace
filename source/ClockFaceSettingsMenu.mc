import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

//! On-watch (and simulator) settings for display toggles.
class ClockFaceSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Display"});

        addItem(new WatchUi.ToggleMenuItem(
            "Digital time",
            null,
            :showDigitalTime,
            readBool("ShowDigitalTime"),
            null
        ));
        addItem(new WatchUi.ToggleMenuItem(
            "Step count",
            null,
            :showSteps,
            readBool("ShowSteps"),
            null
        ));
        addItem(new WatchUi.ToggleMenuItem(
            "Battery %",
            null,
            :showBattery,
            readBool("ShowBattery"),
            null
        ));
        addItem(new WatchUi.ToggleMenuItem(
            "Date",
            null,
            :showDate,
            readBool("ShowDate"),
            null
        ));
        addItem(new WatchUi.ToggleMenuItem(
            "Sun path ring",
            null,
            :showSunBorder,
            readBool("ShowSunBorder"),
            null
        ));
        addItem(new WatchUi.ToggleMenuItem(
            "24-hour digital",
            null,
            :use24Hour,
            readBool("Use24Hour"),
            null
        ));
    }

    private function readBool(key as String) as Boolean {
        var value = Properties.getValue(key);
        return value != null ? value : true;
    }

}

class ClockFaceSettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (!(item instanceof WatchUi.ToggleMenuItem)) {
            return;
        }

        var toggle = item as WatchUi.ToggleMenuItem;
        var enabled = toggle.isEnabled();
        var id = toggle.getId();

        if (id == :showDigitalTime) {
            Properties.setValue("ShowDigitalTime", enabled);
        } else if (id == :showSteps) {
            Properties.setValue("ShowSteps", enabled);
        } else if (id == :showBattery) {
            Properties.setValue("ShowBattery", enabled);
        } else if (id == :showDate) {
            Properties.setValue("ShowDate", enabled);
        } else if (id == :showSunBorder) {
            Properties.setValue("ShowSunBorder", enabled);
        } else if (id == :use24Hour) {
            Properties.setValue("Use24Hour", enabled);
        }

        WatchUi.requestUpdate();
    }

}

import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

//! On-watch (and simulator) settings for display toggles.
class ClockFaceSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Display"});

        addItem(new WatchUi.MenuItem(
            "Digital time",
            DisplaySettings.labelForDigitalTime(Theme.getDigitalTimeMode()),
            :digitalTimeMode,
            null
        ));
        addItem(new WatchUi.MenuItem(
            "Steps",
            DisplaySettings.labelForSteps(Theme.getStepsMode()),
            :stepsMode,
            null
        ));
        addItem(new WatchUi.MenuItem(
            "Battery",
            DisplaySettings.labelForBattery(Theme.getBatteryMode()),
            :batteryMode,
            null
        ));
        addItem(new WatchUi.MenuItem(
            "Date",
            DisplaySettings.labelForDate(Theme.getDateMode()),
            :dateMode,
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
        if (item instanceof WatchUi.ToggleMenuItem) {
            handleToggle(item as WatchUi.ToggleMenuItem);
            return;
        }

        var id = item.getId();
        if (id == :digitalTimeMode) {
            pushModePicker(
                "Digital time",
                DisplaySettings.PROP_DIGITAL_TIME,
                [ "Hidden", "Small", "Large" ],
                [ DisplaySettings.MODE_HIDDEN, DisplaySettings.MODE_SMALL, DisplaySettings.MODE_LARGE ]
            );
        } else if (id == :stepsMode) {
            pushModePicker(
                "Steps",
                DisplaySettings.PROP_STEPS,
                [ "Hidden", "Small", "Large", "Auto-hide" ],
                [
                    DisplaySettings.MODE_HIDDEN,
                    DisplaySettings.MODE_SMALL,
                    DisplaySettings.MODE_LARGE,
                    DisplaySettings.STEPS_AUTO_HIDE
                ]
            );
        } else if (id == :batteryMode) {
            pushModePicker(
                "Battery",
                DisplaySettings.PROP_BATTERY,
                [ "Hidden", "Small", "Large", "Warning only" ],
                [
                    DisplaySettings.MODE_HIDDEN,
                    DisplaySettings.MODE_SMALL,
                    DisplaySettings.MODE_LARGE,
                    DisplaySettings.BATTERY_WARNING_ONLY
                ]
            );
        } else if (id == :dateMode) {
            pushModePicker(
                "Date",
                DisplaySettings.PROP_DATE,
                [ "Hidden", "Small", "Large" ],
                [ DisplaySettings.MODE_HIDDEN, DisplaySettings.MODE_SMALL, DisplaySettings.MODE_LARGE ]
            );
        }
    }

    private function handleToggle(toggle as WatchUi.ToggleMenuItem) as Void {
        var enabled = toggle.isEnabled();
        var id = toggle.getId();

        if (id == :showSunBorder) {
            Properties.setValue("ShowSunBorder", enabled);
        } else if (id == :use24Hour) {
            Properties.setValue("Use24Hour", enabled);
        }

        WatchUi.requestUpdate();
    }

    private function pushModePicker(
        title as String,
        propertyKey as String,
        labels as Array<String>,
        values as Array<Number>
    ) as Void {
        WatchUi.pushView(
            new DisplayModePickerMenu(title, propertyKey, labels, values),
            new DisplayModePickerDelegate(propertyKey),
            WatchUi.SLIDE_LEFT
        );
    }

}

class DisplayModePickerMenu extends WatchUi.Menu2 {

    function initialize(
        title as String,
        propertyKey as String,
        labels as Array<String>,
        values as Array<Number>
    ) {
        Menu2.initialize({:title => title});

        var current = DisplaySettings.readMode(propertyKey);
        for (var i = 0; i < labels.size(); i += 1) {
            var suffix = values[i] == current ? " ✓" : null;
            addItem(new WatchUi.MenuItem(labels[i], suffix, values[i], null));
        }
    }

}

class DisplayModePickerDelegate extends WatchUi.Menu2InputDelegate {

    private var _propertyKey as String;

    function initialize(propertyKey as String) {
        Menu2InputDelegate.initialize();
        _propertyKey = propertyKey;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        Properties.setValue(_propertyKey, item.getId());
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}

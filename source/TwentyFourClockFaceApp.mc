import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TwentyFourClockFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function onSettingsChanged() as Void {
        DisplaySettings.invalidateTimeFonts();
        WatchUi.requestUpdate();
    }

    function onNightModeChanged() as Void {
        WatchUi.requestUpdate();
    }

    function getInitialView() {
        return [ new TwentyFourClockFaceView(), new TwentyFourClockFaceDelegate() ];
    }

    function getSettingsView() {
        return [ new ClockFaceSettingsMenu(), new ClockFaceSettingsDelegate() ];
    }
}

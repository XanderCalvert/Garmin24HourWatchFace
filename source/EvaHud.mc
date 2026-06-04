import Toybox.Lang;
import Toybox.Time.Gregorian;

//! NERV / MAGI-inspired label strings and layout constants.
module EvaHud {

    const LABEL_DATE = "DATE";
    const LABEL_ENRG = "ENRG";

    const DAY_NAMES = [ "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" ];
    const MONTH_NAMES = [ "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" ];

    const FRAME_HALF_W = 72;
    const FRAME_HALF_H = 46;
    const FRAME_CORNER = 14;
    const BAR_SEGMENTS = 8;
    const BAR_SEGMENT_W = 5;
    const BAR_SEGMENT_H = 5;
    const BAR_SEGMENT_GAP = 2;

    function formatDateLine(today as Gregorian.Info) as String {
        var monthIndex = today.month - 1;
        if (monthIndex < 0 || monthIndex >= MONTH_NAMES.size()) {
            monthIndex = 0;
        }

        var dayText = today.day.format("%02d");
        return dayText + " " + MONTH_NAMES[monthIndex];
    }

    function phaseStatus(phase as Number) as String {
        if (phase == SunSchedule.PHASE_NIGHT) {
            return "NIGHT";
        }
        if (phase == SunSchedule.PHASE_DAY) {
            return "DAYLITE";
        }
        if (phase == SunSchedule.PHASE_DAWN) {
            return "DAWN";
        }
        if (phase == SunSchedule.PHASE_DUSK) {
            return "DUSK";
        }
        return "STANDBY";
    }
}

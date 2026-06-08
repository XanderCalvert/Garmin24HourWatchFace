import Toybox.Graphics;
import Toybox.Lang;

//! Clip the 24-hour hand so it passes behind the digital time block.
module HandClip {

    function drawLineExcludingRect(
        dc as Graphics.Dc,
        x1 as Number,
        y1 as Number,
        x2 as Number,
        y2 as Number,
        minX as Number,
        minY as Number,
        maxX as Number,
        maxY as Number
    ) as Void {
        var inside = lineInsideRectTs(x1, y1, x2, y2, minX, minY, maxX, maxY);
        if (inside == null) {
            dc.drawLine(x1, y1, x2, y2);
            return;
        }

        var tMin = inside[0];
        var tMax = inside[1];

        if (tMin > 0.001) {
            drawLineSegment(dc, x1, y1, x2, y2, 0.0, tMin);
        }
        if (tMax < 0.999) {
            drawLineSegment(dc, x1, y1, x2, y2, tMax, 1.0);
        }
    }

    function drawLineSegment(
        dc as Graphics.Dc,
        x1 as Number,
        y1 as Number,
        x2 as Number,
        y2 as Number,
        tStart as Float,
        tEnd as Float
    ) as Void {
        var dx = (x2 - x1).toFloat();
        var dy = (y2 - y1).toFloat();
        var sx = (x1 + dx * tStart).toNumber();
        var sy = (y1 + dy * tStart).toNumber();
        var ex = (x1 + dx * tEnd).toNumber();
        var ey = (y1 + dy * tEnd).toNumber();
        dc.drawLine(sx, sy, ex, ey);
    }

    function lineInsideRectTs(
        x1 as Number,
        y1 as Number,
        x2 as Number,
        y2 as Number,
        minX as Number,
        minY as Number,
        maxX as Number,
        maxY as Number
    ) as Array<Float> or Null {
        var dx = (x2 - x1).toFloat();
        var dy = (y2 - y1).toFloat();
        var ts = [ 0.0, 1.0 ] as Array<Float>;

        if (!clipEdge(dx, (minX - x1).toFloat(), ts) ||
            !clipEdge(-dx, (x1 - maxX).toFloat(), ts) ||
            !clipEdge(dy, (minY - y1).toFloat(), ts) ||
            !clipEdge(-dy, (y1 - maxY).toFloat(), ts)) {
            return null;
        }

        if (ts[0] > ts[1]) {
            return null;
        }

        return ts;
    }

    function clipEdge(p as Float, q as Float, ts as Array<Float>) as Boolean {
        if (p == 0.0) {
            return q >= 0.0;
        }

        var t = q / p;
        if (p < 0.0) {
            if (t > ts[1]) {
                return false;
            }
            if (t > ts[0]) {
                ts[0] = t;
            }
        } else {
            if (t < ts[0]) {
                return false;
            }
            if (t < ts[1]) {
                ts[1] = t;
            }
        }

        return true;
    }

}

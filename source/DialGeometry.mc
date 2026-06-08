import Toybox.Graphics;
import Toybox.Lang;

//! Screen-derived dial, tick, hand, sun ring, and centre text layout.
module DialGeometry {

    const REF_SCREEN_MIN = 280;
    const EDGE_INSET = 4;
    const TICK_TO_RING_GAP = 0;
    const BAND_THICKNESS = 6;
    const TICK_MINOR_INSET_REF = 8;
    const TICK_MAJOR_INSET_REF = 14;
    const HAND_HUB_RADIUS_REF = 30;
    const HAND_TO_DIAL_RATIO = 0.79;
    const CENTER_DOT_RADIUS_REF = 4;

    var centerX as Number = 0;
    var centerY as Number = 0;
    var dialRadius as Number = 0;
    var handLength as Number = 0;
    var handHubRadius as Number = 0;
    var centerDotRadius as Number = 0;
    var tickOuter as Number = 0;
    var tickMinorInner as Number = 0;
    var tickMajorInner as Number = 0;
    var sunBorderInner as Number = 0;
    var sunBorderOuter as Number = 0;
    var sunArcRadius as Number = 0;
    var sunDotRadius as Number = 0;
    var hudRowGap as Number = 0;

    function initFromDc(dc as Graphics.Dc) as Void {
        centerX = dc.getWidth() / 2;
        centerY = dc.getHeight() / 2;

        var minDim = dc.getWidth();
        if (dc.getHeight() < minDim) {
            minDim = dc.getHeight();
        }

        var scale = minDim.toFloat() / REF_SCREEN_MIN.toFloat();

        var maxRadius = centerX;
        if (centerY < maxRadius) {
            maxRadius = centerY;
        }

        var edgeInset = scaleToPx(EDGE_INSET, scale);
        var bandThickness = scaleToPx(BAND_THICKNESS, scale);

        sunBorderOuter = maxRadius - edgeInset;
        dialRadius = sunBorderOuter - TICK_TO_RING_GAP - bandThickness;
        sunBorderInner = dialRadius + TICK_TO_RING_GAP;
        handLength = (dialRadius * HAND_TO_DIAL_RATIO).toNumber();
        handHubRadius = scaleToPx(HAND_HUB_RADIUS_REF, scale);
        centerDotRadius = scaleToPx(CENTER_DOT_RADIUS_REF, scale);
        if (centerDotRadius < 2) {
            centerDotRadius = 2;
        }

        tickOuter = dialRadius;
        tickMinorInner = dialRadius - scaleToPx(TICK_MINOR_INSET_REF, scale);
        tickMajorInner = dialRadius - scaleToPx(TICK_MAJOR_INSET_REF, scale);

        sunArcRadius = (sunBorderOuter + sunBorderInner) / 2;
        sunDotRadius = (sunBorderOuter - sunBorderInner) / 2;
        hudRowGap = scaleToPx(HudLayout.ROW_GAP_REF, scale);
    }

    function scaleToPx(refPx as Number, scale as Float) as Number {
        return (refPx.toFloat() * scale).toNumber();
    }

}

import Toybox.Graphics;
import Toybox.Lang;

//! Faux stroke by drawing text at pixel offsets before the fill pass.
module TextOutline {

    function draw(
        dc as Graphics.Dc,
        x as Number,
        y as Number,
        font as Graphics.FontType,
        text as String,
        fillColor,
        outlineColor,
        justify as Number,
        strokePx as Number
    ) as Void {
        dc.setColor(outlineColor, Graphics.COLOR_TRANSPARENT);
        drawStrokeOffsets(dc, x, y, font, text, justify, strokePx);
        dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justify);
    }

    //! Clears anything drawn underneath (e.g. the hand) within the text bounds.
    function fillBackdrop(
        dc as Graphics.Dc,
        x as Number,
        y as Number,
        font as Graphics.FontType,
        text as String,
        justify as Number,
        strokePx as Number,
        color
    ) as Void {
        var dims = dc.getTextDimensions(text, font);
        var pad = strokePx + 3;
        var halfW = dims[0] / 2 + pad;
        var halfH = dims[1] / 2 + pad;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - halfW, y - halfH, halfW * 2, halfH * 2);
    }

    function textBounds(
        dc as Graphics.Dc,
        x as Number,
        y as Number,
        font as Graphics.FontType,
        text as String,
        strokePx as Number
    ) as Array<Number> {
        var dims = dc.getTextDimensions(text, font);
        var pad = strokePx + 3;
        var halfW = dims[0] / 2 + pad;
        var halfH = dims[1] / 2 + pad;

        return [ x - halfW, y - halfH, x + halfW, y + halfH ];
    }

    function drawStrokeOffsets(
        dc as Graphics.Dc,
        x as Number,
        y as Number,
        font as Graphics.FontType,
        text as String,
        justify as Number,
        strokePx as Number
    ) as Void {
        for (var dx = -strokePx; dx <= strokePx; dx += 1) {
            for (var dy = -strokePx; dy <= strokePx; dy += 1) {
                if (dx == 0 && dy == 0) {
                    continue;
                }
                dc.drawText(x + dx, y + dy, font, text, justify);
            }
        }
    }

}

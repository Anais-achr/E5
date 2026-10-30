package fr.uge.poo.paint.ex5;

import java.awt.*;

public record Line(int x1, int y1, int x2, int y2) implements Shape {
    @Override
    public void draw(Canvas canvas, Colors color) {
        canvas.drawLine(x1, y1, x2, y2, color);
    }

    @Override
    public int distanceSquaredTo(int px, int py) {
        int dx = (x1 + x2) / 2 - px;
        int dy = (y1 + y2) / 2 - py;
        return dx * dx + dy * dy;
    }
}
package fr.uge.poo.paint.ex5;

import java.awt.*;

public record Rectangle(int x1, int y1, int x2, int y2) implements Shape {
    private Box box() { return new Box(x1, y1, x2, y2); }

    @Override
    public void draw(Canvas canvas, Colors color) {
        var b = box();
        canvas.drawRectangle(b.x(), b.y(), b.width(), b.height(), color);
    }


    @Override
    public int distanceSquaredTo(int px, int py) {
        return box().distanceSquaredTo(px, py);
    }
}
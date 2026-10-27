package fr.uge.poo.paint.ex4;

import java.awt.Graphics2D;

record Ellipse(int x1, int y1, int x2, int y2) implements Shape {
    private Box box() { return new Box(x1, y1, x2, y2); }

    @Override
    public void draw(Graphics2D g) {
        var b = box();
        g.drawOval(b.x(), b.y(), b.width(), b.height());
    }

    @Override
    public int distanceSquaredTo(int px, int py) {
        return box().distanceSquaredTo(px, py);
    }
}
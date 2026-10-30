package fr.uge.poo.paint.ex5;

public sealed interface Shape permits Ellipse, Line, Rectangle {
    void draw(Canvas canvas, Colors color);
    int distanceSquaredTo(int x, int y);
}

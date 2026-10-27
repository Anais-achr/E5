package fr.uge.poo.paint.ex4;

import java.awt.*;

public sealed interface Shape permits Ellipse, Line, Rectangle {
    void draw(Graphics2D graphics);
    int distanceSquaredTo(int x, int y);
}

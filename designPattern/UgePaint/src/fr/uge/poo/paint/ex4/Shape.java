package fr.uge.poo.paint.ex4;

import java.awt.*;

public sealed interface Shape permits fr.uge.poo.paint.ex4.Line, Rectangle, fr.uge.poo.paint.ex4.Elipse {
    void draw(Graphics2D graphics);
    //int distanceSquaredTo(int x, int y);
    int center();
}

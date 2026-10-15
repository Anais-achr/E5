package fr.uge.poo.paint.ex4;

import java.awt.*;

public sealed interface Shape permits Line, Rectangle, Elipse {
    void draw(Graphics2D graphics);
    int center();
}

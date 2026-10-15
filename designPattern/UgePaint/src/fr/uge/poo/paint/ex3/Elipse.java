package fr.uge.poo.paint.ex3;

import java.awt.*;

public record Elipse(int x, int y, int width, int height) implements Shape {
    @Override
    public void draw(Graphics2D graphics) {
        graphics.drawOval(x, y, width, height);
    }
}

package fr.uge.poo.paint.ex5;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.*;
import java.util.function.Consumer;

public final class SimpleGraphicAdapter implements Canvas {
    private final SimpleGraphics simpleGraphics = new SimpleGraphics("simple", 800, 600);

    @Override
    public void clear(Color color) {
        simpleGraphics.clear(color);
    }

    @Override
    public void drawLine(Graphics2D graphics, int x1, int y1, int x2, int y2) {
        graphics.drawLine(x1, y1, x2, y2);
    }

    @Override
    public void drawRectangle(Graphics2D graphics, int x, int y, int width, int height) {
        graphics.drawRect(x, y, width, height);
    }

    @Override
    public void drawEllipse(Graphics2D graphics, int x, int y, int width, int height) {
        graphics.drawOval(x, y, width, height);
    }

    @Override
    public void onMouseClick(int x, int y) {

    }

    @Override
    public void waitForMouseEvents(MouseCallback mouseCallback) {

    }
}

package fr.uge.poo.paint.ex5;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.Color;
import java.util.Objects;

public final class SimpleGraphicAdapter implements Canvas {
    private final SimpleGraphics simpleGraphics;

    public SimpleGraphicAdapter(String title, int width, int height) {
        simpleGraphics = new SimpleGraphics(title, width, height);
    }

    private static Color toAwtColor(Colors color) {
        return switch (color) {
            case WHITE -> Color.WHITE;
            case BLACK -> Color.BLACK;
            case ORANGE -> Color.ORANGE;
        };
    }

    @Override
    public void clear(Colors color) {
        Objects.requireNonNull(color);
        simpleGraphics.clear(toAwtColor(color));
    }

    @Override
    public void drawLine(int x1, int y1, int x2, int y2, Colors color) {
        Objects.requireNonNull(color);
        simpleGraphics.render(graphics -> {
            graphics.setColor(toAwtColor(color));
            graphics.drawLine(x1, y1, x2, y2);
        });
    }

    @Override
    public void drawRectangle(int x, int y, int width, int height, Colors color) {
        Objects.requireNonNull(color);
        simpleGraphics.render(graphics -> {
            graphics.setColor(toAwtColor(color));
            graphics.drawRect(x, y, width, height);
        });
    }

    @Override
    public void drawEllipse(int x, int y, int width, int height, Colors color) {
        Objects.requireNonNull(color);
        simpleGraphics.render(graphics -> {
            graphics.setColor(toAwtColor(color));
            graphics.drawOval(x, y, width, height);
        });
    }

    @Override
    public void waitForMouseEvents(MouseCallback callback) {
        Objects.requireNonNull(callback);
        simpleGraphics.waitForMouseEvents(callback::mouseClicked);
    }
}
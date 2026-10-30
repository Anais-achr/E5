package fr.uge.poo.paint.ex5;

import java.util.Objects;

public final class CoolGraphicAdapter implements Canvas {
    private final CoolGraphics coolGraphics;

    public CoolGraphicAdapter(String title, int width, int height) {
        coolGraphics = new CoolGraphics(title, width, height);
    }

    private static CoolGraphics.ColorPlus toColorPlus(Colors color) {
        return switch (color) {
            case WHITE -> CoolGraphics.ColorPlus.WHITE;
            case BLACK -> CoolGraphics.ColorPlus.BLACK;
            case ORANGE -> CoolGraphics.ColorPlus.ORANGE;
        };
    }

    @Override
    public void clear(Colors color) {
        Objects.requireNonNull(color);
        coolGraphics.repaint(toColorPlus(color));
    }

    @Override
    public void drawLine(int x1, int y1, int x2, int y2, Colors color) {
        Objects.requireNonNull(color);
        coolGraphics.drawLine(x1, y1, x2, y2, toColorPlus(color));
    }

    @Override
    public void drawRectangle(int x, int y, int width, int height, Colors color) {
        Objects.requireNonNull(color);
        var c = toColorPlus(color);
        coolGraphics.drawLine(x, y, x + width, y, c);
        coolGraphics.drawLine(x + width, y, x + width, y + height, c);
        coolGraphics.drawLine(x + width, y + height, x, y + height, c);
        coolGraphics.drawLine(x, y + height, x, y, c);
    }

    @Override
    public void drawEllipse(int x, int y, int width, int height, Colors color) {
        Objects.requireNonNull(color);
        coolGraphics.drawEllipse(x, y, width, height, toColorPlus(color));
    }

    @Override
    public void waitForMouseEvents(MouseCallback callback) {
        Objects.requireNonNull(callback);
        coolGraphics.waitForMouseEvents(callback::mouseClicked);
    }
}
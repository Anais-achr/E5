package fr.uge.poo.paint.ex5;

import java.awt.*;

public final class CoolGraphicAdapter implements Canvas {
    private final CoolGraphics coolGraphics = new CoolGraphics("cool", 800, 600);

    @Override
    public void clear(Color white) {
        coolGraphics.repaint(CoolGraphics.ColorPlus.WHITE);
    }

    @Override
    public void drawLine(Graphics2D graphics, int x1, int y1, int x2, int y2) {
        coolGraphics.drawLine(x1, y1, x2, y2, CoolGraphics.ColorPlus.BLACK);
    }

    @Override
    public void drawRectangle(Graphics2D graphics, int x, int y, int width, int height) {
        coolGraphics.drawLine(x, y, x+width, y, CoolGraphics.ColorPlus.BLACK);
        coolGraphics.drawLine(x, y, x, y+height, CoolGraphics.ColorPlus.BLACK);
        coolGraphics.drawLine(x, y+height, x+width, y+height, CoolGraphics.ColorPlus.BLACK);
        coolGraphics.drawLine(x+width, y, x+width, y+height, CoolGraphics.ColorPlus.BLACK);
    }

    @Override
    public void drawEllipse(Graphics2D graphics, int x, int y, int width, int height) {
        coolGraphics.drawEllipse(x, y, width, height, CoolGraphics.ColorPlus.BLACK);
    }

    @Override
    public void onMouseClick(int x, int y) {

    }

    @Override
    public void waitForMouseEvents(MouseCallback mouseCallback) {

    }
}

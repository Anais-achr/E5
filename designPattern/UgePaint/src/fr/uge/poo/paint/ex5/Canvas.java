package fr.uge.poo.paint.ex5;

import java.awt.*;

public interface Canvas {
    void clear(Color white);
    void drawLine(Graphics2D graphics, int x1, int y1, int x2, int y2);
    void drawRectangle(Graphics2D graphics, int x, int y, int width, int height);
    void drawEllipse(Graphics2D graphics, int x, int y, int width, int height);
    void onMouseClick(int x, int y);

    void setColor(Color color);

    @FunctionalInterface
    public interface MouseCallback {
        void mouseClicked(int x, int y);
    }
    void waitForMouseEvents(MouseCallback mouseCallback);
}


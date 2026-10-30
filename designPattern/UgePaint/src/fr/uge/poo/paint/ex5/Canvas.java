package fr.uge.poo.paint.ex5;



public interface Canvas {
    void clear(Colors color);
    void drawLine(int x1, int y1, int x2, int y2, Colors color);
    void drawRectangle(int x, int y, int width, int height, Colors color);
    void drawEllipse(int x, int y, int width, int height, Colors color);

    @FunctionalInterface
    interface MouseCallback {
        void mouseClicked(int x, int y);
    }
    void waitForMouseEvents(MouseCallback callback);
}




package fr.uge.poo.simplegraphics;



import java.awt.Color;
import java.awt.Graphics2D;

public class SimpleGraphicsExample {
    private static void drawAll(Graphics2D graphics) {
        graphics.setColor(Color.BLACK);
        graphics.drawRect(100, 20, 40, 140);

        graphics.drawLine(0, 0, 800, 600);
        graphics.drawLine(800, 0, 0, 600);

        graphics.drawOval(100, 20, 40, 140);
    }

    public static void main(String[] args) {
        SimpleGraphics area = new SimpleGraphics("area", 800, 600);
        area.clear(Color.WHITE);
        area.render(SimpleGraphicsExample::drawAll);
        //canvas.render(graphics -> drawAll(graphics));
    }
}

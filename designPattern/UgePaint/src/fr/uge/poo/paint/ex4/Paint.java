package fr.uge.poo.paint.ex4;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.Color;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Paint {

    private static void callback(SimpleGraphics area, Drawing drawing, int x, int y) {
        drawing.onclick(x, y);
        area.clear(Color.WHITE);
        area.render(drawing::drawAll);
    }

    public static void main(String[] args) throws IOException {
        Path path = Paths.get("draw2.txt");
        var drawing = Drawing.fromFile(path);

        var area = new SimpleGraphics("area", 800, 600);
        area.clear(Color.WHITE);
        area.render(drawing::drawAll);
        area.waitForMouseEvents((x, y) -> callback(area, drawing, x, y));
    }
}
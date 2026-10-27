package fr.uge.poo.paint.ex5;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.*;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Paint {
    private final Canvas canvas;

    public Paint(Canvas canvas) {
        this.canvas = canvas;
    }

//    private static void callback(Canvas area, int x, int y) {
//        area.onMouseClick(x, y);
//        area.clear(Color.WHITE);
//        //area.render(drawing::drawAll);
//    }

    public static void main(String[] args) throws IOException {
        Canvas canvas;
        if (args.length == 1 && args[0].equals("-legacy")) {
            canvas = new SimpleGraphicAdapter();
        } else {
            canvas = new CoolGraphicAdapter();
        }

        Path path = Paths.get("/home/26_epigep-in-5/anais.aoucher/Bureau/E5/designPattern/UgePaint/draw2.txt");
        var drawing = Drawing.fromFile(path);

        var paint = new Paint(canvas);

        canvas.clear(Color.WHITE);
        drawing.drawAll();
        canvas.waitForMouseEvents((x, y) -> callback(canvas, x, y));
    }
}
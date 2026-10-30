package fr.uge.poo.paint.ex5;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.*;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;

public class Paint {
    private final Canvas canvas;
    private final Drawing drawing;

    public Paint(Canvas canvas, Drawing drawing) {
        this.canvas = Objects.requireNonNull(canvas);
        this.drawing = Objects.requireNonNull(drawing);
    }


    public static void main(String[] args) throws IOException {
        Canvas canvas;
        if (args.length == 1 && args[0].equals("-legacy")) {
            canvas = new SimpleGraphicAdapter("simple", 800, 600);
        } else {
            canvas = new CoolGraphicAdapter("cool", 800, 600);
        }

        Path path = Paths.get("/Users/anaisaoucher/git/E5/designPattern/UgePaint/draw2.txt");
        var drawingFile = Drawing.fromFile(path);

        var paint = new Paint(canvas, drawingFile);

        paint.canvas.clear(Colors.WHITE);
        paint.drawing.drawAll(paint.canvas);

        paint.canvas.waitForMouseEvents((x, y) -> {
            paint.drawing.onclick(x, y);
            paint.canvas.clear(Colors.WHITE);
            paint.drawing.drawAll(paint.canvas);
        });
    }
}
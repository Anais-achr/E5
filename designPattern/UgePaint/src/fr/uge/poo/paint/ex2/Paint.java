package fr.uge.poo.paint.ex2;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.Color;
import java.awt.Graphics2D;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Stream;

public class Paint {

    public static List<Line> readFile(Path path) throws IOException {
        List<Line> res = new ArrayList<>();

        try(Stream<String> lines = Files.lines(path)) {
            lines.forEach(line -> {
                String[] tokens = line.split(" ");
                int x1 = Integer.parseInt(tokens[1]);
                int y1 = Integer.parseInt(tokens[2]);
                int x2 = Integer.parseInt(tokens[3]);
                int y2 = Integer.parseInt(tokens[4]);

                //System.out.println("x1 = " + x1 + " y1 = " + y1 + " x2 = " + x2 + " y2 = " + y2 );

                res.add(new Line(x1, y1, x2, y2));
            });
        }

        return res;
    }

    private static void drawLines(Graphics2D graphics, List<Line> lines) {
        Objects.requireNonNull(lines);

        graphics.setColor(Color.BLACK);
        for(var line : lines) {
            graphics.drawLine(line.x1(), line.y1(), line.x2(), line.y2());
        }
    }

    public static void main(String[] args) throws IOException {
        Path path = Paths.get("draw1.txt");

        var list = readFile(path);

        SimpleGraphics area = new SimpleGraphics("area", 800, 600);
        area.clear(Color.WHITE);
        area.render(graphics2D -> drawLines(graphics2D, list));
    }
}

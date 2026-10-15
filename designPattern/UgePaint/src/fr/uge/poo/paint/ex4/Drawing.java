package fr.uge.poo.paint.ex4;

import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Stream;

public class Drawing {
    private final List<Shape> shapes;
    private Shape selected;


    private Drawing(List<Shape> shapes) {
        this.shapes = shapes;
    }

    static Drawing fromFile(Path path) throws IOException {
        List<Shape> res = new ArrayList<>();

        try(Stream<String> lines = Files.lines(path)) {
            lines.forEach(line -> {
                String[] tokens = line.split(" ");
                var shape = tokens[0];
                int x1 = Integer.parseInt(tokens[1]);
                int y1 = Integer.parseInt(tokens[2]);
                int x2 = Integer.parseInt(tokens[3]);
                int y2 = Integer.parseInt(tokens[4]);

                var forme = switch (shape) {
                    case "ellipse" -> { yield new Elipse(x1, y1, x2, y2); }
                    case "line" -> { yield new Line(x1, y1, x2, y2); }
                    case "rectangle" -> { yield new Rectangle(x1, y1, x2, y2); }
                    default -> throw new IllegalStateException("Unexpected value: " + shape);
                };

                res.add(forme);
            });
        }

        return new Drawing(res);
    }

    public void onclick(int x, int y) {
        //on trie les distance et on prend la plus petite


        //on modifie la shape selected
        //on redessine

    }

    public void drawAll(Graphics2D graphics) {
        Objects.requireNonNull(shapes);

        graphics.setColor(Color.BLACK);
        for(var shape : shapes) {
            shape.draw(graphics);
        }
    }
}

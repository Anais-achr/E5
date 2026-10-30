package fr.uge.poo.paint.ex5;

import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Drawing {
    private final List<Shape> shapes;
    private Shape selected;

    private Drawing(List<Shape> shapes) {
        this.shapes = List.copyOf(shapes);
    }

    public static Drawing fromFile(Path path) throws IOException {
        Objects.requireNonNull(path);
        var res = new ArrayList<Shape>();

        try (Stream<String> lines = Files.lines(path)) {
            lines.forEach(line -> {
                var tokens = line.split(" ");
                int x1 = Integer.parseInt(tokens[1]);
                int y1 = Integer.parseInt(tokens[2]);
                int x2 = Integer.parseInt(tokens[3]);
                int y2 = Integer.parseInt(tokens[4]);

                Shape shape = switch (tokens[0]) {
                    case "ellipse"   -> new Ellipse(x1, y1, x2, y2);
                    case "line"      -> new Line(x1, y1, x2, y2);
                    case "rectangle" -> new Rectangle(x1, y1, x2, y2);
                    default -> throw new IllegalStateException("Unexpected value: " + tokens[0]);
                };
                res.add(shape);
            });
        }

        return new Drawing(res);
    }

    public void onclick(int x, int y) {
        selected = shapes.stream()
                .collect(Collectors.minBy(
                        Comparator.comparingInt((Shape s) -> s.distanceSquaredTo(x, y))))
                .orElse(null);
    }

    public void drawAll(Canvas canvas) {
        Objects.requireNonNull(canvas);
        for (var shape : shapes) {
            shape.draw(canvas, shape == selected ? Colors.ORANGE : Colors.BLACK);
        }
    }
}
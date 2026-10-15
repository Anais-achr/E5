package fr.uge.poo.paint.ex3;

import fr.uge.poo.simplegraphics.SimpleGraphics;

import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Stream;

public class Paint {

    public static List<Shape> readFile(Path path) throws IOException {
        List<Shape> res = new ArrayList<>();

        try(Stream<String> lines = Files.lines(path)) {
            lines.forEach(line -> {
                String[] tokens = line.split(" ");
                var shape = tokens[0];

                var forme = switch (shape) {
                    case "ellipse" -> {
                        int x1 = Integer.parseInt(tokens[1]);
                        int y1 = Integer.parseInt(tokens[2]);
                        int width = Integer.parseInt(tokens[3]);
                        int height = Integer.parseInt(tokens[4]);

                        yield new Elipse(x1, y1, width, height);
                    }
                    case "line" -> {
                        int x1 = Integer.parseInt(tokens[1]);
                        int y1 = Integer.parseInt(tokens[2]);
                        int x2 = Integer.parseInt(tokens[3]);
                        int y2 = Integer.parseInt(tokens[4]);

                        yield new Line(x1, y1, x2, y2);
                    }

                    case "rectangle" -> {
                        int x1 = Integer.parseInt(tokens[1]);
                        int y1 = Integer.parseInt(tokens[2]);
                        int width = Integer.parseInt(tokens[3]);
                        int height = Integer.parseInt(tokens[4]);

                        yield new Rectangle(x1, y1, width, height);
                    }
                    default -> throw new IllegalStateException("Unexpected value: " + shape);
                };

                res.add(forme);
            });
        }

        return res;
    }

    private static void drawShapes(Graphics2D graphics, List<Shape> shapes) {
        Objects.requireNonNull(shapes);

        graphics.setColor(Color.BLACK);
        for(var shape : shapes) {
            shape.draw(graphics);

//            switch (shape) {
//                case Line line: {
//                    graphics.drawLine(line.x1(), line.y1(), line.x2(), line.y2());
//                    break;
//                }
//                case Elipse elipse : {
//                    graphics.drawOval(elipse.x(), elipse.y(), elipse.width(), elipse.height());
//                    break;
//                }
//                case Rectangle rectangle : {
//                    graphics.drawRect(rectangle.x(), rectangle.y(), rectangle.width(), rectangle.height());
//                    break;
//                }
//            }
        }
    }

    public static void main(String[] args) throws IOException {
        Path path = Paths.get("draw2.txt");

        var list = readFile(path);

        SimpleGraphics area = new SimpleGraphics("area", 800, 600);
        area.clear(Color.WHITE);
        area.render(graphics2D -> drawShapes(graphics2D, list));
    }
}

package fr.uge.poo.paint.ex4;

record Box(int x1, int y1, int x2, int y2) {
    int x() {
        return Math.min(x1, x2);
    }

    int y() {
        return Math.min(y1, y2);
    }

    int width() {
        return Math.abs(x2 - x1);
    }

    int height() {
        return Math.abs(y2 - y1);
    }

    int distanceSquaredTo(int px, int py) {
        int dx = (x1 + x2) / 2 - px;
        int dy = (y1 + y2) / 2 - py;
        return dx * dx + dy * dy;
    }
}
package fr.uge.poo.decoProxy.ex2;

public class ImageLazy implements Image {
    private final String url;

    public ImageLazy(String url) {
        this.url = url;
    }


    @Override
    public String name() {
        //initialize();
        //return new ImageLazy(url);
        return null;
    }

    @Override
    public int size() {
        //initialize();
        return 0; //image.size();
    }

    @Override
    public double hue() {
        //initialize();
        return 0; //image.hue();
    }

    public static Image download(String url) {
        return ImageRaw.download(url);
    }

    public static ImageLazy downloadLazy(String url) {
        return null; //download(url);
    }

}

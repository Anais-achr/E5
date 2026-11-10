package fr.uge.poo.decoProxy.ex2;

public interface Image {
    public String name();
    public int size();
    public double hue();

    public static Image download(String url) {
        return null;
    }

    public static Image downloadLazy(String url) {
        return ImageLazy.download(url);
    }

    @Override
    public boolean equals(Object o);

    @Override
    public int hashCode() ;
}



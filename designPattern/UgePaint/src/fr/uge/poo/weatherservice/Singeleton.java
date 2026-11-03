package fr.uge.poo.weatherservice;

public class Singeleton {

    private Singeleton() {

    }

    private static WeatherService INSTANCE;

    //retourner un optional (version fail)
    public static WeatherService getINSTANCE() {
        if(INSTANCE == null) {
            INSTANCE = new WeatherServiceTS();
        }

        return INSTANCE;
    }
}

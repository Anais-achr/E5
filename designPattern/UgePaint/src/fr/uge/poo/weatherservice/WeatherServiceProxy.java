package fr.uge.poo.weatherservice;

public class WeatherServiceProxy implements WeatherService{
    //private final WeatherServiceNTS service;
    private final Object lock;

    public WeatherServiceProxy() {
        //service = new WeatherServiceNTS();
        lock = new Object();
        super();
    }

    @Override
    public int query(String city) {
        synchronized (lock) {
            //return service.query(city);
        }
        return 0;
    }
}

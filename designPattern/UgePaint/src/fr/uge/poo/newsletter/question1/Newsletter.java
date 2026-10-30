package fr.uge.poo.newsletter.question1;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.function.Predicate;

public class Newsletter {
    private final String name;
    private final List<String> suscribers;

    public Newsletter(String name) {
        Objects.requireNonNull(name);
        this.name = name;
        this.suscribers = new ArrayList<>();
    }

    public Newsletter(String name, Predicate<User> predicat) {
        Objects.requireNonNull(name);
        this.name = name;
        this.suscribers = new ArrayList<>();
    }


    private void suscribe(String userEmail) {
        if(!suscribers.contains(userEmail)) {
            suscribers.add(userEmail);
        }
    }

    private void unsuscribe(String userEmail) {
        suscribers.remove(userEmail);
    }

    void sendMessage(String title, String content) {
        suscribers.stream().map(_ -> "[" + name + "] " + title);
    }
}

package fr.uge.poo.newsletter.question2;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.function.Predicate;

public class Newsletter {
    private final String name;
    private final Map<String, User> suscribers;
    private final Predicate<User> predicat;

    public Newsletter(String name) {
        Objects.requireNonNull(name);
        this.name = name;
        this.suscribers = new HashMap<>();
        this.predicat = user -> true;
    }

    public Newsletter(String name, Predicate<User> predicat) {
        Objects.requireNonNull(name);
        this.name = name;
        this.suscribers = new HashMap<>();
        this.predicat = predicat;
    }


    private void suscribe(String userEmail, User user) {
        if(predicat.test(user)) {
            suscribers.computeIfAbsent(userEmail, mail -> new User(user.name(), userEmail, user.age(), user.nationality()));
        } else {
            System.err.println("tu peux pas hahahahaha looooser");
        }
    }

    private void unsuscribe(String userEmail) {
        suscribers.remove(userEmail);
    }

    void sendMessage(String title, String content) {
        suscribers.entrySet().stream().map(_ -> "[" + name + "] " + title);
    }

    public static void main(String[] args) {
        Predicate<User> predicatPotter = user -> (user.nationality() == User.Nationality.BRITISH && user.age() >= 18);
        var potterEver = new Newsletter("Potter 4ever", predicatPotter);

        Predicate<User> predicatJava = user -> (
                        (user.nationality() == User.Nationality.FRENCH || user.nationality() == User.Nationality.BRITISH)
                        && user.age() >= 18);
        var javaEver = new Newsletter("Java 4ever", predicatJava);

        Predicate<User> predicatWhyMe = user -> (user.age() % 2 == 0 && user.email().contains("@univ-eiffel.fr"));
        var wheMe = new Newsletter("Why me!", predicatWhyMe);

        var user1 = new User("theo", "theo@jesuisfou.haha", 114, User.Nationality.FRENCH);
        var user2 = new User("etiennnne", "etienne@@univ-eiffel.fr", 4, User.Nationality.BRITISH);

        potterEver.suscribe("theo@jesuisfou.haha", user1);
        javaEver.suscribe("theo@jesuisfou.haha", user1);
        wheMe.suscribe("theo@jesuisfou.haha", user1);

        potterEver.suscribe("etienne@@univ-eiffel.fr", user2);
        javaEver.suscribe("etienne@@univ-eiffel.fr", user2);
        wheMe.suscribe("etienne@@univ-eiffel.fr", user2);
    }
}




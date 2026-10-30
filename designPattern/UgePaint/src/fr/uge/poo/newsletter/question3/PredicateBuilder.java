package fr.uge.poo.newsletter.question3;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;

public class PredicateBuilder {
    private final User user;
    private final List<Predicate<User>> predicates = new ArrayList<>();

    public PredicateBuilder(User user) {
        this.user = user;
    }

    public Predicate<User> build() {
        return new Predicate<User>() {
            @Override
            public boolean test(User user) {
                return predicates.stream().forEach(p -> p.test(user));
            }
        }
    }
}

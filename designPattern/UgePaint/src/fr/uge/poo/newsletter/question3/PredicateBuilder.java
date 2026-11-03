package fr.uge.poo.newsletter.question3;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.function.Predicate;

public class PredicateBuilder {
    private final User user;
    private final List<Predicate<User>> predicatesAge = new ArrayList<>();
    private final List<Predicate<User>> predicatesNationality = new ArrayList<>();

    public PredicateBuilder(User user) {
        this.user = Objects.requireNonNull(user);
    }

//    public PredicateBuilder nationality(User.Nationality nationality) {
//        predicates.add(user -> user.nationality().equals(nationality));
//        return this;
//    }
//
//    public PredicateBuilder ageMin(int n){
//        predicates.add(user -> user.age() >= n);
//        return this;
//    }
//
//    public PredicateBuilder ageMax(int n){
//        predicates.add(user -> user.age() <= n);
//        return this;
//    }
//
//    public Predicate<User> build() {
//        return new Predicate<User>() {
//            @Override
//            public boolean test(User user) {
//                for(var p : predicates) {
//                    if(!p.test(user)) {
//                        return false;
//                    }
//                }
//                return true;
//            }
//        };
//    }
}

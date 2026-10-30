package fr.uge.poo.uberClient;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ThreadLocalRandom;

public class UberClientBuilder {
    private String firstName;
    private String lastName;
    private long uid;
    private List<Integer> grades = new ArrayList<>();
    private List<String> emails = new ArrayList<>();
    private List<String> phoneNumbers = new ArrayList<>();

    public UberClientBuilder firstName(String firstName) {
        this.firstName = Objects.requireNonNull(firstName);
        return this;
    }

    public UberClientBuilder lastName(String lastName) {
        this.lastName = Objects.requireNonNull(lastName);
        return this;
    }

    public UberClientBuilder uid(long uid) {
        this.uid = uid;
        return this;
    }

    public UberClientBuilder randomUid() {
        this.uid = ThreadLocalRandom.current().nextLong(0,Long.MAX_VALUE);
        return this;
    }

    public UberClientBuilder grade(int grade) {
        this.grades.add(grade);
        return this;
    }

    public UberClientBuilder grades(List<Integer> grades) {
        Objects.requireNonNull(grades);
        this.grades.addAll(grades);
        return this;
    }


    public UberClientBuilder email(String email) {
        Objects.requireNonNull(email);
        this.emails.add(email);
        return this;
    }

    public UberClientBuilder emails(List<String> emails) {
        Objects.requireNonNull(emails);
        this.emails.addAll(emails);
        return this;
    }

    public UberClientBuilder phoneNumber(String phoneNumber) {
        this.phoneNumbers.add(phoneNumber);
        return this;
    }

    public UberClientBuilder phoneNumbers(List<String> phoneNumbers) {
        Objects.requireNonNull(phoneNumbers);
        this.phoneNumbers.addAll(phoneNumbers);
        return this;
    }

    public UberClient build() {
        return new UberClient(firstName, lastName, uid, grades, emails, phoneNumbers);
    }
}

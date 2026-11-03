package fr.uge.poo.newsletter.question5;

public interface NewsletterObserver {
    default void onSuscribe(Newsletter newsletter, User user) {}
    default void onUnsuscribe(Newsletter newsletter, User user) {}
    default void onSend(Newsletter newsletter, String title, String content) {}
}

package fr.uge.poo.decoProxy.ex1;

public class MainDuck {
    public static void main(String[] args) {
//        Duck duck1 = new RegularDuck();
//        duck1.quack();
//        Duck duck2 = new LoggedDuck(new RegularDuck());
//        duck2.quack();
//        duck1.quack();
//        duck2.quack();

        Duck duck = new LoggedDuck(new RegularDuck());
        duck.quackManyTimes(2);
    }
}

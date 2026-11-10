package fr.uge.poo.decoProxy.ex1;

public interface Duck {
    void quack();
    default void quackManyTimes(int n) {
        for(int i=0; i < n; i++){
            quack();
        }
    }
}

class AtomicDuck implements Duck{
    @Override
    public void quack() {
        System.out.println("Atomic Quack");
    }

    @Override
    public void quackManyTimes(int n) {
        for(int i=0; i < n; i++){
            quack();
        }
    }

}
class RegularDuck implements Duck {

    @Override
    public void quack() {
        System.out.println("Regular Quack !");
    }

    @Override
    public void quackManyTimes(int n) {
        for(int i=0; i < n; i++){
            quack();
        }
    }
}


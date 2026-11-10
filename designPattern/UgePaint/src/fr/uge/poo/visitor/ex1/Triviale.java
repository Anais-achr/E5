package fr.uge.poo.visitor.ex1;

import java.util.Scanner;

public class Triviale {

    public static void main(String[] args) {

        var parser = new STPParser();

        try(var scanner = new Scanner(System.in)) {
            while(scanner.hasNextLine()) {
                var command = STPParser.parse(scanner.nextLine());

                if(command.isEmpty()) {
                    IO.println("Au revoir");
                    break;
                }

                if(command.get() instanceof StartTimerCmd) {
                    IO.println("Pas compris");
                }
                if(command.get() instanceof StopTimerCmd) {
                    IO.println("Pas compris");
                }
                if(command.get() instanceof ElapsedTimeCmd) {
                    IO.println("Pas compris");
                }

            }
        }

    }
}

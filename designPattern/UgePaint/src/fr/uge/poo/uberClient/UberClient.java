package fr.uge.poo.uberClient;

import java.util.List;
import java.util.Objects;
import java.util.concurrent.ThreadLocalRandom;

public class UberClient {

   private final String firstName;
   private final String lastName;
   private final long uid;
   private final List<Integer> grades;
   private final List<String> emails;
   private final List<String> phoneNumbers;



   public UberClient(String firstName, String lastName, long uid, List<Integer> grades, List<String> emails, List<String> phoneNumbers) {
       this.firstName = Objects.requireNonNull(firstName);
       this.lastName = Objects.requireNonNull(lastName);
       if (uid<0) {
           throw new IllegalArgumentException("UID must be positive");
       }
       this.uid = uid;
       this.grades = List.copyOf(grades);
       for(var grade : grades){
           if (grade < 1 ||grade > 5) {
               throw new IllegalArgumentException("All grades must be between 1 and 5");
           }
       }
       this.emails = List.copyOf(emails);
       this.phoneNumbers = List.copyOf(phoneNumbers);
       if (grades.size()==0){
           throw new IllegalArgumentException("A client must have at least one grade");
       }
       if (emails.size()==0 && phoneNumbers.size()==0) {
           throw new IllegalArgumentException("A client must have at least an email or a phoneNumber");
       }


   }
   
   public UberClient(String firstName, String lastName, List<Integer> grades, List<String> emails, List<String> phoneNumbers) {
       this(firstName, lastName, ThreadLocalRandom.current().nextLong(0,Long.MAX_VALUE),grades,emails,phoneNumbers);
   }

   public static void main(String[] args) {
        //var arnaud = new UberClient("Arnaud","Carayol",1,List.of(1,2,5,2,5,1,1,1),List.of("arnaud.carayol@univ-eiffel.fr","arnaud.carayol@u-pem.fr"),List.of("07070707070707"));
        //var youssef = new UberClient("Youssef", "Bergeron", List.of(5), List.of("youssefbergeron@outlook.fr"),List.of());

        var arnaud = new UberClientBuilder()
                .firstName("Arnaud")
                .lastName("Carayol")
                .uid(1L)
                .grades(List.of(1,2,5,2,5,1,1,1))
                .emails(List.of("arnaud.carayol@univ-eiffel.fr"))
                .phoneNumbers(List.of("07070707070707"))
                .build();

        var youssef = new UberClientBuilder()
                .firstName("Youssef")
                .lastName("Bergeron")
                .grade(5)
                .email("youssefbergeron@outlook.fr")
                .phoneNumbers(List.of())
                .randomUid()
                .build();
   }

}
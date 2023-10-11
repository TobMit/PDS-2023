package org.example;

import com.sun.source.tree.Tree;
import net.datafaker.Faker;


import java.lang.reflect.Array;
import java.util.*;
import java.text.SimpleDateFormat;

/**
 * Hello world!
 *
 */
public class App 
{

    public static final int POCET_ZNACIEK = 100;
    private static ArrayList<Pair> znacky_aut = new ArrayList<Pair>();
    private static ArrayList<Pair> stavy_aut = new ArrayList<Pair>();
    private static ArrayList<Pair> typy_aut = new ArrayList<Pair>();
    private static Faker faker = new Faker(new Locale("sk"));

    public static void main( String[] args )
    {


//        String carBrand = faker.vehicle().manufacturer();
        for (int i = 0; i < 100; i++) {
            String birthNumber = generateBirthNumber(faker);
            System.out.println(birthNumber + " " + getSum(birthNumber));
        }

        carGenerator();
    }

    private static void carGenerator() {
        TreeMap<String, String> tmpZnacky = new TreeMap<String, String>();
        while (tmpZnacky.size() < POCET_ZNACIEK) {
            String carBrand = faker.vehicle().manufacturer();
            if (!tmpZnacky.containsKey(carBrand)) {
                tmpZnacky.put(carBrand, carBrand);
            }
        }

        int i = 0;
        for (Map.Entry<String, String> entry : tmpZnacky.entrySet()) {
            znacky_aut.add(new Pair(String.valueOf(i), entry.getKey()));
            i++;
        }

        System.out.println("Auta vygenerovane: " + znacky_aut.size());
    }

    private static void stavGenerator() {
        TreeMap<String,String> tmpStavy = new TreeMap<String,String>();
        ArrayList<String> stavy = new ArrayList<String>(List.of(new String[]{"Pozicane", "Volne"}));
        for (String stav : stavy) {
            if (!tmpStavy.containsKey(stav)) {
                tmpStavy.put(stav, stav);
            }
        }
        int i = 0;
        for (Map.Entry<String, String> entry : tmpStavy.entrySet()) {
            stavy_aut.add(new Pair(String.valueOf(i), entry.getKey()));
            i++;
        }
    }

    private static void typyGenerator() {
        TreeMap<String, String> tmpTypy = new TreeMap<>();
        ArrayList<String> typy = new ArrayList<String>(List.of(new String[]{"Combi", "Suv", "Sedan"}));
        for (String typ: typy) {
            if (!tmpTypy.containsKey(typ)) {
                tmpTypy.put(typ, typ);
            }
        }
        int i =0;
        for (Map.Entry<String, String> entry : tmpTypy.entrySet()) {
            typy_aut.add(new Pair(String.valueOf(i), entry.getKey()));
            i++;
        }
    }

    private static void adresaGenerator() {


    }

    private static String generateBirthNumber(Faker faker) {
        // Generate a random date of birth between 1990 and 2003
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, 1990);
        Date startDate = calendar.getTime();
        calendar.set(Calendar.YEAR, 2003);
        Date endDate = calendar.getTime();

        // Get a random date of birth within the specified range
        Date dateOfBirth = faker.date().between(startDate, endDate);

        // Format the date of birth as needed
        SimpleDateFormat yearFormat = new SimpleDateFormat("yy");
        String lastTwoDigitsOfYear = yearFormat.format(dateOfBirth);

        SimpleDateFormat monthDayFormat = new SimpleDateFormat("MM");
        String formattedMonthDay = monthDayFormat.format(dateOfBirth);

        SimpleDateFormat dayFormat = new SimpleDateFormat("dd");
        String formattedDay = dayFormat.format(dateOfBirth);

        // Add a 50% chance to add +50 to the month part
        if (faker.bool().bool()) {
            formattedMonthDay = String.format("%02d", Integer.parseInt(formattedMonthDay) + 50);
        }

        // Ensure day and year have leading zeros if less than 10
        formattedDay = String.format("%02d", Integer.parseInt(formattedDay));
        lastTwoDigitsOfYear = String.format("%02d", Integer.parseInt(lastTwoDigitsOfYear));

        // Generate a unique identifier or use additional information based on your country's format
        // For demonstration purposes, generate a random 4-digit number
        String uniqueIdentifier = String.format("%04d", faker.number().numberBetween(1000, 9999));

        // Calculate the current sum
        String birthNumberIdentifier = lastTwoDigitsOfYear + formattedMonthDay + formattedDay + uniqueIdentifier;
        int currentSum = getSum(birthNumberIdentifier);

        StringBuilder finalBirthNumberBuilder = new StringBuilder();

        if (currentSum % 11 != 0) {

            // Calculate the remainder when the current sum is divided by 11
            int remainder = currentSum % 11;

            // Calculate the adjustment needed to make the whole number divisible by 11
            int adjustment = (11 - remainder) % 11;

            // Select a random digit from the unique identifier
            int randomDigitIndex = faker.number().numberBetween(0, 4); // Assuming a 4-digit unique identifier
            int selectedDigit = Character.getNumericValue(uniqueIdentifier.charAt(randomDigitIndex));

            // Adjust the selected digit to make the whole number divisible by 11
            int adjustedDigit = (selectedDigit + adjustment) % 10;

            // Handle carry-over if the adjusted digit is larger than 10
            int carry = (selectedDigit + adjustment) / 10;

            // Update the unique identifier with the adjusted digit and handle carry-over
            StringBuilder updatedIdentifierBuilder = new StringBuilder(uniqueIdentifier);
            updatedIdentifierBuilder.setCharAt(randomDigitIndex, Character.forDigit(adjustedDigit, 10));

            // Handle carry-over to the next digit or wrap around to the first digit
            for (int i = randomDigitIndex + 1; i < 4 && carry > 0; i++) {
                int currentDigit = Character.getNumericValue(updatedIdentifierBuilder.charAt(i));
                int newDigit = (currentDigit + carry) % 10;
                carry = (currentDigit + carry) / 10;
                updatedIdentifierBuilder.setCharAt(i, Character.forDigit(newDigit, 10));
            }

            if (carry > 0) {
                // If carry-over remains, wrap around to the first digit
                int currentFirstDigit = Character.getNumericValue(updatedIdentifierBuilder.charAt(0));
                int newFirstDigit = (currentFirstDigit + carry) % 10;
                updatedIdentifierBuilder.setCharAt(0, Character.forDigit(newFirstDigit, 10));
            }

            String updatedIdentifier = updatedIdentifierBuilder.toString();

            // Use StringBuilder for efficient string concatenation
            finalBirthNumberBuilder.append(lastTwoDigitsOfYear)
                    .append(formattedMonthDay)
                    .append(formattedDay)
                    .append("/")
                    .append(updatedIdentifier);
        } else {
            finalBirthNumberBuilder.append(lastTwoDigitsOfYear)
                    .append(formattedMonthDay)
                    .append(formattedDay)
                    .append("/")
                    .append(uniqueIdentifier);
        }

        return finalBirthNumberBuilder.toString();
    }

    private static int getSum(String number) {
        int sum = 0;
        for (int i = 0; i < number.length(); i++) {
            char digitChar = number.charAt(i);
            if (Character.isDigit(digitChar)) {
                int digit = Character.getNumericValue(digitChar);
                sum += digit;
            }
        }
        return sum;
    }
}

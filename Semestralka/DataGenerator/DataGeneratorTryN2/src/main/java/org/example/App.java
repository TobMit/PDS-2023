package org.example;

import net.datafaker.Faker;
import net.datafaker.transformations.JsonTransformer;
import org.example.DataSaver.Osoba;
import org.example.DataSaver.Vozidlo;


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;
import java.text.SimpleDateFormat;

/**
 * Hello world!
 *
 */
public class App 
{

    public static final int POCET_ZNACIEK = 100;
    public static final int POCET_ULIC = 70;
    public static final int POCET_VOZIDIEL = 35;
    public static final int POCET_OSOB = 2000;
    public static final double PRAVDEBODOBNST_ZENY = 0.48;

    private static ArrayList<Pair<Integer, String>> znacky_aut = new ArrayList<Pair<Integer, String>>();
    private static ArrayList<Pair<Integer, String>> stav_auta = new ArrayList<Pair<Integer, String>>();
    private static ArrayList<Pair<Integer, String>> typy_aut = new ArrayList<Pair<Integer, String>>();
    private static ArrayList<Pair<String, String>> adresa = new ArrayList<Pair<String, String>>();
    private static ArrayList<String> arrUlice = new ArrayList<>();
    private static ArrayList<String> arrRodCisloMuzi = new ArrayList<>();
    private static ArrayList<String> arrRodCisloZeny = new ArrayList<>();
    private static ArrayList<String> arrObcianskyPreukaz = new ArrayList<>();
    private static ArrayList<String> arrNameWoman = new ArrayList<>();
    private static ArrayList<String> arrNameMan = new ArrayList<>();
    private static ArrayList<String> arrPriezviskoWoman = new ArrayList<>();
    private static ArrayList<String> arrPriezviskoMan = new ArrayList<>();
    private static ArrayList<Osoba> osoba = new ArrayList<>();
    private static ArrayList<Vozidlo> vozidla = new ArrayList<>();

    private static Faker faker = new Faker(new Locale("sk"));
    private static Random random = new Random();

    public static void main( String[] args )
    {


//        String carBrand = faker.vehicle().manufacturer();
//        for (int i = 0; i < 100; i++) {
//            String birthNumber = generateBirthNumber(faker);
//            System.out.println(birthNumber + " " + getSum(birthNumber));
//        }

        carGenerator();
        typyGenerator();
        stavGenerator();
        adresaGenerator();
        ulicaGenerator();
        rodneCislaGenerator();
        obcianskyPreukazGenerator();
        menaPriezviskaGenerator();
        osobaGenerator();
        vozidlaGenerator();
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
            znacky_aut.add(new Pair<Integer, String>(i, entry.getKey()));
            i++;
        }

        System.out.println("Znacky aut vygenerovane: " + znacky_aut.size());
    }

    private static void stavGenerator() {
//        TreeMap<String,String> tmpStavy = new TreeMap<String,String>();
        ArrayList<String> stavy = new ArrayList<String>(List.of(new String[]{"Pozicane", "Volne"}));
//        for (String stav : stavy) {
//            if (!tmpStavy.containsKey(stav)) {
//                tmpStavy.put(stav, stav);
//            }
//        }
//        for (Map.Entry<String, String> entry : tmpStavy.entrySet()) {
//            stavy_aut.add(new Pair(String.valueOf(i), entry.getKey()));
//            i++;
//        }
        int i = 0;
        for (String s : stavy) {
            stav_auta.add(new Pair<Integer, String>(i, s));
            i++;
        }
        System.out.println("Stav auta vygenerovane: " + stav_auta.size());
    }

    private static void typyGenerator() {
//        TreeMap<String, String> tmpTypy = new TreeMap<>();
        ArrayList<String> typy = new ArrayList<String>(List.of(new String[]{"Combi", "Suv", "Sedan"}));
//        for (String typ: typy) {
//            if (!tmpTypy.containsKey(typ)) {
//                tmpTypy.put(typ, typ);
//            }
//        }
//        for (Map.Entry<String, String> entry : tmpTypy.entrySet()) {
//            typy_aut.add(new Pair(String.valueOf(i), entry.getKey()));
//        i++;
//        }
        int i =0;
        for (String s : typy) {
            typy_aut.add(new Pair<Integer, String>(i, s));
            i++;
        }
        System.out.println("Typy aut vygenerovane: " + typy_aut.size());
    }

    private static void adresaGenerator() {
        BufferedReader reader;
        try {
            reader = new BufferedReader(new FileReader(
                    "src/main/java/org/example/DataSaver/Resources/cities.txt"));
            String line = reader.readLine();
            while (line != null) {
                String[] obec = line.split(" ");
                if (obec.length == 2) {
                    adresa.add(new Pair(obec[1], obec[0]));
                }
                else {
                    StringBuilder builder = new StringBuilder();
                    for (int j = 0; j < obec.length - 1; j++) {
                        builder.append(obec[j] + " ");
                    }
                    // ten substring tam je pre to aby som orezal poslednu medzeru
                    adresa.add(new Pair(obec[obec.length - 1], builder.substring(0, builder.length() - 1)));

                }
                line = reader.readLine();
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("Adresy nacitane: " + adresa.size());
    }

    private static void ulicaGenerator() {
        // generuj názvy ulíc pomoco fakera
        TreeMap<String, String> ulice = new TreeMap<>();
        while (ulice.size() < POCET_ULIC){
            String tmp = faker.address().streetAddress(false);
            if (!ulice.containsKey(tmp)) {
                ulice.put(tmp, tmp);
            }
        }
        for (String s : ulice.keySet()) {
            arrUlice.add(s);
        }

        System.out.println("Pomocný zoznam ulíc vygenerovaný: " + arrUlice.size());
    }

    private static void rodneCislaGenerator() {
        TreeMap<String, String> muzi = new TreeMap<>();
        TreeMap<String, String> zeny = new TreeMap<>();
        while (muzi.size() < POCET_OSOB) {
            //todo for maros onyl man generate
            String tmp = generateBirthNumber();
            if (!muzi.containsKey(tmp)){
                muzi.put(tmp, tmp);
            }
        }
        for (String s : muzi.keySet()) {
            arrRodCisloMuzi.add(s);
        }
        System.out.println("Rodne cisla muzi vygenerovane: " + arrRodCisloMuzi.size());

        while (zeny.size() < POCET_OSOB) {
            //todo for maros onyl woman generate
            String tmp = generateBirthNumber();
            if (!zeny.containsKey(tmp)){
                zeny.put(tmp, tmp);
            }
        }
        for (String s : zeny.keySet()) {
            arrRodCisloZeny.add(s);
        }

        System.out.println("Rodne cisla zeny vygenerovane: " + arrRodCisloZeny.size());
    }

    private static void obcianskyPreukazGenerator() {
        TreeMap<String, String> obc = new TreeMap<>();
        while (obc.size() < 2*POCET_OSOB){
            StringBuilder builder = new StringBuilder();
            char tmp = 'A';
            builder.append((char) (tmp + random.nextInt(26)));
            builder.append((char) (tmp + random.nextInt(26)));
            builder.append(random.nextInt(9));
            builder.append(random.nextInt(9));
            builder.append(random.nextInt(9));
            builder.append(random.nextInt(9));
            builder.append(random.nextInt(9));
            builder.append(random.nextInt(9));
            if (!obc.containsKey(builder.toString())) {
                obc.put(builder.toString(), builder.toString());
            }
        }

        for (String s : obc.keySet()) {
            arrObcianskyPreukaz.add(s);
        }
        System.out.println("Cisla obcianských preukazov vygenerovane: " + arrObcianskyPreukaz.size());
    }

    private static void menaPriezviskaGenerator() {
        try {
            BufferedReader reader;

            // mena mužov
            reader = new BufferedReader(new FileReader("src/main/java/org/example/DataSaver/Resources/NameMan.txt"));
            String tmp = reader.readLine();
            while (tmp != null) {
                arrNameMan.add(tmp);
                tmp = reader.readLine();
            }
            reader.close();
            System.out.println("Mena muzov nacitane: " + arrNameMan.size());

            // mena žien
            reader = new BufferedReader(new FileReader("src/main/java/org/example/DataSaver/Resources/NameWoman.txt"));
            tmp = reader.readLine();
            while (tmp != null) {
                arrNameWoman.add(tmp);
                tmp = reader.readLine();
            }
            reader.close();
            System.out.println("Mena zien nacitane: " + arrNameWoman.size());

            // priezviska muzov
            reader = new BufferedReader(new FileReader("src/main/java/org/example/DataSaver/Resources/PriezviskoMan.txt"));
            tmp = reader.readLine();
            while (tmp != null) {
                arrPriezviskoMan.add(tmp);
                tmp = reader.readLine();
            }
            reader.close();
            System.out.println("Priezviska muzov nacitane: " + arrPriezviskoMan.size());

            // priezviska žien
            reader = new BufferedReader(new FileReader("src/main/java/org/example/DataSaver/Resources/PrizviskaWoman.txt"));
            tmp = reader.readLine();
            while (tmp != null) {
                arrPriezviskoWoman.add(tmp);
                tmp = reader.readLine();
            }
            reader.close();
            System.out.println("Priezviska zien nacitane: " + arrPriezviskoWoman.size());

        } catch (Exception e) {
            System.err.println(e);
        }
    }

    private static void osobaGenerator() {
        int pocetMuzov = 0;
        int pocetZien = 0;
        for (int i = 0; i < POCET_OSOB; i++) {
            Osoba tmpOsoba = new Osoba();
            if (random.nextDouble() > PRAVDEBODOBNST_ZENY){
                // generujeme muzov
                Pair<String, String> tmpAdresa = adresa.get(random.nextInt(adresa.size()));
                tmpOsoba.psc = tmpAdresa.key;
                tmpOsoba.rod_cislo = getRodCislo(false);
                tmpOsoba.Meno = arrNameMan.get(random.nextInt(arrNameMan.size()));
                tmpOsoba.Priezvisko = arrPriezviskoMan.get(random.nextInt(arrPriezviskoMan.size()));
                tmpOsoba.cislo_obcianskeho = getCisloObcianskeho();
                tmpOsoba.ulica = tmpAdresa.value;
                tmpOsoba.id_osoby = i;
                pocetMuzov++;
            } else {
                // generujeme zeny
                Pair<String, String> tmpAdresa = adresa.get(random.nextInt(adresa.size()));
                tmpOsoba.psc = tmpAdresa.key;
                tmpOsoba.rod_cislo = getRodCislo(true);
                tmpOsoba.Meno = arrNameWoman.get(random.nextInt(arrNameWoman.size()));
                tmpOsoba.Priezvisko = arrPriezviskoWoman.get(random.nextInt(arrPriezviskoWoman.size()));
                tmpOsoba.cislo_obcianskeho = getCisloObcianskeho();
                tmpOsoba.ulica = tmpAdresa.value;
                tmpOsoba.id_osoby = i;
                pocetZien++;
            }
//            System.out.println(tmpOsoba);
            osoba.add(tmpOsoba);
        }
        System.out.println("Vygenerované osoby: " + osoba.size());
        System.out.println("\tZeny: " + pocetZien);
        System.out.println("\tMuzi: " + pocetMuzov);
    }

    private static void vozidlaGenerator() {
        for (int i = 0; i < POCET_VOZIDIEL; i++) {
            Vozidlo tmpVozidlo = new Vozidlo();
            tmpVozidlo.znacka_auta = znacky_aut.get(random.nextInt(znacky_aut.size())).key;
            tmpVozidlo.typ_auta = typy_aut.get(random.nextInt(typy_aut.size())).key;
            tmpVozidlo.stav_vozidla = stav_auta.get(random.nextInt(stav_auta.size())).key;
            tmpVozidlo.ecv = ""; //todo for matus generator xD
            tmpVozidlo.pocet_miest_na_sedenie = random.nextInt(6); //todo premyslieť či to má zmysel random (môže byť miest na sedenie aj 3) a to moc nedáva zmysel
            tmpVozidlo.fotka = ""; //todo for maros toto nemam ponatia ako
            tmpVozidlo.rok_vyroby = 1989 + random.nextInt(32);
            char[] typ_motora = new char[]{'D', 'B', 'E'}; //dizel, benzín, elektrina
            tmpVozidlo.typ_motora = typ_motora[random.nextInt(typ_motora.length)];
            tmpVozidlo.seriove_cislo_vozidla = String.valueOf(i); //todo asi nejaký lepší generátor
            vozidla.add(tmpVozidlo);
        }
        System.out.println("Vygenerované vozidla: " + vozidla.size());
    }

    //todo transakcie viac máš maroš v hlasovke
    //todo uložiť do súboru, da sa pre triedy ktoré sa poutívajú spraviť custom toString ktorý by ti automaticky vygeneroval riadok

    private static String generateBirthNumber() {
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

    private static String getRodCislo(boolean zena) {
        String tmp;
        if (zena) {
            int tmpIndex = random.nextInt(arrRodCisloZeny.size());
            tmp = arrRodCisloZeny.get(tmpIndex);
            arrRodCisloZeny.remove(tmpIndex);
        } else {
            int tmpIndex = random.nextInt(arrRodCisloMuzi.size());
            tmp = arrRodCisloMuzi.get(tmpIndex);
            arrRodCisloMuzi.remove(tmpIndex);
        }

        return tmp;
    }

    private static String getCisloObcianskeho() {
        int tmpIndex = random.nextInt(arrObcianskyPreukaz.size());
        String tmp = arrObcianskyPreukaz.get(tmpIndex);
        arrObcianskyPreukaz.remove(tmpIndex);

        return tmp;
    }
}

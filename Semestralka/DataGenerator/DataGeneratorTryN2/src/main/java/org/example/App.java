package org.example;

import net.datafaker.Faker;
import org.example.DataSaver.DataSaver;
import org.example.DataSaver.Osoba;
import org.example.DataSaver.Transakcia;
import org.example.DataSaver.Vozidlo;


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Month;
import java.util.*;
import java.text.SimpleDateFormat;

import static org.example.DataSaver.DataSaver.CSV_DELIMETER;

/**
 * Hello world!
 *
 */
public class App 
{

    public static final int POCET_ZNACIEK = 100;
    public static final int POCET_ULIC = 70;
    public static final int POCET_VOZIDIEL = 50;
    public static final int POCET_OSOB = 2000;
    public static final double PRAVDEBODOBNST_ZENY = 0.48;

    public static final LocalDate START_DATE = LocalDate.of(2008, 6, 14);

    public static final LocalDate END_DATE = LocalDate.now();

    private static final ArrayList<Pair<Integer, String>> znacky_aut = new ArrayList<>();
    private static final ArrayList<Pair<Integer, String>> stav_auta = new ArrayList<>();
    private static final ArrayList<Pair<Integer, String>> typy_aut = new ArrayList<>();
    private static final ArrayList<Pair<String, String>> adresa = new ArrayList<>();
    private static final ArrayList<String> arrUlice = new ArrayList<>();
    private static final ArrayList<String> arrRodCisloMuzi = new ArrayList<>();
    private static final ArrayList<String> arrRodCisloZeny = new ArrayList<>();
    private static final ArrayList<String> arrObcianskyPreukaz = new ArrayList<>();
    private static final ArrayList<String> arrNameWoman = new ArrayList<>();
    private static final ArrayList<String> arrNameMan = new ArrayList<>();
    private static final ArrayList<String> arrPriezviskoWoman = new ArrayList<>();
    private static final ArrayList<String> arrPriezviskoMan = new ArrayList<>();
    private static final ArrayList<Osoba> osoba = new ArrayList<>();
    private static final ArrayList<Vozidlo> vozidla = new ArrayList<>();
    private static final ArrayList<Transakcia> transakcie = new ArrayList<>();

    private static final HashMap<String, List<Integer>> numberOfCarSeats = new HashMap<>();

    private static final Faker faker = new Faker(new Locale("sk"));
    private static final Random random = new Random();

    public static void main( String[] args ) {
        carGenerator();
        typyGenerator();
        stavGenerator();
        adresaGenerator();
        ulicaGenerator();
        rodneCislaGenerator();
        numberOfSeatsGenerator();
        obcianskyPreukazGenerator();
        menaPriezviskaGenerator();
        osobaGenerator();
        vozidlaGenerator();
        transakciaGenerator();

        saveData();
    }

    private static void saveData() {
        // Output files
        DataSaver typyAutSaver = new DataSaver("typy_aut.csv");
        DataSaver stavAutaSaver = new DataSaver("stav_aut.csv");
        DataSaver znackyAutSaver = new DataSaver("znacky_aut.csv");
        DataSaver adresaSaver = new DataSaver("adresa.csv");
        DataSaver osobaSaver = new DataSaver("osoba.csv");
        DataSaver vozidloSaver = new DataSaver("vozidlo.csv");
        DataSaver transakcieSaver = new DataSaver("transakcie.csv");

        // typy aut
        typyAutSaver.appendData("nazov_typu" + CSV_DELIMETER + "id_typu" + '\n');
        for (Pair<Integer, String > typAutaPair: typy_aut) {
            typyAutSaver.appendData(typAutaPair.value + CSV_DELIMETER + typAutaPair.key + '\n');
        }

        // stav aut
        stavAutaSaver.appendData("nazov_stavu" + CSV_DELIMETER + "id_stavu" + '\n');
        for (Pair<Integer, String > stavAutaPar: stav_auta) {
            stavAutaSaver.appendData(stavAutaPar.value + CSV_DELIMETER + stavAutaPar.key + '\n');
        }

        // znacka aut
        znackyAutSaver.appendData("nazov_znacky" + CSV_DELIMETER + "id_znacky" + '\n');
        for (Pair<Integer, String > znackyAutaPair: znacky_aut) {
            znackyAutSaver.appendData(znackyAutaPair.value + CSV_DELIMETER + znackyAutaPair.key + '\n');
        }

        // adresa
        adresaSaver.appendData("mesto" + CSV_DELIMETER + "psc" + '\n');
        for (Pair<String , String > adresaPair: adresa) {
            adresaSaver.appendData(adresaPair.key + CSV_DELIMETER + adresaPair.value + '\n');
        }

        // osoba
        osobaSaver.appendData("psc" + CSV_DELIMETER + "rod_cislo" + CSV_DELIMETER + "meno" +
                CSV_DELIMETER + "priezvisko" + CSV_DELIMETER + "cislo_obcianskeho" + CSV_DELIMETER + "ulica" + CSV_DELIMETER + "id_osoby" + '\n');
        for (Osoba osoba: osoba) {
            osobaSaver.appendData(osoba.toString());
        }

        // vozidlo
        vozidloSaver.appendData("znacka_auta" + CSV_DELIMETER + "typ_auta" + CSV_DELIMETER + "stav_vozidla" +
                CSV_DELIMETER + "ecv" + CSV_DELIMETER + "pocet_miest_na_sedenie" + CSV_DELIMETER + "fotka" + CSV_DELIMETER
                + "rok_vyroby" + CSV_DELIMETER + "pocet_najazdenych_km" + CSV_DELIMETER + "typ_motora" + CSV_DELIMETER + "seriove_cislo_vozidla" + '\n');
        for (Vozidlo vozidlo: vozidla) {
            vozidloSaver.appendData(vozidlo.toString());
        }

        // transakcie
        transakcieSaver.appendData("dat_od" + CSV_DELIMETER + "dat_do" + CSV_DELIMETER + "suma" +
                CSV_DELIMETER + "id_osoby" + CSV_DELIMETER + "id_vozidla" + '\n');
        for (Transakcia transakcia: transakcie) {
            transakcieSaver.appendData(transakcia.toString());
        }

        typyAutSaver.saveDataToFile();
        stavAutaSaver.saveDataToFile();
        znackyAutSaver.saveDataToFile();
        adresaSaver.saveDataToFile();
        osobaSaver.saveDataToFile();
        vozidloSaver.saveDataToFile();
        transakcieSaver.saveDataToFile();

    }

    private static void carGenerator() {
        TreeMap<String, String> tmpZnacky = new TreeMap<>();
        while (tmpZnacky.size() < POCET_ZNACIEK) {
            String carBrand = faker.vehicle().manufacturer();
            if (!tmpZnacky.containsKey(carBrand)) {
                tmpZnacky.put(carBrand, carBrand);
            }
        }

        int i = 1;
        for (Map.Entry<String, String> entry : tmpZnacky.entrySet()) {
            znacky_aut.add(new Pair<>(i, entry.getKey()));
            i++;
        }

        System.out.println("Znacky aut vygenerovane: " + znacky_aut.size());
    }

    private static void numberOfSeatsGenerator() {
        numberOfCarSeats.put("Abarth", List.of(2));
        numberOfCarSeats.put("Acura", List.of(2, 5, 7));
        numberOfCarSeats.put("Aixam", List.of(2));
        numberOfCarSeats.put("Alfa Romeo", List.of(2, 4, 5));
        numberOfCarSeats.put("Alpine", List.of(2));
        numberOfCarSeats.put("Aston Martin", List.of(2));
        numberOfCarSeats.put("Audi", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Baojun", List.of(5, 7));
        numberOfCarSeats.put("Bentley", List.of(4, 5));
        numberOfCarSeats.put("BMW", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Brilliance", List.of(5, 7));
        numberOfCarSeats.put("Bugatti", List.of(2));
        numberOfCarSeats.put("Buick", List.of(5, 7));
        numberOfCarSeats.put("BYD", List.of(5, 7));
        numberOfCarSeats.put("Cadillac", List.of(5, 7));
        numberOfCarSeats.put("Caterham", List.of(2));
        numberOfCarSeats.put("Chang'an", List.of(5, 7));
        numberOfCarSeats.put("Chevrolet", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Chrysler", List.of(5, 7));
        numberOfCarSeats.put("Citroën", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Dacia", List.of(5, 7));
        numberOfCarSeats.put("Daihatsu", List.of(2, 4, 5));
        numberOfCarSeats.put("Datsun", List.of(5));
        numberOfCarSeats.put("Dodge", List.of(5, 7));
        numberOfCarSeats.put("Dongfeng", List.of(5, 7));
        numberOfCarSeats.put("DS", List.of(4, 5));
        numberOfCarSeats.put("Dongfeng Fengshen", List.of(5, 7));
        numberOfCarSeats.put("Fiat", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Karma", List.of(4, 5));
        numberOfCarSeats.put("Ford", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Ferrari", List.of(2));
        numberOfCarSeats.put("Geely", List.of(5, 7));
        numberOfCarSeats.put("Genesis", List.of(5));
        numberOfCarSeats.put("GMC", List.of(5, 7));
        numberOfCarSeats.put("Hino Motors", List.of(2));
        numberOfCarSeats.put("Holden (HSV)", List.of(5, 7));
        numberOfCarSeats.put("Honda", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Hyundai", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Infiniti", List.of(5));
        numberOfCarSeats.put("Isuzu", List.of(2, 4, 5));
        numberOfCarSeats.put("Jaguar", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Jeep", List.of(4, 5, 7));
        numberOfCarSeats.put("Jie Fang", List.of(5, 7));
        numberOfCarSeats.put("Kantanka", List.of(5, 7));
        numberOfCarSeats.put("Koenigsegg", List.of(2));
        numberOfCarSeats.put("Kia", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Lada", List.of(5, 7));
        numberOfCarSeats.put("Lamborghini", List.of(2));
        numberOfCarSeats.put("Lancia", List.of(4, 5));
        numberOfCarSeats.put("Land Rover", List.of(5, 7));
        numberOfCarSeats.put("Lexus", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Ligier", List.of(2));
        numberOfCarSeats.put("Lincoln", List.of(5, 7));
        numberOfCarSeats.put("Lotus", List.of(2));
        numberOfCarSeats.put("LTI", List.of(4, 5));
        numberOfCarSeats.put("Luxgen", List.of(5, 7));
        numberOfCarSeats.put("Mahindra", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Maruti Suzuki", List.of(5, 7));
        numberOfCarSeats.put("Maserati", List.of(4, 5));
        numberOfCarSeats.put("Mastretta", List.of(2));
        numberOfCarSeats.put("Maybach", List.of(4, 5));
        numberOfCarSeats.put("Mazda", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("McLaren", List.of(2));
        numberOfCarSeats.put("Mercedes-Benz", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("MG", List.of(5));
        numberOfCarSeats.put("Microcar", List.of(2));
        numberOfCarSeats.put("Mini", List.of(2, 4, 5));
        numberOfCarSeats.put("Mitsubishi", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Morgan", List.of(2));
        numberOfCarSeats.put("NEVS", List.of(5, 7));
        numberOfCarSeats.put("Nissan", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Noble", List.of(2));
        numberOfCarSeats.put("Opel", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Pagani", List.of(2));
        numberOfCarSeats.put("Perodua", List.of(5));
        numberOfCarSeats.put("Peugeot", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("PGO", List.of(2));
        numberOfCarSeats.put("Porsche", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("PROTON", List.of(5, 7));
        numberOfCarSeats.put("Ram", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Ravon", List.of(5, 7));
        numberOfCarSeats.put("Renault", List.of(5, 7));
        numberOfCarSeats.put("Rimac", List.of(2));
        numberOfCarSeats.put("Roewe", List.of(5, 7));
        numberOfCarSeats.put("Rolls Royce", List.of(4, 5));
        numberOfCarSeats.put("Saleen", List.of(2, 4));
        numberOfCarSeats.put("Samand", List.of(5, 7));
        numberOfCarSeats.put("Renault Samsung Motors", List.of(5, 7));
        numberOfCarSeats.put("SEAT", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Senova", List.of(5, 7));
        numberOfCarSeats.put("Škoda", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Smart", List.of(2));
        numberOfCarSeats.put("SsangYong", List.of(5, 7));
        numberOfCarSeats.put("Subaru", List.of(5, 7));
        numberOfCarSeats.put("Suzuki", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Tata", List.of(5, 7));
        numberOfCarSeats.put("Tesla", List.of(5, 7));
        numberOfCarSeats.put("Tiba/Miniator", List.of(5, 7));
        numberOfCarSeats.put("Toyota", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Uniti", List.of(2));
        numberOfCarSeats.put("Vauxhall", List.of(5, 7));
        numberOfCarSeats.put("Venucia", List.of(5, 7));
        numberOfCarSeats.put("Volkswagen", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Volvo Cars", List.of(2, 4, 5, 7));
        numberOfCarSeats.put("Vuhl", List.of(2));
        numberOfCarSeats.put("Wuling", List.of(5, 7));
        numberOfCarSeats.put("IVM", List.of(5, 7));
    }

    private static void stavGenerator() {
//        TreeMap<String,String> tmpStavy = new TreeMap<String,String>();
        ArrayList<String> stavy = new ArrayList<>(List.of(new String[]{"Pozicane", "Volne"}));
//        for (String stav : stavy) {
//            if (!tmpStavy.containsKey(stav)) {
//                tmpStavy.put(stav, stav);
//            }
//        }
//        for (Map.Entry<String, String> entry : tmpStavy.entrySet()) {
//            stavy_aut.add(new Pair(String.valueOf(i), entry.getKey()));
//            i++;
//        }
        int i = 1;
        for (String s : stavy) {
            stav_auta.add(new Pair<>(i, s));
            i++;
        }
        System.out.println("Stav auta vygenerovane: " + stav_auta.size());
    }

    private static void typyGenerator() {
//        TreeMap<String, String> tmpTypy = new TreeMap<>();
        ArrayList<String> typy = new ArrayList<>(List.of(new String[]{"Combi", "Suv", "Sedan"}));
//        for (String typ: typy) {
//            if (!tmpTypy.containsKey(typ)) {
//                tmpTypy.put(typ, typ);
//            }
//        }
//        for (Map.Entry<String, String> entry : tmpTypy.entrySet()) {
//            typy_aut.add(new Pair(String.valueOf(i), entry.getKey()));
//        i++;
//        }
        int i = 1;
        for (String s : typy) {
            typy_aut.add(new Pair<>(i, s));
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
                    adresa.add(new Pair<>(obec[1], obec[0]));
                }
                else {
                    StringBuilder builder = new StringBuilder();
                    for (int j = 0; j < obec.length - 1; j++) {
                        builder.append(obec[j]).append(" ");
                    }
                    // ten substring tam je pre to aby som orezal poslednu medzeru
                    adresa.add(new Pair<>(obec[obec.length - 1], builder.substring(0, builder.length() - 1)));

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
        arrUlice.addAll(ulice.keySet());

        System.out.println("Pomocný zoznam ulíc vygenerovaný: " + arrUlice.size());
    }

    private static void transakciaGenerator() {
        int availableCars = POCET_VOZIDIEL;
        LocalDate currentDate = START_DATE;
        ArrayList<Integer> currentlyRentedCarsIndexes = new ArrayList<>();
        ArrayList<Month> summerMonths = new ArrayList<>(List.of(Month.JUNE, Month.JULY, Month.AUGUST));
        HashMap<LocalDate, List<Integer>> endDatesOfTransactions = new HashMap<>();
        int numberOfCarsRentedToday;
        int[] carRentDurationInterval;
        int randomVehicleIndex;
        int randomPersonIndex;

        while (!currentDate.isAfter(END_DATE)) {
            // During the summer the people rent more cards for longer time periods
            if (summerMonths.contains(currentDate.getMonth()) || currentDate.getMonth() == Month.DECEMBER
                    || currentDate.getMonth() == Month.APRIL) {
                numberOfCarsRentedToday = faker.random().nextInt(13, 18);
                carRentDurationInterval = new int[]{1, 5};
            }
            // During the weekend people will rent more cars, but for a shorter duration
            else if (currentDate.getDayOfWeek() == DayOfWeek.SATURDAY || currentDate.getDayOfWeek() == DayOfWeek.SUNDAY) {
                numberOfCarsRentedToday = faker.random().nextInt(12, 15);
                carRentDurationInterval = new int[]{1, 5};
            // During the weekdays people will rent fewer cards with an okay duration or the shortest duration
            } else {
                numberOfCarsRentedToday = faker.random().nextInt(23, 25);
                carRentDurationInterval = new int[]{1, 2};
            }

            List<Integer> todayTransactions = endDatesOfTransactions.get(currentDate);
            // Remove car indexes whose rental ends today from the rented cars ArrayList
            if (todayTransactions != null) {
                for (int index: todayTransactions) {
                    currentlyRentedCarsIndexes.remove(Integer.valueOf(index));
                    availableCars++;
                }
                endDatesOfTransactions.remove(currentDate);
            }

            // Generate transactions
            while (numberOfCarsRentedToday > 0 && availableCars > 0) {
                // select a random vehicle that is not being rented
                randomVehicleIndex = faker.random().nextInt(0, POCET_VOZIDIEL - 1);
                randomPersonIndex = faker.random().nextInt(0, POCET_OSOB - 1);
                if (currentlyRentedCarsIndexes.isEmpty()) {
                    currentlyRentedCarsIndexes.add(randomVehicleIndex);
                } else {
                    while (currentlyRentedCarsIndexes.contains(randomVehicleIndex)) {
                        randomVehicleIndex = faker.random().nextInt(0, POCET_VOZIDIEL - 1);
                    }
                    currentlyRentedCarsIndexes.add(randomVehicleIndex);
                }
                
                Vozidlo selectedVehicle = vozidla.get(randomVehicleIndex);
                Osoba selectedPerson = osoba.get(randomPersonIndex);
                int daysRented = faker.random()
                        .nextInt(carRentDurationInterval[0], carRentDurationInterval[1]);
                int totalRentalPrice = selectedVehicle.dayRentalPrice * daysRented;
                LocalDate rentalEndDate = currentDate.plusDays(daysRented);

                Transakcia transaction;
                if (rentalEndDate.isBefore(END_DATE)) {
                    transaction = new Transakcia(currentDate, rentalEndDate, totalRentalPrice,
                            selectedPerson.id_osoby, selectedVehicle.seriove_cislo_vozidla);
                } else {
                    transaction = new Transakcia(currentDate, totalRentalPrice,
                            selectedPerson.id_osoby, selectedVehicle.seriove_cislo_vozidla);
                }
                transakcie.add(transaction);

                if (endDatesOfTransactions.containsKey(rentalEndDate)) {
                    List<Integer> currValue = endDatesOfTransactions.get(rentalEndDate);
                    currValue.add(randomVehicleIndex);
                    endDatesOfTransactions.put(rentalEndDate, currValue);
                } else {
                    endDatesOfTransactions.put(rentalEndDate, new ArrayList<>(List.of(randomVehicleIndex)));
                }

                numberOfCarsRentedToday--;
                availableCars--;
            }
            currentDate = currentDate.plusDays(1);
        }
        System.out.println("Transakcie vygenerovane, pocet transakcii: " + transakcie.size());
    }

    private static void rodneCislaGenerator() {
        TreeMap<String, String> muzi = new TreeMap<>();
        TreeMap<String, String> zeny = new TreeMap<>();
        while (muzi.size() < POCET_OSOB) {
            String tmp = generateBirthNumber(false);
            if (!muzi.containsKey(tmp)){
                muzi.put(tmp, tmp);
            }
        }
        arrRodCisloMuzi.addAll(muzi.keySet());
        System.out.println("Rodne cisla muzi vygenerovane: " + arrRodCisloMuzi.size());

        while (zeny.size() < POCET_OSOB) {
            String tmp = generateBirthNumber(true);
            if (!zeny.containsKey(tmp)){
                zeny.put(tmp, tmp);
            }
        }
        arrRodCisloZeny.addAll(zeny.keySet());

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

        arrObcianskyPreukaz.addAll(obc.keySet());
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
            e.printStackTrace();
        }
    }

    private static void osobaGenerator() {
        int pocetMuzov = 0;
        int pocetZien = 0;
        for (int i = 1; i <= POCET_OSOB; i++) {
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
        ArrayList<Integer> carRentalDayPrices = new ArrayList<>(List.of(50, 80, 100, 150, 170, 200, 400, 500));
        for (int i = 0; i < POCET_VOZIDIEL; i++) {
            Vozidlo tmpVozidlo = new Vozidlo();

            Pair<Integer, String> carBrandPair = znacky_aut.get(random.nextInt(znacky_aut.size()));
            List<Integer> carBrandSeatsOptions = numberOfCarSeats.get(carBrandPair.value);

            Vozidlo.znacka_auta = carBrandPair.key;
            tmpVozidlo.typ_auta = typy_aut.get(random.nextInt(typy_aut.size())).key;
            tmpVozidlo.stav_vozidla = stav_auta.get(random.nextInt(stav_auta.size())).key;
            tmpVozidlo.ecv = faker.regexify("[A-Z]{2}[0-9]{3}[A-Z]{2}");
            tmpVozidlo.pocet_miest_na_sedenie = carBrandSeatsOptions.get(faker.random().nextInt(carBrandSeatsOptions.size()));
            tmpVozidlo.fotka = ""; //todo toto sa bude robit az pri vkladani dat do apexu, pridal som fotky do resources
            tmpVozidlo.rok_vyroby = 1989 + random.nextInt(32);
            char[] typ_motora = new char[]{'D', 'B', 'E'}; //dizel, benzín, elektrina
            tmpVozidlo.typ_motora = typ_motora[random.nextInt(typ_motora.length)];
            tmpVozidlo.seriove_cislo_vozidla = faker.regexify("[A-HJ-NPR-Z]") + faker.regexify("[0-9A-HJ-NPR-Z]{16}");
            tmpVozidlo.dayRentalPrice = carRentalDayPrices.get(faker.random().nextInt(0, carRentalDayPrices.size() - 1));
            vozidla.add(tmpVozidlo);
        }
        System.out.println("Vygenerované vozidla: " + vozidla.size());
    }

    private static String generateBirthNumber(boolean womanGeneration) {

        // Generate a random date of birth between 1970 and 2003
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, 1970);
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

        if (womanGeneration) {
            formattedMonthDay = String.format("%02d", Integer.parseInt(formattedMonthDay) + 50);
        }

        // Ensure day and year have leading zeros if less than 10
        formattedDay = String.format("%02d", Integer.parseInt(formattedDay));
        lastTwoDigitsOfYear = String.format("%02d", Integer.parseInt(lastTwoDigitsOfYear));

        // Calculate the current sum
        String birthNumberIdentifierShort = lastTwoDigitsOfYear + formattedMonthDay + formattedDay;
        int currentSum = getSum(birthNumberIdentifierShort);
        String uniqueIdentifier = String.format("%04d", faker.number().numberBetween(1000, 9999));

        if (womanGeneration) {
            while ((currentSum + getSum(uniqueIdentifier)) % 11 != 0 || arrRodCisloZeny.contains(lastTwoDigitsOfYear +
                    formattedMonthDay +
                    formattedDay +
                    "/" +
                    uniqueIdentifier)) {
                uniqueIdentifier = String.format("%04d", faker.number().numberBetween(1000, 9999));
            }

            arrRodCisloZeny.add(lastTwoDigitsOfYear +
                    formattedMonthDay +
                    formattedDay +
                    "/" +
                    uniqueIdentifier);
        } else {
            while ((currentSum + getSum(uniqueIdentifier)) % 11 != 0 || arrRodCisloMuzi.contains(lastTwoDigitsOfYear +
                    formattedMonthDay +
                    formattedDay +
                    "/" +
                    uniqueIdentifier)) {
                uniqueIdentifier = String.format("%04d", faker.number().numberBetween(1000, 9999));
            }

            arrRodCisloMuzi.add(lastTwoDigitsOfYear +
                    formattedMonthDay +
                    formattedDay +
                    "/" +
                    uniqueIdentifier);
        }

        return lastTwoDigitsOfYear +
                formattedMonthDay +
                formattedDay +
                "/" +
                uniqueIdentifier;
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

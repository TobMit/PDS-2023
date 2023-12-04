package org.example;

import com.opencsv.CSVParserBuilder;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import com.opencsv.exceptions.CsvException;
import net.datafaker.Faker;
import org.example.DataSaver.*;
import org.example.DataSaver.Mesto;


import javax.management.InvalidAttributeValueException;
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
 */
public class App {
    public static final int POCET_VOZIDIEL = 900;
    public static final int POCET_OSOB = 10000;
    public static final double PRAVDEBODOBNST_ZENY = 0.48;
    public static final LocalDate START_DATE = LocalDate.of(2008, 6, 14);
    public static final LocalDate END_DATE = LocalDate.now();
    public static final ArrayList<Pair<Integer, String>> typy_aut = new ArrayList<>();
    public static final ArrayList<String> arrRodCisloMuzi = new ArrayList<>();
    public static final ArrayList<String> arrRodCisloZeny = new ArrayList<>();
    public static final ArrayList<String> arrObcianskyPreukaz = new ArrayList<>();
    public static final ArrayList<String> arrNameWoman = new ArrayList<>();
    public static final ArrayList<String> arrNameMan = new ArrayList<>();
    public static final ArrayList<String> arrPriezviskoWoman = new ArrayList<>();
    public static final ArrayList<String> arrPriezviskoMan = new ArrayList<>();
    public static final ArrayList<Osoba> osoba = new ArrayList<>();
    public static final ArrayList<Vozidlo> vozidla = new ArrayList<>();
    public static final ArrayList<Transakcia> transakcie = new ArrayList<>();
    public static final ArrayList<Servis> servisy = new ArrayList<>();
    private static final HashMap<String, List<Integer>> numberOfCarSeats = new HashMap<>();
    public static final Faker faker = new Faker(new Locale("sk"));
    private static final Random random = new Random();
    private static final HashMap<String, List<Mesto>> okresyObceMap = new HashMap<>();
    private static final HashMap<String, String> okresyMap = new HashMap<>();

    public static void main(String[] args) {
        okresyAndObceGenerator();
        typyGenerator();
        numberOfSeatsGenerator();
        vozidlaGenerator();
        rodneCislaGenerator();
        obcianskyPreukazGenerator();
        menaPriezviskaGenerator();
        osobaGenerator();
        transakciaGenerator();

        saveData();
    }
    private static void saveData() {
        // Output files
        DataSaver typyAutSaver = new DataSaver("typy_aut.csv");
        DataSaver stavAutaSaver = new DataSaver("stav_aut.csv");
        DataSaver znackyAutSaver = new DataSaver("znacky_aut.csv");
        DataSaver mestoSaver = new DataSaver("mesta.csv");
        DataSaver okresSaver = new DataSaver("okresy.csv");
        DataSaver osobaSaver = new DataSaver("osoby.csv");
        DataSaver vozidloSaver = new DataSaver("vozidla.csv");
        DataSaver transakcieSaver = new DataSaver("transakcie.csv");
        DataSaver servisSaver = new DataSaver("servisy.csv");

        // typy aut
        typyAutSaver.appendData("typ_auta" + CSV_DELIMETER + "id_typu" + '\n');
        for (Pair<Integer, String> typAutaPair : typy_aut) {
            typyAutSaver.appendData(typAutaPair.value + CSV_DELIMETER + typAutaPair.key + '\n');
        }

        // stav aut
        stavAutaSaver.appendData("typ_stavu" + CSV_DELIMETER + "id_stavu" + '\n');
        stavAutaSaver.appendData("volné" + CSV_DELIMETER + (StavVozidla.VOLNE.getStavVozidla()) + '\n');
        stavAutaSaver.appendData("požičané" + CSV_DELIMETER + (StavVozidla.POZICANE.getStavVozidla()) + '\n');
        stavAutaSaver.appendData("servis" + CSV_DELIMETER + (StavVozidla.SERVIS.getStavVozidla()) + '\n');

        // znacka aut
        int i = 1;
        List<String> znackyAut = new ArrayList<>(numberOfCarSeats.keySet());
        znackyAutSaver.appendData("nazov_znacky" + CSV_DELIMETER + "id_znacky" + '\n');
        for (String znackaAuta : znackyAut) {
            znackyAutSaver.appendData(znackaAuta + CSV_DELIMETER + i + CSV_DELIMETER + '\n');
            i++;
        }

        i = 1;

        // mesto
        mestoSaver.appendData("id_okresu" + CSV_DELIMETER + "nazov" + CSV_DELIMETER + "psc" + '\n');
        for (List<Mesto> mesta : okresyObceMap.values()) {
            for (Mesto mesto : mesta) {
                mestoSaver.appendData(String.valueOf(i) + CSV_DELIMETER + mesto.toString());
            }
            i++;
        }

        // okres
        i = 1;
        okresSaver.appendData("nazov" + CSV_DELIMETER + "id_okresu" + '\n');
        for (String nazov : okresyMap.values()) {
            okresSaver.appendData(String.valueOf(i) + CSV_DELIMETER + nazov + '\n');
            i++;
        }

        // osoba
        osobaSaver.appendData("psc" + CSV_DELIMETER + "rod_cislo" + CSV_DELIMETER + "meno" +
                CSV_DELIMETER + "priezvisko" + CSV_DELIMETER + "cislo_obcianskeho" + CSV_DELIMETER + "ulica" + CSV_DELIMETER + "id_osoby" + '\n');
        for (Osoba osoba : osoba) {
            osobaSaver.appendData(osoba.toString());
        }

        // vozidlo
        vozidloSaver.appendData("znacka_auta" + CSV_DELIMETER + "typ_auta" + CSV_DELIMETER + "stav_auta" +
                CSV_DELIMETER + "ecv" + CSV_DELIMETER + "pocet_miest_na_sedenie" + CSV_DELIMETER + "fotka" + CSV_DELIMETER
                + "rok_vyroby" + CSV_DELIMETER + "pocet_najazdenych_km" + CSV_DELIMETER + "typ_motora" + CSV_DELIMETER + "seriove_cislo_vozidla" + '\n');
        for (Vozidlo vozidlo : vozidla) {
            vozidloSaver.appendData(vozidlo.toString());
        }

        // transakcie
        transakcieSaver.appendData("dat_od" + CSV_DELIMETER + "dat_do" + CSV_DELIMETER + "suma" +
                CSV_DELIMETER + "id_osoby" + CSV_DELIMETER + "id_vozidla" + CSV_DELIMETER + "pocet_najazdenych_km" + '\n');
        for (Transakcia transakcia : transakcie) {
            transakcieSaver.appendData(transakcia.toString());
        }

        // servisy
        servisSaver.appendData("dat_do" + CSV_DELIMETER + "suma" + CSV_DELIMETER + "id_vozidla" + CSV_DELIMETER + "dat_od" + '\n');
        for (Servis servis : servisy) {
            servisSaver.appendData(servis.toString());
        }

        typyAutSaver.saveDataToFile();
        stavAutaSaver.saveDataToFile();
        znackyAutSaver.saveDataToFile();
        mestoSaver.saveDataToFile();
        okresSaver.saveDataToFile();
        osobaSaver.saveDataToFile();
        vozidloSaver.saveDataToFile();
        transakcieSaver.saveDataToFile();
        servisSaver.saveDataToFile();

    }

    private static void okresyAndObceGenerator() {
        try (CSVReader reader = new CSVReaderBuilder(new FileReader("src/main/java/org/example/DataSaver/Resources/okresy.csv"))
                .withCSVParser(new CSVParserBuilder().withSeparator(';').build())
                .build()) {
            reader.skip(1);
            List<String[]> rows = reader.readAll();
            for (String[] row : rows) {
                okresyObceMap.put(row[1], new ArrayList<>());
                okresyMap.put(row[1], row[2]);
            }
        } catch (IOException | CsvException e) {
            e.printStackTrace();
        }

        try (CSVReader reader = new CSVReaderBuilder(new FileReader("src/main/java/org/example/DataSaver/Resources/obce.csv"))
                .withCSVParser(new CSVParserBuilder().withSeparator(';').build())
                .build()) {
            reader.skip(1);
            List<String[]> rows = reader.readAll();
            for (String[] row : rows) {
                List<Mesto> value = okresyObceMap.get(row[1].substring(0, 6));
                value.add(new Mesto(row[2], row[5]));
            }
        } catch (IOException | CsvException e) {
            e.printStackTrace();
        }
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

    private static void typyGenerator() {
        ArrayList<String> typy = new ArrayList<>(List.of(new String[]{"Combi", "Suv", "Sedan"}));

        int i = 1;
        for (String s : typy) {
            typy_aut.add(new Pair<>(i, s));
            i++;
        }
        System.out.println("Typy aut vygenerovane: " + typy_aut.size());
    }

    private static void transakciaGenerator() {
        LocalDate currentDate = START_DATE;
        // build a map of available vehicles based on the manufacture date
        HashMap<Integer, List<Vozidlo>> currentlyAvailableCars = new HashMap<>();
        while (currentDate.getYear() <= 2023) {
            ArrayList<Vozidlo> currentYearCars = new ArrayList<>();
            for (Vozidlo vozidlo : vozidla) {
                if (vozidlo.rokVyroby <= currentDate.getYear()) {
                    currentYearCars.add(vozidlo);
                }
            }
            currentlyAvailableCars.put(currentDate.getYear(), currentYearCars);
            currentDate = currentDate.plusYears(1);
        }

        currentDate = START_DATE;
        int availableCars = currentlyAvailableCars.get(currentDate.getYear()).size();
        int[] carServiceInterval = new int[]{2, 7};
        ArrayList<Vozidlo> currentlyRentedCars = new ArrayList<>();
        ArrayList<Vozidlo> currentlyMaintainedCarsIndexes = new ArrayList<>();
        ArrayList<Month> summerMonths = new ArrayList<>(List.of(Month.JUNE, Month.JULY, Month.AUGUST));
        HashMap<LocalDate, List<Vozidlo>> endDatesOfTransactions = new HashMap<>();
        HashMap<LocalDate, List<Vozidlo>> endDateOfMaintenances = new HashMap<>();
        int numberOfCarsToRentToday;
        int[] carRentDurationInterval;
        Vozidlo randomVehicle;
        int randomPersonIndex;
        TransakciaType transakciaType;

        while (!currentDate.isAfter(END_DATE)) {
            // At the start of a new year add the new vehicles
            if (currentDate.getDayOfYear() == 1 && currentDate.getYear() != START_DATE.getYear()) {
                availableCars = currentlyAvailableCars.get(currentDate.getYear()).size() - currentlyMaintainedCarsIndexes.size() - currentlyRentedCars.size();
            }

            // During the summer the people rent more cards for longer time periods
            if (summerMonths.contains(currentDate.getMonth()) || currentDate.getMonth() == Month.DECEMBER
                    || currentDate.getMonth() == Month.APRIL) {
                numberOfCarsToRentToday = faker.random().nextInt(50, 80);
                carRentDurationInterval = new int[]{7, 14};
                transakciaType = TransakciaType.SUMMER;
            }
            // During the weekend people will rent more cars, but for a shorter duration
            else if (currentDate.getDayOfWeek() == DayOfWeek.SATURDAY || currentDate.getDayOfWeek() == DayOfWeek.SUNDAY) {
                numberOfCarsToRentToday = faker.random().nextInt(25, 60);
                carRentDurationInterval = new int[]{1, 5};
                transakciaType = TransakciaType.WEEKEND;
                // During the weekdays people will rent fewer cards with an okay duration or the shortest duration
            } else {
                numberOfCarsToRentToday = faker.random().nextInt(30, 40);
                carRentDurationInterval = new int[]{1, 2};
                transakciaType = TransakciaType.WEEKDAY;
            }

            // add today's km count to the rented vehicles total km count
            for (Vozidlo rentedVehicle : currentlyRentedCars) {
                try {
                    rentedVehicle.addDailyKm(transakciaType);
                } catch (InvalidAttributeValueException e) {
                    throw new RuntimeException(e);
                }
            }

            // Remove car indexes whose rental ends today from the rented cars ArrayList
            List<Vozidlo> todayTransactions = endDatesOfTransactions.get(currentDate);
            if (todayTransactions != null) {
                for (Vozidlo returnedVozidlo : todayTransactions) {
                    currentlyRentedCars.remove(returnedVozidlo);
                    // check if the car needs maintenance
                    if (returnedVozidlo.requiresService()) {
                        returnedVozidlo.stavVozidla = StavVozidla.SERVIS.getStavVozidla();
                        int numberOfDaysInMaintenance = faker.random().nextInt(carServiceInterval[0], carServiceInterval[1]);
                        LocalDate maintenanceEndDate = currentDate.plusDays(numberOfDaysInMaintenance);
                        int price = faker.random().nextInt((int) (returnedVozidlo.dayRentalPrice * 0.2), returnedVozidlo.dayRentalPrice * 6);
                        servisy.add(new Servis(returnedVozidlo.serioveCisloVozidla, currentDate, maintenanceEndDate, price));

                        currentlyMaintainedCarsIndexes.add(returnedVozidlo);
                        if (endDateOfMaintenances.containsKey(maintenanceEndDate)) {
                            List<Vozidlo> currValue = endDateOfMaintenances.get(maintenanceEndDate);
                            currValue.add(returnedVozidlo);
                            endDateOfMaintenances.put(maintenanceEndDate, currValue);
                        } else {
                            endDateOfMaintenances.put(maintenanceEndDate, new ArrayList<>(List.of(returnedVozidlo)));
                        }
                    } else {
                        availableCars++;
                        returnedVozidlo.stavVozidla = StavVozidla.VOLNE.getStavVozidla();
                    }
                }
                endDatesOfTransactions.remove(currentDate);
            }

            // Remove car indexes whose maintenance ends today from the maintained cars HashMap
            List<Vozidlo> todayMaintenanceEnds = endDateOfMaintenances.get(currentDate);
            if (todayMaintenanceEnds != null) {
                for (Vozidlo maintainedVozidlo : todayMaintenanceEnds) {
                    currentlyMaintainedCarsIndexes.remove(maintainedVozidlo);
                    maintainedVozidlo.stavVozidla = StavVozidla.VOLNE.getStavVozidla();
                    availableCars++;
                }
            }

            // Generate transactions
            while (numberOfCarsToRentToday > 0 && availableCars > 0) {
                // select a random vehicle that is not being rented
                List<Vozidlo> currentCarIndexes = currentlyAvailableCars.get(currentDate.getYear());
                randomVehicle = currentCarIndexes.get(faker.random().nextInt(currentCarIndexes.size()));
                randomPersonIndex = faker.random().nextInt(POCET_OSOB);
                if (currentlyRentedCars.isEmpty()) {
                    currentlyRentedCars.add(randomVehicle);
                } else {
                    while (randomVehicle.stavVozidla != StavVozidla.VOLNE.getStavVozidla()) {
                        randomVehicle = currentCarIndexes.get(faker.random().nextInt(currentCarIndexes.size()));
                    }
                    currentlyRentedCars.add(randomVehicle);
                }

                randomVehicle.stavVozidla = StavVozidla.POZICANE.getStavVozidla();
                Osoba selectedPerson = osoba.get(randomPersonIndex);
                int daysRented = faker.random()
                        .nextInt(carRentDurationInterval[0], carRentDurationInterval[1]);
                int totalRentalPrice = randomVehicle.dayRentalPrice * daysRented;
                LocalDate rentalEndDate = currentDate.plusDays(daysRented);

                Transakcia transaction;
                if (rentalEndDate.isBefore(END_DATE)) {
                    LocalDate currTempDate = currentDate;
                    while (!currTempDate.isAfter(rentalEndDate)) {
                        try {
                            randomVehicle.addDailyKm(transakciaType);
                        } catch (InvalidAttributeValueException e) {
                            throw new RuntimeException(e);
                        }
                        currTempDate = currTempDate.plusDays(1);
                    }
                    transaction = new Transakcia(currentDate, rentalEndDate, totalRentalPrice,
                            selectedPerson.id_osoby, randomVehicle.serioveCisloVozidla, randomVehicle.poslednePozicaniePocetkm);
                    randomVehicle.pocetNajazdenychKm += randomVehicle.poslednePozicaniePocetkm;
                    randomVehicle.poslednePozicaniePocetkm = 0;
                } else {
                    transaction = new Transakcia(currentDate, totalRentalPrice,
                            selectedPerson.id_osoby, randomVehicle.serioveCisloVozidla);
                }
                transakcie.add(transaction);

                if (endDatesOfTransactions.containsKey(rentalEndDate)) {
                    List<Vozidlo> currValue = endDatesOfTransactions.get(rentalEndDate);
                    currValue.add(randomVehicle);
                    endDatesOfTransactions.put(rentalEndDate, currValue);
                } else {
                    endDatesOfTransactions.put(rentalEndDate, new ArrayList<>(List.of(randomVehicle)));
                }

                numberOfCarsToRentToday--;
                availableCars--;
            }
            currentDate = currentDate.plusDays(1);
        }
        System.out.println("Transakcie vygenerovane, pocet transakcii: " + transakcie.size());
        System.out.println("Number of services: " + servisy.size());
    }

    private static void rodneCislaGenerator() {
        TreeMap<String, String> muzi = new TreeMap<>();
        TreeMap<String, String> zeny = new TreeMap<>();
        while (muzi.size() < POCET_OSOB) {
            String tmp = generateBirthNumber(false);
            if (!muzi.containsKey(tmp)) {
                muzi.put(tmp, tmp);
            }
        }
        arrRodCisloMuzi.addAll(muzi.keySet());
        System.out.println("Rodne cisla muzi vygenerovane: " + arrRodCisloMuzi.size());

        while (zeny.size() < POCET_OSOB) {
            String tmp = generateBirthNumber(true);
            if (!zeny.containsKey(tmp)) {
                zeny.put(tmp, tmp);
            }
        }
        arrRodCisloZeny.addAll(zeny.keySet());

        System.out.println("Rodne cisla zeny vygenerovane: " + arrRodCisloZeny.size());
    }

    private static void obcianskyPreukazGenerator() {
        TreeMap<String, String> obc = new TreeMap<>();
        while (obc.size() < 2 * POCET_OSOB) {
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
        List<String> okresyKeys = List.copyOf(okresyMap.keySet());
        for (int i = 1; i <= POCET_OSOB; i++) {
            Osoba tmpOsoba = new Osoba();

            tmpOsoba.cislo_obcianskeho = getCisloObcianskeho();
            tmpOsoba.ulica = faker.address().streetAddress();
            tmpOsoba.id_osoby = i;
            List<Mesto> randomOkresList = okresyObceMap.get(okresyKeys.get(faker.random().nextInt(okresyKeys.size())));
            tmpOsoba.psc = randomOkresList.get(faker.random().nextInt(randomOkresList.size())).psc;

            if (random.nextDouble() > PRAVDEBODOBNST_ZENY) {
                // generujeme muzov
                tmpOsoba.rod_cislo = getRodCislo(false);
                tmpOsoba.Meno = arrNameMan.get(random.nextInt(arrNameMan.size()));
                tmpOsoba.Priezvisko = arrPriezviskoMan.get(random.nextInt(arrPriezviskoMan.size()));
                pocetMuzov++;
            } else {
                // generujeme zeny
                tmpOsoba.rod_cislo = getRodCislo(true);
                tmpOsoba.Meno = arrNameWoman.get(random.nextInt(arrNameWoman.size()));
                tmpOsoba.Priezvisko = arrPriezviskoWoman.get(random.nextInt(arrPriezviskoWoman.size()));
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
        List<String> carBrands = List.copyOf(numberOfCarSeats.keySet());
        for (int i = 0; i < POCET_VOZIDIEL; i++) {
            Vozidlo tmpVozidlo = new Vozidlo();

            int randomIndex = faker.random().nextInt(carBrands.size());
            List<Integer> carBrandSeatsOptions = numberOfCarSeats.get(carBrands.get(randomIndex));

            tmpVozidlo.id = i + 1;
            tmpVozidlo.znackaAuta = randomIndex + 1;
            tmpVozidlo.typAuta = typy_aut.get(random.nextInt(typy_aut.size())).key;
            tmpVozidlo.stavVozidla = StavVozidla.VOLNE.getStavVozidla();
            tmpVozidlo.ecv = faker.regexify("[A-Z]{2}[0-9]{3}[A-Z]{2}");
            tmpVozidlo.pocetMiestNaSedenie = carBrandSeatsOptions.get(faker.random().nextInt(carBrandSeatsOptions.size()));
            tmpVozidlo.fotka = ""; //toto sa bude robit az pri vkladani dat do apexu, pridal som fotky do resources
            tmpVozidlo.rokVyroby = 2002 + random.nextInt(21);
            char[] typ_motora = new char[]{'D', 'B', 'E'}; //dizel, benzín, elektrina
            tmpVozidlo.typMotora = typ_motora[random.nextInt(typ_motora.length)];
            tmpVozidlo.serioveCisloVozidla = faker.regexify("[A-HJ-NPR-Z]") + faker.regexify("[0-9A-HJ-NPR-Z]{16}");
            tmpVozidlo.dayRentalPrice = carRentalDayPrices.get(faker.random().nextInt(0, carRentalDayPrices.size() - 1));
            tmpVozidlo.pocetNajazdenychKm = faker.random().nextInt(0, 368_945);
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

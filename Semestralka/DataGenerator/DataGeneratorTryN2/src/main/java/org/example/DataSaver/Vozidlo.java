package org.example.DataSaver;

import org.example.App;

import javax.management.InvalidAttributeValueException;

import static org.example.DataSaver.DataSaver.CSV_DELIMETER;

public class Vozidlo {
    public static final int DAILY_KM_BASE = 40;
    public static final double REQUIRES_SERVICE_CHANCE_THRESHOLD = 0.58;
    public int id;
    public int znackaAuta;
    public int typAuta;
    public int stavVozidla;
    public String ecv;
    public int pocetMiestNaSedenie;
    public String fotka;
    public int rokVyroby;
    public int pocetNajazdenychKm;
    public char typMotora;
    public String serioveCisloVozidla;
    public int poslednePozicaniePocetkm;

    public int dayRentalPrice;

    public void addDailyKm(TransakciaType transakciaType) throws InvalidAttributeValueException {
        double multiplier = (rokVyrobyMultiplier() + transakciaType.getKmMultiplier() + pocetNajazdenychKmMultiplier());
        if (multiplier < 0) {
            throw new InvalidAttributeValueException("Multiplier cant be negative");
        }
        double dailyKm = (int) (DAILY_KM_BASE * multiplier);
        this.poslednePozicaniePocetkm += dailyKm;
    }

    private double rokVyrobyMultiplier() {
        if (isBetween(rokVyroby, 2002, 2005)) {
            return 0.6;
        } else if (isBetween(rokVyroby, 2006, 2010)) {
            return 0.75;
        } else if (isBetween(rokVyroby, 2011, 2015)) {
            return 0.95;
        } else {
            return 1;
        }
    }

    public double pocetNajazdenychKmMultiplier() {
        double randomProduct;
        if (isBetween(pocetNajazdenychKm, 0, 20_000)) {
            randomProduct = pocetNajazdenychKm * App.faker.random().nextDouble(0.000_010, 0.000_02);
        } else if (isBetween(pocetNajazdenychKm, 20_001, 60_000)) {
            randomProduct = pocetNajazdenychKm * App.faker.random().nextDouble(0.000_002, 0.000_010);
        } else if (isBetween(pocetNajazdenychKm, 60_001, 116_000)) {
            randomProduct = pocetNajazdenychKm * App.faker.random().nextDouble(0.000_001_8, 0.000_008);
        } else if (isBetween(pocetNajazdenychKm, 116_001, 220_000)) {
            randomProduct = pocetNajazdenychKm * App.faker.random().nextDouble(0.000_003_0, 0.000_006_0);
        } else if (isBetween(pocetNajazdenychKm, 220_001, 478_000)) {
            randomProduct = pocetNajazdenychKm * App.faker.random().nextDouble(0.000_002_6, 0.000_004_0);
        } else {
            randomProduct = pocetNajazdenychKm * App.faker.random().nextDouble(0.000_000_6, 0.000_002_0);
        }

        return 1.5 - randomProduct;
    }

    public boolean requiresService() {
        double calculatedChance = 0;

        if (isBetween(rokVyroby, 2002, 2005)) {
            calculatedChance += App.faker.random().nextDouble(0.29, 0.4);
        } else if (isBetween(rokVyroby, 2006, 2010)) {
            calculatedChance += App.faker.random().nextDouble(0.18, 0.3);
        } else if (isBetween(rokVyroby, 2011, 2015)) {
           calculatedChance += App.faker.random().nextDouble(0.08, 0.2);
        } else {
            calculatedChance +=  App.faker.random().nextDouble(0.22, 0.35);
        }

        if (isBetween(pocetNajazdenychKm, 0, 20_000)) {
            calculatedChance += App.faker.random().nextDouble(0.001, 0.02);
        } else if (isBetween(pocetNajazdenychKm, 20_001, 60_000)) {
            calculatedChance +=  App.faker.random().nextDouble(0.03, 0.06);
        } else if (isBetween(pocetNajazdenychKm, 60_001, 116_000)) {
            calculatedChance +=  App.faker.random().nextDouble(0.08, 0.14);
        } else if (isBetween(pocetNajazdenychKm, 116_001, 220_000)) {
            calculatedChance +=  App.faker.random().nextDouble(0.115, 0.20);
        } else if (isBetween(pocetNajazdenychKm, 220_001, 478_000)) {
            calculatedChance +=  App.faker.random().nextDouble(0.17, 0.28);
        } else {
            calculatedChance +=  App.faker.random().nextDouble(0.30, 0.37);
        }

        return calculatedChance > REQUIRES_SERVICE_CHANCE_THRESHOLD;
    }

    public boolean isBetween(int x, int lower, int upper) {
        return lower <= x && x <= upper;
    }


    @Override
    public String toString() {
        return String.valueOf(znackaAuta) + CSV_DELIMETER + typAuta + CSV_DELIMETER + stavVozidla + CSV_DELIMETER + ecv + CSV_DELIMETER
                + pocetMiestNaSedenie + CSV_DELIMETER + fotka + CSV_DELIMETER + rokVyroby + CSV_DELIMETER
                + pocetNajazdenychKm + CSV_DELIMETER + typMotora + CSV_DELIMETER + serioveCisloVozidla + '\n';
    }
}

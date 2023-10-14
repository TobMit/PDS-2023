package org.example.DataSaver;

import static org.example.DataSaver.DataSaver.CSV_DELIMETER;

public class Vozidlo {
    public static int znacka_auta;
    public int typ_auta;
    public int stav_vozidla;
    public String ecv;
    public int pocet_miest_na_sedenie;
    public String fotka;
    public int rok_vyroby;
    public int pocet_najazdenych_km;
    public char typ_motora;
    public String seriove_cislo_vozidla;

    public int dayRentalPrice;


    @Override
    public String toString() {
        return String.valueOf(znacka_auta) + CSV_DELIMETER + typ_auta + CSV_DELIMETER + stav_vozidla + CSV_DELIMETER + ecv + CSV_DELIMETER
                + pocet_miest_na_sedenie + CSV_DELIMETER + fotka + CSV_DELIMETER + rok_vyroby + CSV_DELIMETER
                + pocet_najazdenych_km + CSV_DELIMETER + typ_motora + CSV_DELIMETER + seriove_cislo_vozidla + '\n';
    }
}

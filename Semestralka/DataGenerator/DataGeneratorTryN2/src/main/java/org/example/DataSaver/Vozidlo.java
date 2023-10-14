package org.example.DataSaver;

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
        return "Vozidlo{" +
                "typ_auta=" + typ_auta +
                ", stav_vozidla=" + stav_vozidla +
                ", ecv='" + ecv + '\'' +
                ", pocet_miest_na_sedenie=" + pocet_miest_na_sedenie +
                ", fotka='" + fotka + '\'' +
                ", rok_vyroby=" + rok_vyroby +
                ", pocet_najazdenych_km=" + pocet_najazdenych_km +
                ", typ_motora=" + typ_motora +
                ", seriove_cislo_vozidla='" + seriove_cislo_vozidla + '\'' +
                ", dayRentalPrice=" + dayRentalPrice +
                '}';
    }
}

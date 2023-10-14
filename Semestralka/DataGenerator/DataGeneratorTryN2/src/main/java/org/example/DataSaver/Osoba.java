package org.example.DataSaver;

import static org.example.DataSaver.DataSaver.CSV_DELIMETER;

public class Osoba {
    public String psc;
    public String rod_cislo;
    public String Meno;
    public String Priezvisko;
    public String cislo_obcianskeho;
    public String ulica;
    public int id_osoby;

    public String toString() {
        return psc + CSV_DELIMETER + rod_cislo + CSV_DELIMETER + Meno + CSV_DELIMETER + Priezvisko + CSV_DELIMETER
                + cislo_obcianskeho + CSV_DELIMETER + ulica + CSV_DELIMETER + id_osoby + '\n';
    }
}

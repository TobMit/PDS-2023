package org.example.DataSaver;

public class Osoba {
    public static String psc;
    public static String rod_cislo;
    public static String Meno;
    public static String Priezvisko;
    public static String cislo_obcianskeho;
    public static String ulica;
    public static int id_osoby;

    public String toString() {
        return psc + " " + rod_cislo + " " + Meno + " " + Priezvisko + " " + cislo_obcianskeho + " " + ulica + " " + id_osoby;
    }
}
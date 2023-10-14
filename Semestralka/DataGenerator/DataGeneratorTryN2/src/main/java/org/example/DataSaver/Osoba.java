package org.example.DataSaver;

public class Osoba {
    public String psc;
    public String rod_cislo;
    public String Meno;
    public String Priezvisko;
    public String cislo_obcianskeho;
    public String ulica;
    public int id_osoby;

    public String toString() {
        return psc + " " + rod_cislo + " " + Meno + " " + Priezvisko + " " + cislo_obcianskeho + " " + ulica + " " + id_osoby;
    }
}

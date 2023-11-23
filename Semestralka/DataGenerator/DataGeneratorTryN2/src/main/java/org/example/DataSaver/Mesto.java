package org.example.DataSaver;

import static org.example.DataSaver.DataSaver.CSV_DELIMETER;

public class Mesto {
    public String nazov;
    public String psc;

    public Mesto(String nazov, String psc) {
        this.nazov = nazov;
        this.psc = psc;
    }

    @Override
    public String toString() {
        return nazov + CSV_DELIMETER + psc + '\n';
    }
}

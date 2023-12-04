package org.example.DataSaver;

public enum StavVozidla {
    VOLNE(0),
    POZICANE(1),
    SERVIS(2);

    private final int stavVozidla;

    StavVozidla(int stavVozidla) {
        this.stavVozidla = stavVozidla;
    }

    public int getStavVozidla() {
        return stavVozidla;
    }

}

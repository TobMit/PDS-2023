package org.example.DataSaver;

import java.time.LocalDate;

public class Transakcia {
    private final LocalDate from;
    private LocalDate to;
    private final int price;
    private final int personId;
    private final String vehicleId;

    public Transakcia(LocalDate from, LocalDate to, int price, int personId, String vehicleId) {
        this.from = from;
        this.to = to;
        this.price = price;
        this.personId = personId;
        this.vehicleId = vehicleId;
    }

    public Transakcia(LocalDate from, int price, int personId, String vehicleId) {
        this.from = from;
        this.price = price;
        this.personId = personId;
        this.vehicleId = vehicleId;
    }
}

package org.example.DataSaver;

import java.time.LocalDate;

import static org.example.DataSaver.DataSaver.CSV_DELIMETER;

public class Servis {
    private final String vehicleId;
    private final LocalDate datOd;
    private final LocalDate datDo;
    private final int price;

    public Servis(String vehicleId, LocalDate datOd, LocalDate datDo, int price) {
        this.vehicleId = vehicleId;
        this.datOd = datOd;
        this.datDo = datDo;
        this.price = price;
    }

    @Override
    public String toString() {
        return datDo.toString() + CSV_DELIMETER + price + CSV_DELIMETER + vehicleId + CSV_DELIMETER + datOd.toString() + '\n';
    }
}

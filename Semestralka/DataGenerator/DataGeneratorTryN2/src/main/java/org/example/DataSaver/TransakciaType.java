package org.example.DataSaver;

import org.example.App;

public enum TransakciaType {
    SUMMER(App.faker.random().nextDouble(0.5, 4)),
    WEEKEND(App.faker.random().nextDouble(0.3, 3)),
    WEEKDAY(App.faker.random().nextDouble(0.1, 0.2));

    private final double kmMultiplier;

    TransakciaType(double kmMultiplier) {
        this.kmMultiplier = kmMultiplier;
    }

    public double getKmMultiplier() {
        return kmMultiplier;
    }
}

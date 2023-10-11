package org.example.DataSaver;

import java.io.BufferedWriter;
import java.io.FileWriter;

public class DataSaver {
    private StringBuilder data;

    public DataSaver(String fileName) {
        this.data = new StringBuilder();
    }

    public void saveData(String data) {
        this.data.append(data);
    }

    public void saveDataToFile(String fileName) {
        try {
            // save data to file
            BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
            writer.write(this.data.toString());
            writer.close();
        }catch(Exception e) {
            System.err.println(e);
        }
    }
}

package org.example.DataSaver;

import java.io.BufferedWriter;
import java.io.FileWriter;

public class DataSaver {
    private final StringBuilder data;
    private final String fileName;

    public static final char CSV_DELIMETER = ',';

    public DataSaver(String fileName) {
        this.data = new StringBuilder();
        this.fileName = fileName;
    }

    public void appendData(String data) {
        this.data.append(data);
    }

    public void saveDataToFile() {
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

package org.example;
import java.util.ArrayList;
public class Pair<T, K> {
    public T key;
    public K value;

    public Pair(T key, K value) {
        this.key = key;
        this.value = value;
    }

    public Pair() {}
}


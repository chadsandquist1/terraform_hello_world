package org.example;

import java.util.HashMap;
import java.util.Map;

public class IntegerToRoman {


    private static Map<Integer, String> romanMap = new HashMap<>(Map.ofEntries(
            Map.entry(1000, "M"),
            Map.entry(900, "CM"),
            Map.entry(500, "D"),
            Map.entry(400, "CD"),
            Map.entry(100, "C"),
            Map.entry(90, "XC"),
            Map.entry(50, "L"),
            Map.entry(40, "XL"),
            Map.entry(10, "X"),
            Map.entry(9, "IX"),
            Map.entry(5, "V"),
            Map.entry(4, "IV"),
            Map.entry(1, "I")
    ));

    public static String intToRoman(int num) {
        StringBuilder romanNumeral = new StringBuilder();

        // Iterate through the HashMap's entries in descending order of keys
        for (Map.Entry<Integer, String> entry : romanMap.entrySet()) {
            while (num >= entry.getKey()) {
                romanNumeral.append(entry.getValue());
                num -= entry.getKey();
            }
        }

        return romanNumeral.toString();
    }
}

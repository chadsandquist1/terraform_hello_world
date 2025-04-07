package org.example;

import java.util.Map;

public class RomanToInteger {

    static Map<Character, Integer> romanMap = Map.of(
            'I', 1, 'V', 5, 'X', 10, 'L', 50,
            'C', 100, 'D', 500, 'M', 1000);

    public static int romanToInt(String s) {
        int result = 0;
        int prev = 0;

        for (char c : s.toCharArray()) {
            int current = romanMap.get(c);

            //for example : IV (1+5)
            if (current > prev) {
                // Add the current value and subtract the previous value (since it was added earlier)
                result += current - (2 * prev);
            } else {
                // for example: VI Simply add the current value
                result += current;
            }
            // Update the previous value
            prev = current;
        }
        return result;
    }
}

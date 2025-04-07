package org.example;

import java.lang.Character;
import java.util.*;

public class LongestSubstring {
    public int lengthOfLongestSubstring(String s) {
        int maxLength = 0;
        int start = 0;
        Set<Character> uniqueChars = new HashSet<>();

        for (int end = 0; end < s.length(); end++) {
            while (uniqueChars.contains(s.charAt(end))) {
                uniqueChars.remove(s.charAt(start++));
            }
            uniqueChars.add(s.charAt(end));
            maxLength = Math.max(maxLength, end - start + 1);
        }
        return maxLength;}
}


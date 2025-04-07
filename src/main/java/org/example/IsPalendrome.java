package org.example;

public class IsPalendrome {


    public static boolean isPalindrome(String x) {

        String s = x.replaceAll("[^a-zA-Z0-9]+", " ").toLowerCase().replace(" ", "");
        System.out.println(s);
        char[] charArray = s.toCharArray();

        for(int i = 0; i < charArray.length/2; i++) {
            if(charArray[i] != charArray[charArray.length-1-i]) {
                return false;
            }
        }
        return true;
    }
}

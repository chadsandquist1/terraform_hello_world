package org.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class IsPalindromeTest {
    @Test
    public void testIsPalindrome() {
        assertTrue(IsPalendrome.isPalindrome("ABA"));
        assertFalse(IsPalendrome.isPalindrome("BBA"));
        assertTrue(IsPalendrome.isPalindrome("ABBA"));
        assertTrue(IsPalendrome.isPalindrome("ABABA"));
        assertTrue(IsPalendrome.isPalindrome("A man, a plan, a canal: Panama"));
        assertFalse(IsPalendrome.isPalindrome("0P"));
    }

}
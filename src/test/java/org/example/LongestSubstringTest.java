package org.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class LongestSubstringTest {

    @Test
    public void test() {
        LongestSubstring longestSubstring = new LongestSubstring();
        int i = longestSubstring.lengthOfLongestSubstring("abcdacbb");
        assertEquals(4, i);

        i = longestSubstring.lengthOfLongestSubstring("bbbbabcdeff");
        assertEquals(6, i);
    }

}
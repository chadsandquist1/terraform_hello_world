package org.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class RomanToIntegerTest {

    @Test
    public void testRoman()
    {
        assertEquals(3, RomanToInteger.romanToInt("III"));
        assertEquals(4, RomanToInteger.romanToInt("IV"));
        assertEquals(6, RomanToInteger.romanToInt("VI"));
    }
}
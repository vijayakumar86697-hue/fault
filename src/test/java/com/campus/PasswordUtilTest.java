package com.campus;

import com.campus.util.PasswordUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    public void testHashAndCheckPassword() {
        String rawPassword = "securePassword123";
        String hashed = PasswordUtil.hashPassword(rawPassword);

        assertNotNull(hashed);
        assertTrue(hashed.startsWith("$2a$") || hashed.startsWith("$2b$"));

        // Valid password check
        assertTrue(PasswordUtil.checkPassword(rawPassword, hashed));

        // Invalid password check
        assertFalse(PasswordUtil.checkPassword("wrongPassword", hashed));
    }

    @Test
    public void testEmptyPasswordThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(""));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
    }
}

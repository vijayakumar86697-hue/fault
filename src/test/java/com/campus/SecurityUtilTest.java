package com.campus;

import com.campus.util.SecurityUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class SecurityUtilTest {

    @Test
    public void testEscapeHtml() {
        String dangerous = "<script>alert('xss');</script>&\"'";
        String escaped = SecurityUtil.escapeHtml(dangerous);

        assertFalse(escaped.contains("<script>"));
        assertTrue(escaped.contains("&lt;script&gt;"));
        assertTrue(escaped.contains("&amp;"));
    }

    @Test
    public void testEmailValidation() {
        assertTrue(SecurityUtil.isValidEmail("john.doe@campus.edu"));
        assertTrue(SecurityUtil.isValidEmail("student_123@college.ac.in"));
        assertFalse(SecurityUtil.isValidEmail("invalid-email"));
        assertFalse(SecurityUtil.isValidEmail("@domain.com"));
    }

    @Test
    public void testSanitizeFilename() {
        String pathTraversal = "../../etc/passwd";
        String clean = SecurityUtil.sanitizeFilename(pathTraversal);
        assertFalse(clean.contains("/"));
        assertFalse(clean.contains("\\"));
        assertEquals("passwd", clean);
    }
}

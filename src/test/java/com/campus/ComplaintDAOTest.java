package com.campus;

import com.campus.config.DBConnection;
import com.campus.dao.ComplaintDAO;
import com.campus.model.Complaint;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

public class ComplaintDAOTest {

    @Test
    public void testDatabaseConnection() {
        boolean connected = DBConnection.testConnection();
        assertTrue(connected, "Database connection to campus_fault_db should be successful");
    }

    @Test
    public void testDashboardStats() {
        ComplaintDAO dao = new ComplaintDAO();
        Map<String, Object> stats = dao.getDashboardStats();

        assertNotNull(stats);
        assertTrue(stats.containsKey("total"));
        int total = (Integer) stats.get("total");
        assertTrue(total >= 0, "Total complaints should be non-negative");
    }

    @Test
    public void testTicketGeneration() {
        ComplaintDAO dao = new ComplaintDAO();
        String ticket = dao.generateTicketNumber();

        assertNotNull(ticket);
        assertTrue(ticket.startsWith("CMP-"));
    }

    @Test
    public void testFindById() {
        ComplaintDAO dao = new ComplaintDAO();
        Complaint c = dao.findById(1);

        if (c != null) {
            assertNotNull(c.getTicketNumber());
            assertNotNull(c.getTitle());
            assertNotNull(c.getStatus());
        }
    }
}

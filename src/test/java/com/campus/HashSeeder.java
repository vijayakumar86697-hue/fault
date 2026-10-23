import com.campus.util.PasswordUtil;
import com.campus.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class HashSeeder {
    public static void main(String[] args) throws Exception {
        String adminHash = PasswordUtil.hashPassword("admin123");
        String studentHash = PasswordUtil.hashPassword("student123");
        String facultyHash = PasswordUtil.hashPassword("faculty123");
        String workerHash = PasswordUtil.hashPassword("worker123");

        System.out.println("Admin hash: " + adminHash);
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password_hash = ? WHERE role = 'ADMIN'")) {
                ps.setString(1, adminHash);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password_hash = ? WHERE role = 'STUDENT'")) {
                ps.setString(1, studentHash);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password_hash = ? WHERE role = 'FACULTY'")) {
                ps.setString(1, facultyHash);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET password_hash = ? WHERE role = 'WORKER'")) {
                ps.setString(1, workerHash);
                ps.executeUpdate();
            }
        }
        System.out.println("DATABASE PASSWORDS UPDATED WITH VALID BCRYPT HASHES!");
    }
}

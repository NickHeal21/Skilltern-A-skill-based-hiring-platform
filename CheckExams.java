import java.sql.*;
import java.util.*;

public class CheckExams {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/training_institute?useSSL=false&serverTimezone=Asia/Kolkata&allowPublicKeyRetrieval=true";
        String user = "root";
        String pass = "Nikhil_N@2130";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM exams")) {
            System.out.println("Exams:");
            while (rs.next()) {
                System.out.println("ID: " + rs.getInt("exam_id") + ", Name: " + rs.getString("exam_name") + ", Start: " + rs.getTimestamp("start_time") + ", End: " + rs.getTimestamp("end_time"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtils {

    private static final String DB_NAME = "PRJ301_Group_X";
    private static final String DB_USER_NAME = "sa";
    private static final String DB_PASSWORD = "123456";

    public static Connection getConnection() throws ClassNotFoundException, SQLException {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        String url = "jdbc:sqlserver://localhost;databaseName=PRJ301_Group_X;encrypt=true;trustServerCertificate=true";

        Connection conn = DriverManager.getConnection(url, DB_USER_NAME, DB_PASSWORD);
        return conn;
    }
}
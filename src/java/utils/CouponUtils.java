package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Coupon;

public class CouponUtils {

    public static Coupon getCouponByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM coupons WHERE code = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Coupon(
                        rs.getInt("id"),
                        rs.getString("code"),
                        rs.getDouble("discount_percent"),
                        rs.getDouble("min_order_value"),
                        rs.getTimestamp("start_date"),
                        rs.getTimestamp("end_date"),
                        rs.getInt("usage_limit"),
                        rs.getInt("used_count")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Coupon getCouponById(Connection conn, int id) throws SQLException {
        String sql = "SELECT * FROM coupons WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Coupon(
                        rs.getInt("id"),
                        rs.getString("code"),
                        rs.getDouble("discount_percent"),
                        rs.getDouble("min_order_value"),
                        rs.getTimestamp("start_date"),
                        rs.getTimestamp("end_date"),
                        rs.getInt("usage_limit"),
                        rs.getInt("used_count")
                    );
                }
            }
        }
        return null;
    }

    public static void updateUsedCount(Connection conn, int id) throws SQLException {
        String sql = "UPDATE coupons SET used_count = used_count + 1 WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}

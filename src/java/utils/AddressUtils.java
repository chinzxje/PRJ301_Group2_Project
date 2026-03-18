package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Address;

public class AddressUtils {

    public static List<Address> getAddressesByUser(Connection conn, String email) throws SQLException {
        String sql = "SELECT * FROM addresses WHERE user_email = ? ORDER BY is_default DESC, id DESC";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, email);
        ResultSet rs = pstm.executeQuery();
        List<Address> list = new ArrayList<>();
        while (rs.next()) {
            Address addr = new Address();
            addr.setId(rs.getInt("id"));
            addr.setUserEmail(rs.getString("user_email"));
            addr.setReceiverName(rs.getString("receiver_name"));
            addr.setPhoneNumber(rs.getString("phone_number"));
            addr.setAddressDetail(rs.getString("address_detail"));
            addr.setDefault(rs.getBoolean("is_default"));
            list.add(addr);
        }
        return list;
    }

    public static Address getAddressById(Connection conn, int id) throws SQLException {
        String sql = "SELECT * FROM addresses WHERE id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, id);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            Address addr = new Address();
            addr.setId(rs.getInt("id"));
            addr.setUserEmail(rs.getString("user_email"));
            addr.setReceiverName(rs.getString("receiver_name"));
            addr.setPhoneNumber(rs.getString("phone_number"));
            addr.setAddressDetail(rs.getString("address_detail"));
            addr.setDefault(rs.getBoolean("is_default"));
            return addr;
        }
        return null;
    }

    public static void insertAddress(Connection conn, Address addr) throws SQLException {
        if (addr.isDefault()) {
            resetDefaultAddress(conn, addr.getUserEmail());
        }
        String sql = "INSERT INTO addresses (user_email, receiver_name, phone_number, address_detail, is_default) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, addr.getUserEmail());
        pstm.setString(2, addr.getReceiverName());
        pstm.setString(3, addr.getPhoneNumber());
        pstm.setString(4, addr.getAddressDetail());
        pstm.setBoolean(5, addr.isDefault());
        pstm.executeUpdate();
    }

    public static void updateAddress(Connection conn, Address addr) throws SQLException {
        if (addr.isDefault()) {
            resetDefaultAddress(conn, addr.getUserEmail());
        }
        String sql = "UPDATE addresses SET receiver_name = ?, phone_number = ?, address_detail = ?, is_default = ? WHERE id = ? AND user_email = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, addr.getReceiverName());
        pstm.setString(2, addr.getPhoneNumber());
        pstm.setString(3, addr.getAddressDetail());
        pstm.setBoolean(4, addr.isDefault());
        pstm.setInt(5, addr.getId());
        pstm.setString(6, addr.getUserEmail());
        pstm.executeUpdate();
    }

    public static void deleteAddress(Connection conn, int id, String email) throws SQLException {
        String sql = "DELETE FROM addresses WHERE id = ? AND user_email = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, id);
        pstm.setString(2, email);
        pstm.executeUpdate();
    }

    private static void resetDefaultAddress(Connection conn, String email) throws SQLException {
        String sql = "UPDATE addresses SET is_default = 0 WHERE user_email = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, email);
        pstm.executeUpdate();
    }
}

package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Wishlist;
import model.Product;

public class WishlistUtils {

    public static List<Wishlist> getWishlistByUser(Connection conn, String email) throws SQLException {
        String sql = "SELECT w.*, p.name as product_name, p.price, p.image_url FROM wishlists w "
                   + "JOIN products p ON w.product_id = p.id "
                   + "WHERE w.user_email = ? "
                   + "ORDER BY w.created_at DESC";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, email);
        ResultSet rs = pstm.executeQuery();
        List<Wishlist> list = new ArrayList<>();
        while (rs.next()) {
            Wishlist w = new Wishlist();
            w.setId(rs.getInt("id"));
            w.setUserEmail(rs.getString("user_email"));
            w.setProductId(rs.getInt("product_id"));
            w.setCreatedAt(rs.getTimestamp("created_at"));
            
            Product p = new Product();
            p.setId(rs.getInt("product_id"));
            p.setName(rs.getString("product_name"));
            p.setPrice(rs.getDouble("price"));
            p.setImageUrl(rs.getString("image_url"));
            w.setProduct(p);
            
            list.add(w);
        }
        return list;
    }

    public static boolean checkInWishlist(Connection conn, String email, int productId) throws SQLException {
        String sql = "SELECT 1 FROM wishlists WHERE user_email = ? AND product_id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, email);
        pstm.setInt(2, productId);
        ResultSet rs = pstm.executeQuery();
        return rs.next();
    }

    public static void toggleWishlist(Connection conn, String email, int productId) throws SQLException {
        if(checkInWishlist(conn, email, productId)) {
            // Remove
            String sql = "DELETE FROM wishlists WHERE user_email = ? AND product_id = ?";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, email);
            pstm.setInt(2, productId);
            pstm.executeUpdate();
        } else {
            // Add
            String sql = "INSERT INTO wishlists(user_email, product_id, created_at) VALUES(?, ?, GETDATE())";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, email);
            pstm.setInt(2, productId);
            pstm.executeUpdate();
        }
    }
}

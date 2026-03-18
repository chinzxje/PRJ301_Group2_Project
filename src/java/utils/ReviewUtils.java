package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Review;
import model.User;

public class ReviewUtils {

    public static List<Review> getReviewsByProduct(Connection conn, int productId) throws SQLException {
        String sql = "SELECT r.*, u.full_name as user_name FROM reviews r "
                   + "JOIN users u ON r.user_email = u.email "
                   + "WHERE r.product_id = ? "
                   + "ORDER BY r.created_at DESC";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, productId);
        ResultSet rs = pstm.executeQuery();
        List<Review> list = new ArrayList<>();
        while (rs.next()) {
            Review review = new Review();
            review.setId(rs.getInt("id"));
            review.setUserEmail(rs.getString("user_email"));
            review.setProductId(rs.getInt("product_id"));
            review.setRating(rs.getInt("rating"));
            review.setComment(rs.getString("comment"));
            review.setCreatedAt(rs.getTimestamp("created_at"));
            
            // Map User info
            User user = new User();
            user.setEmail(rs.getString("user_email"));
            user.setFullName(rs.getString("user_name"));
            review.setUser(user);
            
            list.add(review);
        }
        return list;
    }

    public static void insertReview(Connection conn, Review review) throws SQLException {
        String sql = "INSERT INTO reviews(user_email, product_id, rating, comment, created_at) VALUES(?, ?, ?, ?, GETDATE())";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, review.getUserEmail());
        pstm.setInt(2, review.getProductId());
        pstm.setInt(3, review.getRating());
        pstm.setString(4, review.getComment());
        pstm.executeUpdate();
    }
}

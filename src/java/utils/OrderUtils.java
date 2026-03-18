package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import model.Product;
import model.Coupon;

public class OrderUtils {
    
    public static String checkout(Map<Integer, Integer> cart, String userEmail, int addressId, int couponId, String paymentMethod) {
        if (cart == null || cart.isEmpty()) {
            return "Giỏ hàng đang rỗng.";
        }
        
        ProductUtils productUtils = new ProductUtils();

        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Calculate Total Amount
                double totalAmount = 0;
                for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                    Product product = productUtils.getProductById(entry.getKey());
                    if (product != null) {
                        totalAmount += (product.getPrice() * entry.getValue());
                    }
                }
                
                if (couponId > 0) {
                    Coupon coupon = CouponUtils.getCouponById(conn, couponId);
                    if (coupon != null) {
                        if (totalAmount < coupon.getMinOrderValue()) {
                            conn.rollback();
                            return "Đơn hàng chưa đạt giá trị tối thiểu để áp dụng mã giảm giá này.";
                        }
                        long now = System.currentTimeMillis();
                        if (now < coupon.getStartDate().getTime() || now > coupon.getEndDate().getTime()) {
                            conn.rollback();
                            return "Mã giảm giá không trong thời gian có hiệu lực.";
                        }
                        if (coupon.getUsedCount() >= coupon.getUsageLimit()) {
                            conn.rollback();
                            return "Mã giảm giá đã hết lượt sử dụng.";
                        }
                        
                        double discount = totalAmount * (coupon.getDiscountPercent() / 100.0);
                        totalAmount -= discount;
                        CouponUtils.updateUsedCount(conn, couponId);
                    } else {
                        conn.rollback();
                        return "Mã giảm giá không tồn tại.";
                    }
                }
                
                // 1. Create Order
                int orderId = createOrder(conn, userEmail, addressId, couponId, totalAmount);
                
                // 2. Insert Order Items & Update Stock
                for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                    int productId = entry.getKey();
                    int quantity = entry.getValue();
                    if (quantity <= 0) {
                        conn.rollback();
                        return "Số lượng không hợp lệ.";
                    }

                    Product product = getProductByIdForUpdate(conn, productId);
                    if (product == null) {
                        conn.rollback();
                        return "Sản phẩm không tồn tại.";
                    }
                    if (product.getStock() < quantity) {
                        conn.rollback();
                        return "Không đủ tồn kho cho sản phẩm: " + product.getName();
                    }

                    insertOrderItem(conn, orderId, productId, quantity, product.getPrice());
                    updateStockAndSold(conn, productId, quantity);
                }
                
                // 3. Create Payment Record
                createPayment(conn, orderId, paymentMethod);

                conn.commit();
                return "Đặt hàng thành công!";
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi hệ thống: " + e.getMessage();
        }
    }

    private static int createOrder(Connection conn, String userEmail, int addressId, int couponId, double totalAmount) throws SQLException {
        String sql = "INSERT INTO orders(user_email, address_id, coupon_id, total_amount, status, created_at) VALUES(?, ?, ?, ?, 'Pending', GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userEmail);
            if(addressId > 0) ps.setInt(2, addressId); else ps.setNull(2, java.sql.Types.INTEGER);
            if(couponId > 0) ps.setInt(3, couponId); else ps.setNull(3, java.sql.Types.INTEGER);
            ps.setDouble(4, totalAmount);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Không tạo được order.");
    }
    
    private static void createPayment(Connection conn, int orderId, String paymentMethod) throws SQLException {
        String sql = "INSERT INTO payments(order_id, payment_method, payment_status, created_at) VALUES (?, ?, 'Pending', GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, paymentMethod != null && !paymentMethod.trim().isEmpty() ? paymentMethod : "COD");
            ps.executeUpdate();
        }
    }

    private static Product getProductByIdForUpdate(Connection conn, int id) throws SQLException {
        String sql = "SELECT id, category_id, brand_id, name, price, stock, sold, description, image_url FROM products WITH (UPDLOCK, ROWLOCK) WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Product(
                        rs.getInt("id"),
                        rs.getInt("category_id"),
                        rs.getInt("brand_id"),
                        rs.getString("name"),
                        rs.getDouble("price"),
                        rs.getInt("stock"),
                        rs.getInt("sold"),
                        rs.getString("description"),
                        rs.getString("image_url")
                    );
                }
            }
        }
        return null;
    }

    private static void updateStockAndSold(Connection conn, int productId, int quantity) throws SQLException {
        String sql = "UPDATE products SET stock = stock - ?, sold = sold + ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setInt(3, productId);
            ps.executeUpdate();
        }
    }

    private static void insertOrderItem(Connection conn, int orderId, int productId, int quantity, double price)
            throws SQLException {
        String sql = "INSERT INTO order_items(order_id, product_id, quantity, unit_price) VALUES(?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            ps.setDouble(4, price);
            ps.executeUpdate();
        }
    }
}

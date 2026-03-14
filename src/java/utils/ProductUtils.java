package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;

public class ProductUtils {

    public List<Product> searchProducts(String keyword, Double minPrice, Double maxPrice) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, name, brand, price, stock, sold, description, image_url FROM products WHERE 1=1");
        List<Object> params = new ArrayList<>();

       if (keyword != null && !keyword.trim().isEmpty()) {
    String[] keywords = keyword.trim().split("\\s+");

    sql.append(" AND (");

    for (int i = 0; i < keywords.length; i++) {
        if (i > 0) sql.append(" OR ");

        sql.append("(name COLLATE Latin1_General_CI_AI LIKE ? OR brand COLLATE Latin1_General_CI_AI LIKE ?)");

        String like = "%" + keywords[i].trim() + "%";
        params.add(like);
        params.add(like);
    }

    sql.append(")");
}
        

        if (minPrice != null) {
            sql.append(" AND price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND price <= ?");
            params.add(maxPrice);
        }
        sql.append(" ORDER BY id DESC");

        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return products;
    }

    public List<Product> getProducts() {
        return searchProducts(null, null, null);
    }

    public Product getProductById(int id) {
        String sql = "SELECT id, name, brand, price, stock, sold, description, image_url FROM products WHERE id = ?";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    public void saveProduct(Product product) {
        if (product.getId() <= 0) {
            insertProduct(product);
            return;
        }
        updateProduct(product);
    }

    private void insertProduct(Product product) {
        String sql = "INSERT INTO products(name, brand, price, stock, sold, description, image_url) VALUES(?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getBrand());
            ps.setDouble(3, product.getPrice());
            ps.setInt(4, product.getStock());
            ps.setInt(5, product.getSold());
            ps.setString(6, product.getDescription());
            ps.setString(7, product.getImageUrl());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void updateProduct(Product product) {
        String sql = "UPDATE products SET name=?, brand=?, price=?, stock=?, sold=?, description=?, image_url=? WHERE id=?";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getBrand());
            ps.setDouble(3, product.getPrice());
            ps.setInt(4, product.getStock());
            ps.setInt(5, product.getSold());
            ps.setString(6, product.getDescription());
            ps.setString(7, product.getImageUrl());
            ps.setInt(8, product.getId());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public String checkout(java.util.Map<Integer, Integer> cart, String userEmail) {
        if (cart == null || cart.isEmpty()) {
            return "Giỏ hàng đang rỗng.";
        }

        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId = createOrder(conn, userEmail);
                for (java.util.Map.Entry<Integer, Integer> entry : cart.entrySet()) {
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

                conn.commit();
                return "Đặt hàng thành công!    ";
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private int createOrder(Connection conn, String userEmail) throws SQLException {
        String sql = "INSERT INTO orders(user_email, created_at) VALUES(?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userEmail);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Không tạo được order.");
    }

    private Product getProductByIdForUpdate(Connection conn, int id) throws SQLException {
        String sql = "SELECT id, name, brand, price, stock, sold, description, image_url FROM products WITH (UPDLOCK, ROWLOCK) WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private void updateStockAndSold(Connection conn, int productId, int quantity) throws SQLException {
        String sql = "UPDATE products SET stock = stock - ?, sold = sold + ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setInt(3, productId);
            ps.executeUpdate();
        }
    }

    private void insertOrderItem(Connection conn, int orderId, int productId, int quantity, double price)
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

    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }

    public int getTotalSold() {
        String sql = "SELECT ISNULL(SUM(sold), 0) FROM products";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }

    public double getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(CAST(sold AS FLOAT) * price), 0) FROM products";
        try (Connection conn = DBUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        return new Product(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("brand"),
                rs.getDouble("price"),
                rs.getInt("stock"),
                rs.getInt("sold"),
                rs.getString("description"),
                rs.getString("image_url"));
    }
}

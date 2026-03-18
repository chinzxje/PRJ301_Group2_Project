package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.Category;
import model.Brand;

public class ProductUtils {

    public List<Product> searchProducts(String keyword, Double minPrice, Double maxPrice, Integer categoryId, Integer brandId) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.id, p.category_id, p.brand_id, p.name, p.price, p.stock, p.sold, p.description, p.image_url, " +
                "c.name as category_name, b.name as brand_name " +
                "FROM products p " +
                "LEFT JOIN categories c ON p.category_id = c.id " +
                "LEFT JOIN brands b ON p.brand_id = b.id " +
                "WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String[] keywords = keyword.trim().split("\\s+");
            sql.append(" AND (");
            for (int i = 0; i < keywords.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("(p.name COLLATE Latin1_General_CI_AI LIKE ? OR c.name COLLATE Latin1_General_CI_AI LIKE ? OR b.name COLLATE Latin1_General_CI_AI LIKE ?)");
                String like = "%" + keywords[i].trim() + "%";
                params.add(like);
                params.add(like);
                params.add(like);
            }
            sql.append(")");
        }

        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (brandId != null && brandId > 0) {
            sql.append(" AND p.brand_id = ?");
            params.add(brandId);
        }
        
        sql.append(" ORDER BY p.id DESC");

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapRowWithJoins(rs));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return products;
    }

    public List<Product> getProducts() {
        return searchProducts(null, null, null, null, null);
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.id, p.category_id, p.brand_id, p.name, p.price, p.stock, p.sold, p.description, p.image_url, " +
                     "c.name as category_name, b.name as brand_name " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "LEFT JOIN brands b ON p.brand_id = b.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowWithJoins(rs);
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
        String sql = "INSERT INTO products(category_id, brand_id, name, price, stock, sold, description, image_url) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, product.getCategoryId());
            ps.setInt(2, product.getBrandId());
            ps.setString(3, product.getName());
            ps.setDouble(4, product.getPrice());
            ps.setInt(5, product.getStock());
            ps.setInt(6, product.getSold());
            ps.setString(7, product.getDescription());
            ps.setString(8, product.getImageUrl());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void updateProduct(Product product) {
        String sql = "UPDATE products SET category_id=?, brand_id=?, name=?, price=?, stock=?, sold=?, description=?, image_url=? WHERE id=?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, product.getCategoryId());
            ps.setInt(2, product.getBrandId());
            ps.setString(3, product.getName());
            ps.setDouble(4, product.getPrice());
            ps.setInt(5, product.getStock());
            ps.setInt(6, product.getSold());
            ps.setString(7, product.getDescription());
            ps.setString(8, product.getImageUrl());
            ps.setInt(9, product.getId());
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

    // Notice: The checkout method has been disabled here as we will be creating a dedicated OrderUtils to handle complex checkout flows
    // with Address and Payment records instead of doing it all in ProductUtils.
    
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

    private Product mapRowWithJoins(ResultSet rs) throws SQLException {
        Product p = new Product(
                rs.getInt("id"),
                rs.getInt("category_id"),
                rs.getInt("brand_id"),
                rs.getString("name"),
                rs.getDouble("price"),
                rs.getInt("stock"),
                rs.getInt("sold"),
                rs.getString("description"),
                rs.getString("image_url"));
                
        Category c = new Category();
        c.setId(rs.getInt("category_id"));
        c.setName(rs.getString("category_name"));
        p.setCategory(c);
        
        Brand b = new Brand();
        b.setId(rs.getInt("brand_id"));
        b.setName(rs.getString("brand_name"));
        p.setBrand(b);
        
        return p;
    }
}

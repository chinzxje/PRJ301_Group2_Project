package model;

import java.sql.Timestamp;

public class Wishlist {
    private int id;
    private String userEmail;
    private int productId;
    private Timestamp createdAt;

    // Additional properties for join queries
    private Product product;

    public Wishlist() {
    }

    public Wishlist(int id, String userEmail, int productId, Timestamp createdAt) {
        this.id = id;
        this.userEmail = userEmail;
        this.productId = productId;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
}

package model;

import java.sql.Timestamp;

public class Review {
    private int id;
    private String userEmail;
    private int productId;
    private int rating;
    private String comment;
    private Timestamp createdAt;
    
    // Additional properties for join queries
    private User user;

    public Review() {
    }

    public Review(int id, String userEmail, int productId, int rating, String comment, Timestamp createdAt) {
        this.id = id;
        this.userEmail = userEmail;
        this.productId = productId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
}

package model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private String userEmail;
    private int addressId;
    private int couponId;
    private double totalAmount;
    private String status;
    private Timestamp createdAt;

    // Optional joins
    private User user;
    private Address address;
    private Coupon coupon;

    public Order() {
    }

    public Order(int id, String userEmail, int addressId, int couponId, double totalAmount, String status, Timestamp createdAt) {
        this.id = id;
        this.userEmail = userEmail;
        this.addressId = addressId;
        this.couponId = couponId;
        this.totalAmount = totalAmount;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public int getAddressId() { return addressId; }
    public void setAddressId(int addressId) { this.addressId = addressId; }
    public int getCouponId() { return couponId; }
    public void setCouponId(int couponId) { this.couponId = couponId; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Address getAddress() { return address; }
    public void setAddress(Address address) { this.address = address; }
    public Coupon getCoupon() { return coupon; }
    public void setCoupon(Coupon coupon) { this.coupon = coupon; }
}

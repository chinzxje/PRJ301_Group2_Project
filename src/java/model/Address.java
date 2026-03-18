package model;

public class Address {
    private int id;
    private String userEmail;
    private String receiverName;
    private String phoneNumber;
    private String addressDetail;
    private boolean isDefault;

    public Address() {
    }

    public Address(int id, String userEmail, String receiverName, String phoneNumber, String addressDetail, boolean isDefault) {
        this.id = id;
        this.userEmail = userEmail;
        this.receiverName = receiverName;
        this.phoneNumber = phoneNumber;
        this.addressDetail = addressDetail;
        this.isDefault = isDefault;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getAddressDetail() { return addressDetail; }
    public void setAddressDetail(String addressDetail) { this.addressDetail = addressDetail; }
    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }
}

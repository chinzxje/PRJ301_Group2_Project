package model;

public class Product {
    private int id;
    private int categoryId;
    private int brandId;
    private String name;
    private double price;
    private int stock;
    private int sold;
    private String description;
    private String imageUrl;
    
    // Additional properties for join queries
    private Category category;
    private Brand brand;

    public Product() {
    }

    public Product(int id, int categoryId, int brandId, String name, double price, int stock, int sold, String description, String imageUrl) {
        this.id = id;
        this.categoryId = categoryId;
        this.brandId = brandId;
        this.name = name;
        this.price = price;
        this.stock = stock;
        this.sold = sold;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public int getSold() { return sold; }
    public void setSold(int sold) { this.sold = sold; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }
    public Brand getBrand() { return brand; }
    public void setBrand(Brand brand) { this.brand = brand; }
}

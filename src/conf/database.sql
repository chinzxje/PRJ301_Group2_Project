IF DB_ID('PRJ301_Group_X') IS NULL
BEGIN
    CREATE DATABASE PRJ301_Group_X;
END
GO

USE PRJ301_Group_X;
GO

IF OBJECT_ID('order_items', 'U') IS NOT NULL DROP TABLE order_items;
IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products;
IF OBJECT_ID('users', 'U') IS NOT NULL DROP TABLE users;
GO

CREATE TABLE users (
    email VARCHAR(100) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL
);
GO

CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    brand NVARCHAR(100) NOT NULL,
    price FLOAT NOT NULL,
    stock INT NOT NULL,
    sold INT NOT NULL DEFAULT 0,
    description NVARCHAR(500),
    image_url VARCHAR(500)
);
GO

CREATE TABLE orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT FK_orders_users FOREIGN KEY(user_email) REFERENCES users(email)
);
GO

CREATE TABLE order_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price FLOAT NOT NULL,
    CONSTRAINT FK_order_items_orders FOREIGN KEY(order_id) REFERENCES orders(id),
    CONSTRAINT FK_order_items_products FOREIGN KEY(product_id) REFERENCES products(id)
);
GO

INSERT INTO users(email, full_name, password, role)
VALUES
('admin@gmail.com', N'Administrator', '123', 'ADMIN'),
('user@gmail.com', N'Student User', '123', 'USER');
GO

INSERT INTO products(name, brand, price, stock, sold, description, image_url)
VALUES
(N'Laptop Dell Inspiron 15', N'Dell', 15990000, 10, 3, N'Laptop hoc tap, van phong', 'https://picsum.photos/seed/laptop-dell/640/400'),
(N'Laptop Asus Vivobook', N'Asus', 13990000, 8, 2, N'Mau nhe, pin tot', 'https://picsum.photos/seed/laptop-asus/640/400'),
(N'MacBook Air M1', N'Apple', 19990000, 5, 4, N'MacBook cho hoc tap va lap trinh', 'https://picsum.photos/seed/laptop-macbook/640/400'),
(N'PC Gaming RTX 4060', N'Custom', 24990000, 3, 1, N'May tinh cho game va do hoa', 'https://picsum.photos/seed/pc-gaming/640/400'),
(N'Man hinh LG 24 inch', N'LG', 2990000, 15, 6, N'Man hinh Full HD', 'https://picsum.photos/seed/monitor-lg/640/400'),
(N'Ban phim co Keychron', N'Keychron', 1890000, 20, 8, N'Ban phim co hot swap', 'https://picsum.photos/seed/keyboard-keychron/640/400');
GO

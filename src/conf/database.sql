IF DB_ID('PRJ301_Group_X') IS NULL
BEGIN
    CREATE DATABASE PRJ301_Group_X;
END
GO

USE PRJ301_Group_X;
GO

-- DROP TABLES in order to avoid foreign key conflicts
IF OBJECT_ID('reviews', 'U') IS NOT NULL DROP TABLE reviews;
IF OBJECT_ID('product_images', 'U') IS NOT NULL DROP TABLE product_images;
IF OBJECT_ID('wishlists', 'U') IS NOT NULL DROP TABLE wishlists;
IF OBJECT_ID('order_items', 'U') IS NOT NULL DROP TABLE order_items;
IF OBJECT_ID('payments', 'U') IS NOT NULL DROP TABLE payments;
IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('addresses', 'U') IS NOT NULL DROP TABLE addresses;
IF OBJECT_ID('coupons', 'U') IS NOT NULL DROP TABLE coupons;
IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products;
IF OBJECT_ID('brands', 'U') IS NOT NULL DROP TABLE brands;
IF OBJECT_ID('categories', 'U') IS NOT NULL DROP TABLE categories;
IF OBJECT_ID('users', 'U') IS NOT NULL DROP TABLE users;
GO

CREATE TABLE users (
    email VARCHAR(100) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL
);
GO

-- 1. Bảng Categories
CREATE TABLE categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500)
);
GO

-- 2. Bảng Brands
CREATE TABLE brands (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    logo_url VARCHAR(500)
);
GO

-- Cập nhật bảng Products (Thêm category_id, brand_id)
CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    category_id INT NOT NULL,
    brand_id INT NOT NULL,
    name NVARCHAR(200) NOT NULL,
    price FLOAT NOT NULL,
    stock INT NOT NULL,
    sold INT NOT NULL DEFAULT 0,
    description NVARCHAR(500),
    image_url VARCHAR(500),
    CONSTRAINT FK_products_categories FOREIGN KEY(category_id) REFERENCES categories(id),
    CONSTRAINT FK_products_brands FOREIGN KEY(brand_id) REFERENCES brands(id)
);
GO

-- 3. Bảng Product Images
CREATE TABLE product_images (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BIT DEFAULT 0,
    CONSTRAINT FK_product_images_products FOREIGN KEY(product_id) REFERENCES products(id)
);
GO

-- 4. Bảng Reviews
CREATE TABLE reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK(rating BETWEEN 1 AND 5) NOT NULL,
    comment NVARCHAR(1000),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_reviews_users FOREIGN KEY(user_email) REFERENCES users(email),
    CONSTRAINT FK_reviews_products FOREIGN KEY(product_id) REFERENCES products(id)
);
GO

-- 5. Bảng Wishlists
CREATE TABLE wishlists (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_wishlists_user_product UNIQUE (user_email, product_id),
    CONSTRAINT FK_wishlists_users FOREIGN KEY(user_email) REFERENCES users(email),
    CONSTRAINT FK_wishlists_products FOREIGN KEY(product_id) REFERENCES products(id)
);
GO

-- 6. Bảng Addresses
CREATE TABLE addresses (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    receiver_name NVARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_detail NVARCHAR(500) NOT NULL,
    is_default BIT DEFAULT 0,
    CONSTRAINT FK_addresses_users FOREIGN KEY(user_email) REFERENCES users(email)
);
GO

-- 7. Bảng Coupons
CREATE TABLE coupons (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent FLOAT NOT NULL,
    min_order_value FLOAT DEFAULT 0,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    usage_limit INT DEFAULT 1,
    used_count INT DEFAULT 0
);
GO

-- Cập nhật bảng Orders (Thêm address_id, coupon_id, chuyển đổi status, v.v...)
CREATE TABLE orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL,
    address_id INT, 
    coupon_id INT,
    total_amount FLOAT NOT NULL DEFAULT 0,
    status NVARCHAR(50) DEFAULT 'Pending',
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_orders_users FOREIGN KEY(user_email) REFERENCES users(email),
    CONSTRAINT FK_orders_addresses FOREIGN KEY(address_id) REFERENCES addresses(id),
    CONSTRAINT FK_orders_coupons FOREIGN KEY(coupon_id) REFERENCES coupons(id)
);
GO

-- Bảng Order Items (Giữ nguyên, bổ sung FK)
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

-- 8. Bảng Payments
CREATE TABLE payments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_payments_orders FOREIGN KEY(order_id) REFERENCES orders(id)
);
GO

-- =========================================
-- SAMPLE DATA
-- =========================================

INSERT INTO users(email, full_name, password, role)
VALUES
('admin@gmail.com', N'Administrator', '123', 'ADMIN'),
('user@gmail.com', N'Student User', '123', 'USER');
GO

INSERT INTO categories(name, description) VALUES
(N'Laptop Gaming', N'Laptop cấu hình khủng dành cho game thủ'),
(N'Laptop Văn Phòng', N'Laptop mỏng nhẹ, pin trâu cho dân văn phòng, sinh viên'),
(N'PC Gaming', N'Máy tính để bàn chơi game, tản nhiệt tốt'),
(N'Màn Hình', N'Màn hình máy tính tần số quét cao, độ phân giải sắc nét'),
(N'Bàn Phím Cơ', N'Bàn phím cơ chuyên game, gõ êm ái'),
(N'Chuột Gaming', N'Chuột độ nhạy cao, form dáng chuẩn công thái học');
GO

INSERT INTO brands(name, logo_url) VALUES
(N'Asus', 'https://upload.wikimedia.org/wikipedia/commons/2/2e/ASUS_Logo.svg'),
(N'Dell', 'https://upload.wikimedia.org/wikipedia/commons/1/18/Dell_logo_2016.svg'),
(N'Acer', 'https://upload.wikimedia.org/wikipedia/commons/0/00/Acer_2011.svg'),
(N'LG', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/LG_logo_%282014%29.svg/960px-LG_logo_%282014%29.svg.png'),
(N'Logitech', 'https://upload.wikimedia.org/wikipedia/commons/1/17/Logitech_logo.svg'),
(N'Akko', 'https://cdn.brandfetch.io/domain/akkogear.com/fallback/lettermark/theme/dark/h/400/w/400/icon?c=1bfwsmEH20zzEfSNTed');
GO

-- Insert Realistic Products (10 per category)
INSERT INTO products(category_id, brand_id, name, price, stock, sold, description, image_url)
VALUES
-- =================== CATEGORY 1: Laptop Gaming ===================
(1, 1, N'Laptop Gaming ASUS ROG Strix G15', 21990000, 15, 5, N'CPU: Ryzen 7 4800H, RAM: 8GB, SSD 512GB, GTX 1650 4GB. Màn: 15.6" FHD 144Hz.', 'https://cdn.tgdd.vn/Products/Images/44/258231/asus-rog-strix-gaming-g15-g513ih-r7-hn015t-101121-103002-600x600.jpg'),
(1, 1, N'Laptop Gaming ASUS TUF Dash F15', 18990000, 10, 8, N'CPU: Core i5 11300H, RAM: 8GB, SSD 512GB, RTX 3050. Mỏng nhẹ chuyên nghiệp.', 'https://cdn.tgdd.vn/Products/Images/44/274921/asus-tuf-gaming-fx517zc-i5-hn077w-190322-114627-600x600.jpg'),
(1, 1, N'Laptop Gaming ASUS ROG Zephyrus G14', 28990000, 5, 2, N'CPU: Ryzen 9 5900HS, RAM: 16GB, SSD 1TB, RTX 3060. Đỉnh cao cơ động.', 'https://cdn.tgdd.vn/Products/Images/44/310802/asus-gaming-rog-zephyrus-g14-ga402nj-r7-l4056w-thumb-600x600.jpg'),
(1, 2, N'Laptop Gaming Dell G15 5515', 22490000, 20, 12, N'CPU: Ryzen 5 5600H, RAM: 16GB, SSD 512GB, RTX 3050Ti. Bền bỉ hiệu năng.', 'https://cdn.tgdd.vn/Products/Images/44/260170/dell-gaming-g15-5515-r5-p105f004cgr-291121-115616-600x600.jpg'),
(1, 2, N'Laptop Gaming Dell Alienware m15 R6', 45990000, 3, 1, N'CPU: Core i7 11800H, RAM: 32GB, SSD 1TB, RTX 3070 8GB. Đẳng cấp game thủ.', 'https://cdn.tgdd.vn/Products/Images/44/271545/dell-gaming-alienware-m15-r6-i7-p109f001dbl-020322-112012-600x600.jpg'),
(1, 3, N'Laptop Gaming Acer Nitro 5 Eagle', 16990000, 30, 22, N'CPU: Core i5 11400H, RAM: 8GB, SSD 512GB, GTX 1650. Quốc dân Gaming.', 'https://cdn.tgdd.vn/Products/Images/44/308489/acer-gaming-nitro-5-an515-57-53f9-i5-nhqensv008-thumb-600x600.jpg'),
(1, 3, N'Laptop Gaming Acer Predator Helios 300', 31990000, 7, 4, N'CPU: Core i7 11800H, RAM: 16GB, SSD 512GB, RTX 3060. Quái vật làm mát.', 'https://nguyencongpc.vn/media/product/23707-laptop-acer-predator-helios-300-ph315-55-751d-nh-qftsv-002-6.jpeg'),
(1, 3, N'Laptop Gaming Acer Triton 500 SE', 55990000, 2, 0, N'CPU: Core i9 11900H, RAM: 32GB, SSD 2TB, RTX 3080. Cỗ máy tối thượng.', 'https://laptopaz.vn/media/product/2535_laptopaz_acer_predator_triton_500_1.jpg'),
(1, 2, N'Laptop Gaming Dell G15 5511', 23990000, 12, 6, N'CPU: Core i5 11400H, RAM: 8GB, SSD 512GB, RTX 3050. Màn 120Hz mượt mà.', 'https://cdn.tgdd.vn/Products/Images/44/271541/dell-gaming-g15-5511-i7-p105f006bgr-140222-091855-600x600.jpg'),
(1, 1, N'Laptop Gaming ASUS TUF Gaming A15', 20990000, 15, 9, N'CPU: Ryzen 7 5800H, RAM: 8GB, SSD 512GB, RTX 3050. Pin cực trâu.', 'https://dlcdnwebimgs.asus.com/gain/8b25250f-bf55-425f-93bd-b5d8e2744b3e/'),

-- =================== CATEGORY 2: Laptop Văn Phòng ===================
(2, 1, N'Laptop ASUS Zenbook 14 OLED', 24990000, 20, 15, N'CPU: Core i5 1240P, RAM: 16GB, SSD 512GB, Màn OLED 2.8K siêu đẹp.', 'https://cdn.tgdd.vn/Products/Images/44/325480/asus-zenbook-14-oled-i5-km657w-1-750x500.jpg'),
(2, 1, N'Laptop ASUS Vivobook 15', 13500000, 40, 30, N'CPU: Core i3 1115G4, RAM: 8GB, SSD 512GB. Giá sinh viên, học tập tốt.', 'https://product.hstatic.net/200000680839/product/asus-vivobook-15-x1504va-nj023w-thumb-600x600_2185192836324c4c84e39a4931ba134e.jpg'),
(2, 1, N'Laptop ASUS ExpertBook B9', 39990000, 5, 2, N'CPU: Core i7 1165G7, RAM: 16GB, SSD 1TB. Siêu nhẹ 880g, pin 24h.', 'https://www.tnc.com.vn/uploads/product/sp2025/ext/laptop-asus-expertbook-b9-oled-b9403cvar-km0837x-149415.jpg'),
(2, 2, N'Laptop Dell XPS 13 9310', 36990000, 8, 4, N'CPU: Core i5 1135G7, RAM: 8GB, SSD 512GB, Màn 13.4" FHD+ tràn viền.', 'https://cdn.tgdd.vn/Products/Images/44/269554/dell-xps-13-9310-i5-1135g7-8gb-512gb-cap-office-600x600.jpg'),
(2, 2, N'Laptop Dell XPS 15 9520', 52990000, 4, 1, N'CPU: Core i7 12700H, RAM: 16GB, SSD 512GB, RTX 3050Ti. Sức mạnh sáng tạo.', 'https://laptopaz.vn/media/product/2484_laptopaz_dell_xps_9520_2.jpg'),
(2, 2, N'Laptop Dell Inspiron 15 3511', 14990000, 50, 40, N'CPU: Core i5 1135G7, RAM: 8GB, SSD 512GB. Tiêu chuẩn quốc dân.', 'https://cdn.tgdd.vn/Products/Images/44/265469/dell-inspiron-15-3511-i5-1135g7-4gb-512gb-600x600.jpg'),
(2, 2, N'Laptop Dell Vostro 3400', 12990000, 35, 25, N'CPU: Core i3 1115G4, RAM: 8GB, SSD 256GB. Nhỏ gọn, bền bỉ văn phòng.', 'https://cdn.tgdd.vn/Products/Images/44/266085/dell-vostro-3400-i5-1135g7-8gb-256gb-600x600.jpg'),
(2, 3, N'Laptop Acer Swift 3', 18990000, 15, 7, N'CPU: Core i5 1135G7, RAM: 16GB, SSD 512GB. Vỏ nhôm nguyên khối, chuẩn Evo.', 'https://cdn.tgdd.vn/Products/Images/44/269313/acer-swift-3-sf314-511-55qe-i5-nxabnsv003-120122-022600-600x600.jpg'),
(2, 3, N'Laptop Acer Aspire 5', 15990000, 25, 12, N'CPU: Core i5 1135G7, RAM: 8GB, SSD 512GB. Thiết kế trẻ trung, màn viền mỏng.', 'https://product.hstatic.net/200000680839/product/acer-aspire-a515-58gm-53pz-i5-nxkq4sv008-thumb-1-600x600_a866cdc16f814c52a07da903309edb9a.jpg'),
(2, 4, N'Laptop LG Gram 16', 32990000, 10, 3, N'CPU: Core i7 1165G7, RAM: 16GB, SSD 512GB. Màn 16" siêu rộng siêu nhẹ 1.1kg.', 'https://cdn.tgdd.vn/Products/Images/44/238132/lg-gram-16-i7-16z90pgah73a5-600x600.jpg'),

-- =================== CATEGORY 3: PC Gaming ===================
(3, 1, N'PC GVN VIPER (i3 12100F/1650)', 11590000, 20, 12, N'Main H610, Core i3 12100F, RAM 8GB, GTX 1650 4GB. PC Game eSport.', 'https://product.hstatic.net/200000722513/product/pc_gvn_i3_1650_-_25_49bfa7eacaf842b5b2569b0d041c2b23_master.jpg'),
(3, 1, N'PC GVN GHOST (i5 12400F/RTX 3060)', 19990000, 15, 8, N'Main B660, Core i5 12400F, RAM 16GB, RTX 3060 12GB. Chiến Max Setting.', 'https://cdn.hstatic.net/products/200000722513/d_i_di_n_af47907dba164a95b13f999c94f82324_master.jpg'),
(3, 1, N'PC GVN TITAN (i7 13700K/RTX 4070)', 45990000, 5, 1, N'Main Z790, Core i7 13700K, RAM 32GB DDR5, RTX 4070 12GB. Hiệu năng đỉnh.', 'https://cdn.hstatic.net/products/200000722513/web__4_of_101__3dd4fddf61544c3ca40c52a89ebabe7e_master.jpg'),
(3, 2, N'PC Dell Alienware Aurora R13', 65990000, 3, 0, N'Core i7 12700KF, RAM 32GB, SSD 1TB, RTX 3080. Thiết kế phi thuyền.', 'https://nvs.tn-cdn.net/2023/05/dell-alienware-aurora-r13-70297322-1-510x510.jpg'),
(3, 2, N'PC Dell XPS Desktop', 35990000, 5, 2, N'Core i7 12700, RAM 16GB, SSD 512GB + HDD 1TB, RTX 3060 Ti. Làm việc & Game.', 'https://st4.tkcomputer.vn/uploads/xps_desktop_8930_3_1693070049_480.jpg'),
(3, 3, N'PC Acer Predator Orion 3000', 31990000, 8, 3, N'Core i7 11700F, RAM 16GB, SSD 512GB, RTX 3060. Tản nhiệt FrostBlade.', 'https://c1.neweggimages.com/MPS/SellerPortal/AplusContent/25b75f1b3bdcd5b2cc123690335c45ff3b0a2c3d2a8cd50a80cda10df6bbb0c0.jpg'),
(3, 3, N'PC Acer Predator Orion 7000', 89990000, 2, 0, N'Core i9 12900K, RAM 64GB DDR5, SSD 2TB, RTX 3090. Vua của các loài PC.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0U0KKp41I8VPcJ5mFfJjpF8wzqdSo1Q0-xg&s'),
(3, 1, N'PC GVN PHANTOM (Ryzen 5/RX 6600)', 17590000, 12, 6, N'Main B550, Ryzen 5 5600X, RAM 16GB, RX 6600 8GB. P/P tối thượng nhà AMD.', 'https://product.hstatic.net/200000722513/product/pc_gvn_rx6600_-_3_0782e7ab4b554087abc6f69a38a17294.png'),
(3, 1, N'PC GVN SHADOW (i5 10400F/1660S)', 13990000, 25, 18, N'Main B460, Core i5 10400F, RAM 16GB, GTX 1660 Super. Quốc dân cấu hình.', 'https://product.hstatic.net/200000536009/product/1303_10d8fdeae636409d9eb9f19a89f41ee6.jpg'),
(3, 1, N'PC GVN DRAGON (Ryzen 7/RTX 3070)', 32000000, 8, 4, N'Main X570, Ryzen 7 5800X, RAM 32GB RGB, RTX 3070. Rồng đỏ thức tỉnh.', 'https://cdn.hstatic.net/products/200000722513/post-09_90f7f04091324d03808f8755f21ce4b1.jpg'),

-- =================== CATEGORY 4: Màn Hình ===================
(4, 4, N'Màn hình LG UltraGear 24GN650-B 24" IPS 144Hz', 3990000, 50, 35, N'24 inch, IPS, FHD, 144Hz, 1ms. Phù hợp chơi mọi thể loại game.', 'https://nguyencongpc.vn/media/product/23008-24gn650-b.jpg'),
(4, 4, N'Màn hình LG UltraGear 27GP850-B 27" Nano IPS 2K 165Hz', 9990000, 20, 10, N'27 inch, Nano IPS, 2K (2560x1440), 165Hz, chuẩn DCI-P3 98%.', 'https://thegioithietbiso.com/data/product/njx1632632880.jpeg'),
(4, 4, N'Màn hình LG 27UP600 27" IPS 4K HDR', 8990000, 15, 8, N'27 inch, IPS, 4K UHD, HDR400. Chuẩn xác màu sắc đồ họa.', 'https://laptopworld.vn/media/product/8137_m__n_h__nh_lg_27up600_w_1.jpg'),
(4, 4, N'Màn hình LG 24MP60G-B 24" IPS 75Hz', 3290000, 40, 25, N'24 inch, IPS, FHD, 75Hz, sRGB 99%. Làm việc mượt mà.', 'https://nguyencongpc.vn/media/product/19657-24mp60g-b.jpg'),
(4, 1, N'Màn hình ASUS TUF Gaming VG27AQ 27" IPS 2K 165Hz', 8590000, 25, 14, N'27 inch, IPS, 2K, 165Hz, G-Sync Compatible, HDR10.', 'https://nguyencongpc.vn/media/product/25255-30829_vg27aq_tuf_gaming_lcd_2.jpg'),
(4, 1, N'Màn hình ASUS ROG Swift PG259QN 24.5" IPS 360Hz', 18990000, 5, 2, N'Siêu mượt 360Hz thiết kế cho Esport chuyên nghiệp.', 'https://nguyencongpc.vn/media/product/19749-asus-rog-swift-pg259qn.jpg'),
(4, 1, N'Màn hình ASUS VZ24EHE 24" IPS 75Hz', 2890000, 60, 45, N'Bảo vệ mắt, viền siêu mỏng gọn nhẹ cho văn phòng.', 'https://product.hstatic.net/200000420363/product/vz24ehe-03-t_f5eee96697e64aca8ce8e32f5b950bd0_1024x1024.jpg'),
(4, 2, N'Màn hình Dell UltraSharp U2422H 24" IPS', 6290000, 30, 22, N'Độ chuẩn màu cao, viền mỏng vô cực, lý tưởng cho Coder/Designer.', 'https://laptopre.vn/upload/picture/picture-01718936497.jpg'),
(4, 2, N'Màn hình Dell UltraSharp U2720Q 27" IPS 4K', 14590000, 15, 6, N'Màn hình 4K đỉnh cao, cổng Type-C xuất ảnh sạc PD 90W.', 'https://cdn2.cellphones.com.vn/x/media/catalog/product/m/a/man-hinh-dell-ultrasharp-27-inch-u2720q_4_.jpg'),
(4, 3, N'Màn hình Acer Nitro VG270 27" IPS 75Hz', 3990000, 25, 12, N'Thiết kế ngầu gaming, viền sừng trâu, IPS góc nhìn rộng.', 'https://nguyencongpc.vn/media/product/20760-nitro-vg270-s-6.jpg'),

-- =================== CATEGORY 5: Bàn Phím Cơ ===================
(5, 6, N'Bàn phím cơ AKKO 3098B Multi-modes Black Gold', 1990000, 30, 15, N'3 chế độ kết nối (Wireless/Bluetooth/Type-C), Akko CS Jelly Pink.', 'https://akkogear.com.vn/wp-content/uploads/2021/08/ban-phim-co-akko-3098n-multi-modes-black-gold-ava.jpg'),
(5, 6, N'Bàn phím cơ AKKO 3108 RF One Piece', 1590000, 20, 10, N'Bản quyền One Piece siêu độc, fullsize, switch Akko V3.', 'https://cdn2.cellphones.com.vn/x/media/catalog/product/b/a/ban-phim-co-akko-3108-rf-one-piece-luffy-cream_1_.png'),
(5, 6, N'Bàn phím cơ AKKO 3068B Plus Blue on White', 1890000, 15, 8, N'Tối giản 68 phím, gọn gàng, keycap PBT siêu bền.', 'https://akkogear.com.vn/wp-content/uploads/2022/08/ban-phim-co-akko-3068b-plus-blue-on-white-04.jpg'),
(5, 6, N'Kit Bàn phím cơ AKKO MOD007 v2', 3990000, 10, 3, N'Nhôm nguyên khối CNC cao cấp cấu trúc Gasket mount.', 'https://product.hstatic.net/200000889805/product/kit-ban-phim-co-akko-designer-studio-_-mod007v2-vbk6g_ed9730713c3e4e738eb69ecce6f169dc_master.jpg'),
(5, 5, N'Bàn phím cơ Logitech G Pro X Keyboard', 2890000, 25, 12, N'Hotswap switch GX, gọn gàng Tenkeyless cho phân khúc Esport.', 'https://hanoicomputercdn.com/media/product/49500_ban_phim_co_logitech_g_pro_x_rgb_lightsync_mechanical_gx_blue_switch_gaming_keyboard_0001_1.jpg'),
(5, 5, N'Bàn phím cơ không dây Logitech G915 TKL Lightspeed', 4490000, 15, 6, N'Siêu mỏng (low profile), Nhôm xước, không dây độ trễ cực thấp LIGHTSPEED.', 'https://bizweb.dktcdn.net/thumb/grande/100/329/122/products/ban-phim-co-khong-day-logitech-g915-x-lightspeed-tkl-07.jpg?v=1727148060207'),
(5, 5, N'Bàn phím cơ Logitech G512 RGB GX Blue', 2150000, 30, 20, N'Switch Clicky, Full RGB đồng bộ hệ sinh thái G-hub.', 'https://hanoicomputercdn.com/media/product/54071_ban_phim_co_logitech_g512_lightsync_rgb_gx_blue_clicky_switch_0001_2.jpg'),
(5, 1, N'Bàn phím cơ ASUS ROG Strix Scope NX TKL', 2690000, 20, 9, N'ROG Exclusive NX Red Switch, Aura Sync RGB xịn xò.', 'https://nguyencongpc.vn/media/product/24781-asus-rog-strix-scope-nx-tkl-red-switch.jpg'),
(5, 1, N'Bàn phím cơ ASUS ROG Claymore II', 6490000, 5, 2, N'Bàn phím không dây Optical-Mechanical số tháo rời siêu độc.', 'https://product.hstatic.net/1000233206/product/h732__2__977c2b2c50f4419ca6fc19fc301dc08a.png'),
(5, 2, N'Bàn phím cơ Dell Alienware AW410K', 3290000, 8, 3, N'Switch Cherry MX Brown, đèn AlienFX RGB 16.8 triệu màu.', 'https://product.hstatic.net/200000350425/product/aw410k_-_1_5ab6445a86864e17bdfb692cf6f8332a_master_e877b311110c45cbb8cc7caeb94a2cb8.jpg'),

-- =================== CATEGORY 6: Chuột Gaming ===================
(6, 5, N'Chuột Logitech G PRO X SUPERLIGHT Wireless', 2990000, 30, 20, N'Màu đen, cảm biến HERO 25K, siêu nhẹ 63g. Vua chuột E-sport.', 'https://product.hstatic.net/200000722513/product/g-pro-x-superlight-wireless-black-666_83650815ce2e486f9108dbbb17c29159_1450bb4a9bd34dcb92fc77f627eb600d.jpg'),
(6, 5, N'Chuột Logitech G502 Hero', 990000, 100, 75, N'Chỉnh số cân nặng 11 phím lập trình, thiết kế công thái học đỉnh cao.', 'https://hanoicomputercdn.com/media/product/44370_mouse_logitech_g502_hero_gaming_usb_black_0003_1.jpg'),
(6, 5, N'Chuột Logitech G304 Wireless', 850000, 150, 120, N'Công nghệ Lightspeed, pin 250 giờ sử dụng chơi cực sướng không dây vướng víu.', 'https://product.hstatic.net/200000722513/product/gvn_log_g304_3df28cd60a48412b8fb1d2ff762dc6a9_1f12340f2e6b4b8892163de0a06676f2.png'),
(6, 5, N'Chuột Logitech G102 Lightsync RGB', 450000, 200, 180, N'Chuột quốc dân giá rẻ, LED RGB đẹp mắt.', 'https://hanoicomputercdn.com/media/product/53012_mouse_logitech_g102_lightsync_rgb_black_0000_1.jpg'),
(6, 1, N'Chuột ASUS ROG Gladius III', 1990000, 25, 12, N'Hot-swap đổi switch dễ dàng. DPI 26K vô địch.', 'https://hanoicomputercdn.com/media/product/59002_chuot_khong_day_asus_rog_gladius_iii_wireless_usb_rgb_den_0005_2.jpg'),
(6, 1, N'Chuột ASUS ROG Keris Wireless', 1890000, 20, 10, N'Form nhỏ gọn ôm tay, switch ROG Micro, Type-C sạc nhanh.', 'https://nguyencongpc.vn/media/product/22178-rog-keris-1.jpg'),
(6, 1, N'Chuột ASUS TUF Gaming M3', 590000, 50, 30, N'Đơn giản, độ bền cao với Aura Sync. Sensor 7000 DPI cực ổn định.', 'https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/2024_6_25_638549214267778050_asus-tuf-gaming-m3-gen-2-thumb.png'),
(6, 2, N'Chuột Dell Alienware AW610M', 2590000, 15, 6, N'Thiết kế trạm không gian siêu dị, pin 350 giờ.', 'https://bizweb.dktcdn.net/thumb/1024x1024/100/329/122/products/chuot-gaming-khong-day-dell-alienware-aw610m-70273594.png?v=1692600106923'),
(6, 3, N'Chuột Acer Predator Cestus 330', 1290000, 10, 4, N'16000 DPI, ôm sát tay cực chill cho tựa FPS / MOBA.', 'https://images-na.ssl-images-amazon.com/images/I/610g8x6E9-L.jpg'),
(6, 5, N'Chuột Logitech G403 Hero', 1050000, 40, 25, N'Thiết kế to bè thích hợp người dùng Palm Grip lớn.', 'https://hanoicomputercdn.com/media/product/48075_mouse_logitech_g403_hero_gaming_001.jpg');
GO

-- Thêm các hình ảnh mô tả phụ cho sản phẩm (Vào bảng product_images)
INSERT INTO product_images(product_id, image_url, is_primary)
VALUES
(1, 'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=800&q=80', 0),
(1, 'https://images.unsplash.com/photo-1611078174522-8610afcc2fb8?w=800&q=80', 0),
(2, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80', 0),
(3, 'https://images.unsplash.com/photo-1515524738708-327c5b6b801f?w=800&q=80', 0),
(5, 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=800&q=80', 0),
(6, 'https://images.unsplash.com/photo-1615663245857-ac1e99b79830?w=800&q=80', 0);
GO
INSERT INTO coupons (code, discount_percent, min_order_value, start_date, end_date, usage_limit, used_count)
VALUES 
('PROMO20', 20.0, 500000.0, GETDATE(), DATEADD(month, 1, GETDATE()), 50, 0),
('SALE10', 10.0, 500000.0, GETDATE(), DATEADD(month, 1, GETDATE()), 50, 0);
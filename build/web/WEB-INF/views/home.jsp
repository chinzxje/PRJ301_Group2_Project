<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="java.util.List" %>
        <%@page import="model.Product" %>
            <%@page import="model.User" %>
                <% List<Product> products = (List<Product>) request.getAttribute("products");
                        int currentPage = (Integer) request.getAttribute("page");
                        int totalPages = (Integer) request.getAttribute("totalPages");
                        String q = (String) request.getAttribute("q");
                        String min = (String) request.getAttribute("min");
                        String max = (String) request.getAttribute("max");
                        User currentUser = (User) session.getAttribute("user");
                        %>
                        <!DOCTYPE html>
                        <html>

                        <head>
                            <meta charset="UTF-8">
                            <title>Trang chủ - Computer Shop</title>
                            <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
                        </head>

                        <body>
                            <div class="container">
                                <header class="shop-header">
                                    <div class="header-top center-stack">
                                        <div class="shop-logo">ComputerShop</div>
                                        <div class="shop-subtitle">Thiết bị máy tính cho học tập và làm việc</div>
                                    </div>
                                    <nav class="header-menu center-menu">
                                        <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
                                        <a href="home?q=laptop">Laptop</a>
                                        <a href="home?q=pc">PC Gaming</a>
                                        <a href="home?q=man+hinh">Màn hình</a>
                                        <a href="home?q=ban+phim,chuot">Phụ kiện</a>
                                        <% if (currentUser !=null && "ADMIN" .equalsIgnoreCase(currentUser.getRole())) {
                                            %>
                                            <a href="<%=request.getContextPath()%>/admin/products">Quản lý sản phẩm</a>
                                            <a href="<%=request.getContextPath()%>/admin/report">Báo cáo</a>
                                            <% } %>
                                    </nav>
                                    <div class="header-user center-menu">
                                        <a href="<%=request.getContextPath()%>/cart">Giỏ hàng</a>
                                        <% if (currentUser==null) { %>
                                            <a href="<%=request.getContextPath()%>/login">Đăng nhập</a>
                                            <a href="<%=request.getContextPath()%>/register">Đăng ký</a>
                                            <span class="avatar-icon">?</span>
                                            <% } else { %>
                                                <span>Xin chào <b>
                                                        <%=currentUser.getFullName()%>
                                                    </b></span>
                                                <a href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
                                                <span class="avatar-icon">
                                                    <%=currentUser.getFullName().substring(0,1).toUpperCase()%>
                                                </span>
                                                <% } %>
                                    </div>
                                </header>

                                <div class="filter-bar">
                                    <form method="get" action="home" class="search-form center-menu">
                                        <input type="text" name="q" value="<%=q%>" placeholder="Từ khóa">
                                        <input type="number" name="min" value="<%=min%>" placeholder="Giá min">
                                        <input type="number" name="max" value="<%=max%>" placeholder="Giá max">
                                        <button type="submit">Lọc</button>
                                    </form>
                                </div>

                                <h3>Danh sách sản phẩm nổi bật 🔥</h3>
                                <% if (products.isEmpty()) { %>
                                    <p>Không có dữ liệu.</p>
                                    <% } %>
                                        <div class="product-grid">
                                            <% for (Product p : products) { %>
                                                <div class="product-card">
                                                    <% String imgSrc=(p.getImageUrl()==null ||
                                                        p.getImageUrl().trim().isEmpty())
                                                        ? "https://picsum.photos/seed/default-computer/480/300" :
                                                        p.getImageUrl(); %>
                                                        <img src="<%=imgSrc%>" alt="<%=p.getName()%>" loading="lazy"
                                                            decoding="async">
                                                        <div class="product-body">
                                                            <p class="product-title">
                                                                <%=p.getName()%>
                                                            </p>
                                                            <p class="product-meta">
                                                                <%=p.getBrand()%> | Đã bán: <%=p.getSold()%>
                                                            </p>
                                                            <p class="product-price">
                                                                <%=String.format("%,.0f", p.getPrice())%> đ
                                                            </p>
                                                            <% String stockClass=p.getStock() <=0 ? "out-of-stock" : ""
                                                                ; %>
                                                                <% String stockLabel=p.getStock() <=0 ? "Hết hàng"
                                                                    : "Còn lại: " + p.getStock(); %>
                                                                    <p class="product-stock <%=stockClass%>">
                                                                        <%=stockLabel%>
                                                                    </p>
                                                                    <div class="product-actions">
                                                                        <a href="product?id=<%=p.getId()%>">Chi tiết</a>
                                                                        <% if (p.getStock()> 0) { %>
                                                                            <form method="post" action="cart/add">
                                                                                <input type="hidden" name="productId"
                                                                                    value="<%=p.getId()%>">
                                                                                <input type="number" name="quantity"
                                                                                    value="1" min="1"
                                                                                    max="<%=p.getStock()%>">
                                                                                <button type="submit">Thêm giỏ</button>
                                                                            </form>
                                                                            <% } else { %>
                                                                                <span class="btn-out-of-stock">Hết
                                                                                    hàng</span>
                                                                                <% } %>
                                                                    </div>
                                                        </div>
                                                </div>
                                                <% } %>
                                        </div>

                                        <p>
                                            Trang:
                                            <% for (int i=1; i <=totalPages; i++) { %>
                                                <% if (i==currentPage) { %>
                                                    <b>
                                                        <%=i%>
                                                    </b>
                                                    <% } else { %>
                                                        <a href="home?page=<%=i%>&q=<%=q%>&min=<%=min%>&max=<%=max%>">
                                                            <%=i%>
                                                        </a>
                                                        <% } %>
                                                            <% } %>
                                        </p>
                            </div>
                        </body>

                        </html>
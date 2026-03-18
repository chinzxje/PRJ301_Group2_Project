<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="java.util.List" %>
<%@page import="model.Product" %>
<%@page import="model.User" %>
<%@page import="model.Category" %>
<%@page import="model.Brand" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    int currentPage = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("totalPages");
    String q = (String) request.getAttribute("q");
    String min = (String) request.getAttribute("min");
    String max = (String) request.getAttribute("max");
    String categoryIdStr = (String) request.getAttribute("categoryId");
    String brandIdStr = (String) request.getAttribute("brandId");
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html>

                        <head>
                            <meta charset="UTF-8">
                            <title>Trang chủ - Computer Shop</title>
                            <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css?v=2">
                        </head>

                        <body>
                            <div class="container">
                                <header class="shop-header">

                                   <div class="header-top">

                                       <div class="center-stack">
                                           <div class="shop-logo">ComputerShop</div>
                                           <div class="shop-subtitle">
                                               Thiết bị máy tính cho học tập và làm việc
                                           </div>
                                       </div>

                                       <div class="header-user">
                                           <a href="<%=request.getContextPath()%>/cart">Giỏ hàng</a>

                                           <% if (currentUser==null) { %>
                                               <a href="<%=request.getContextPath()%>/login">Đăng nhập</a>
                                               <a href="<%=request.getContextPath()%>/register">Đăng ký</a>
                                               <span class="avatar-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#0f4c81"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg></span>
                                           <% } else { %>
                                               <span>Xin chào <b><%=currentUser.getFullName()%></b></span>
                                               <a href="<%=request.getContextPath()%>/profile/wishlists">Yêu thích</a>
                                               <a href="<%=request.getContextPath()%>/profile/orders">Đơn hàng</a>
                                               <a href="<%=request.getContextPath()%>/profile/addresses">Địa chỉ</a>
                                               <a href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
                                               <span class="avatar-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#0f4c81"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg></span>
                                           <% } %>
                                       </div>

                                   </div>

                                   <nav class="header-menu center-menu">
                                       <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
                                       <% if(categories != null) { for(Category c : categories) { %>
                                           <a href="home?categoryId=<%=c.getId()%>"><%=c.getName()%></a>
                                       <% }} %>

                                       <% if (currentUser != null && "ADMIN".equalsIgnoreCase(currentUser.getRole())) { %>
                                           <a href="<%=request.getContextPath()%>/admin/products">Quản lý</a>
                                           <a href="<%=request.getContextPath()%>/admin/report">Báo cáo</a>
                                       <% } %>
                                   </nav>

                               </header>
                               
                               <div class="brand-slider" style="display: flex; gap: 30px; justify-content: center; flex-wrap: wrap; padding: 25px 0; margin-bottom: 20px;">
                                   <% if(brands != null) { for(Brand b : brands) { %>
                                       <a href="home?brandId=<%=b.getId()%>" style="display: flex; flex-direction: column; align-items: center; text-decoration: none; color: #333; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
                                           <div style="width: 90px; height: 90px; border-radius: 50%; border: 1px solid #eaeaea; display: flex; align-items: center; justify-content: center; background: #fff; box-shadow: 0 4px 10px rgba(0,0,0,0.06); overflow: hidden; padding: 10px;">
                                               <img src="<%=b.getLogoUrl() != null && !b.getLogoUrl().trim().isEmpty() ? b.getLogoUrl() : "https://picsum.photos/seed/brand/100"%>" alt="<%=b.getName()%>" style="max-width: 100%; max-height: 100%; object-fit: contain;" loading="lazy">
                                           </div>
                                           <span style="font-weight: 600; margin-top: 10px; font-size: 13px;"><%=b.getName()%></span>
                                       </a>
                                   <% }} %>
                               </div>
                                
                                <div class="filter-bar">
                                    <form method="get" action="home" class="search-form center-menu">
                                        <input type="text" name="q" value="<%=q != null ? q : ""%>" placeholder="Từ khóa">
                                        
                                        <select name="categoryId">
                                            <option value="">-- Danh mục --</option>
                                            <% if(categories != null) { for(Category c : categories) { %>
                                                <option value="<%=c.getId()%>" <%= (categoryIdStr != null && categoryIdStr.equals(String.valueOf(c.getId()))) ? "selected" : "" %>><%=c.getName()%></option>
                                            <% }} %>
                                        </select>

                                        <select name="brandId">
                                            <option value="">-- Thương hiệu --</option>
                                            <% if(brands != null) { for(Brand b : brands) { %>
                                                <option value="<%=b.getId()%>" <%= (brandIdStr != null && brandIdStr.equals(String.valueOf(b.getId()))) ? "selected" : "" %>><%=b.getName()%></option>
                                            <% }} %>
                                        </select>

                                        <input type="number" name="min" value="<%=min != null ? min : ""%>" placeholder="Giá min" style="width:100px;">
                                        <input type="number" name="max" value="<%=max != null ? max : ""%>" placeholder="Giá max" style="width:100px;">
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
                                                                <%= (p.getBrand() != null) ? p.getBrand().getName() : "No Brand" %> | Đã bán: <%=p.getSold()%>
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
                                                    <b><%=i%></b>
                                                <% } else { %>
                                                    <a href="home?page=<%=i%>&q=<%=q != null ? q : ""%>&min=<%=min != null ? min : ""%>&max=<%=max != null ? max : ""%>&categoryId=<%=categoryIdStr != null ? categoryIdStr : ""%>&brandId=<%=brandIdStr != null ? brandIdStr : ""%>"><%=i%></a>
                                                <% } %>
                                            <% } %>
                                        </p>
                            </div>
                        </body>

                        </html>
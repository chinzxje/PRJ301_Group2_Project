<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Wishlist"%>
<%@page import="model.User"%>
<%
    User currentUser = (User) session.getAttribute("user");
    List<Wishlist> wishlists = (List<Wishlist>) request.getAttribute("wishlists");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sản phẩm yêu thích</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-topbar">
        <div class="menu-left">
            <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
            <a href="<%=request.getContextPath()%>/profile/addresses">Sổ địa chỉ</a>
            <a href="<%=request.getContextPath()%>/profile/orders">Đơn hàng của tôi</a>
            <a href="<%=request.getContextPath()%>/profile/wishlists">Yêu thích</a>
        </div>
        <div class="menu-right">
            <span>Xin chào <b><%= currentUser.getFullName() %></b></span>
            <a class="icon-link" href="<%=request.getContextPath()%>/cart">🛒 Giỏ hàng</a>
            <a class="icon-link" href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
        </div>
    </div>

    <h2>Sản Phẩm Yêu Thích 💖</h2>
    <hr>
    
    <% if (wishlists != null && !wishlists.isEmpty()) { %>
        <div class="product-grid">
            <% for(Wishlist w : wishlists) { %>
                <div class="product-card">
                    <% String imgSrc=(w.getProduct().getImageUrl()==null || w.getProduct().getImageUrl().trim().isEmpty()) ? "https://picsum.photos/seed/default-computer/480/300" : w.getProduct().getImageUrl(); %>
                    <img src="<%=imgSrc%>" alt="<%=w.getProduct().getName()%>" loading="lazy" decoding="async">
                    <div class="product-body">
                        <p class="product-title">
                            <%=w.getProduct().getName()%>
                        </p>
                        <p class="product-price">
                            <%=String.format("%,.0f", w.getProduct().getPrice())%> đ
                        </p>
                        <div class="product-actions">
                            <a href="<%=request.getContextPath()%>/product?id=<%=w.getProductId()%>">Xem chi tiết</a>
                            <a href="<%=request.getContextPath()%>/wishlist/toggle?productId=<%=w.getProductId()%>" style="color: #e74c3c; font-size: 20px; text-decoration: none;" title="Bỏ yêu thích">❤️</a>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    <% } else { %>
        <p>Bạn chưa thêm sản phẩm nào vào danh sách yêu thích.</p>
    <% } %>
</div>
</body>
</html>

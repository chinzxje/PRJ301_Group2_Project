<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.CartItem"%>
<%
    List<CartItem> items = (List<CartItem>) request.getAttribute("items");
    double total = (Double) request.getAttribute("total");
    String checkoutMessage = (String) session.getAttribute("checkoutMessage");
    if (checkoutMessage != null) {
        session.removeAttribute("checkoutMessage");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Giỏ hàng</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
<div class="page-topbar">
    <div class="menu-left">
        <a href="home">Trang chủ</a>
        <a href="product?id=1">Sản phẩm</a>
    </div>
    <div class="menu-right">
        <a class="icon-link" href="login">👤 Tài khoản</a>
        <a class="icon-link" href="cart">🛒 Giỏ hàng</a>
    </div>
</div>

<h2>Giỏ hàng</h2>

<% if (checkoutMessage != null) { %>
<p class="msg-success"><b><%=checkoutMessage%></b></p>
<% } %>

<table border="1" cellpadding="6" cellspacing="0">
    <tr>
        <th>Ảnh</th>
        <th>Sản phẩm</th>
        <th>Giá</th>
        <th>Số lượng</th>
        <th>Thành tiền</th>
        <th>Thao tác</th>
    </tr>
    <% if (items.isEmpty()) { %>
    <tr><td colspan="6">Giỏ hàng rỗng.</td></tr>
    <% } %>
    <% for (CartItem item : items) { %>
    <tr>
        <td><img class="cart-thumb" src="<%=item.getProduct().getImageUrl() == null || item.getProduct().getImageUrl().trim().isEmpty() ? "https://picsum.photos/seed/default-cart/200/120" : item.getProduct().getImageUrl()%>" alt="<%=item.getProduct().getName()%>" loading="lazy" decoding="async"></td>
        <td><%=item.getProduct().getName()%></td>
        <td><%=String.format("%,.0f", item.getProduct().getPrice())%></td>
        <td>
            <form method="post" action="cart" style="display:inline;">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="productId" value="<%=item.getProduct().getId()%>">
                <input type="number" name="quantity" value="<%=item.getQuantity()%>" min="1" max="<%=Math.max(1, item.getProduct().getStock())%>">
                <button type="submit">Cập nhật</button>
            </form>
        </td>
        <td><%=String.format("%,.0f", item.getLineTotal())%></td>
        <td>
            <form method="post" action="cart" style="display:inline;">
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="productId" value="<%=item.getProduct().getId()%>">
                <button type="submit">Xóa</button>
            </form>
        </td>
    </tr>
    <% } %>
    <tr>
        <td colspan="4" align="right"><b>Tổng tiền</b></td>
        <td colspan="2"><b><%=String.format("%,.0f", total)%></b></td>
    </tr>
</table>

<br>
<form method="post" action="cart" style="display:inline;">
    <input type="hidden" name="action" value="clear">
    <button type="submit">Xóa tất cả</button>
</form>

<form method="post" action="checkout" style="display:inline; margin-left: 10px;">
    <button type="submit">Đặt hàng</button>
</form>
</div>
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.CartItem"%>
<%@page import="model.Address"%>
<%
    List<CartItem> items = (List<CartItem>) request.getAttribute("items");
    List<Address> addresses = (List<Address>) request.getAttribute("addresses");
    double total = (Double) request.getAttribute("total");
    Double discountAmountObj = (Double) request.getAttribute("discountAmount");
    double discountAmount = (discountAmountObj != null) ? discountAmountObj : 0;
    Double finalTotalObj = (Double) request.getAttribute("finalTotal");
    double finalTotal = (finalTotalObj != null) ? finalTotalObj : total;

    String couponMessage = (String) request.getAttribute("couponMessage");
    String couponError = (String) request.getAttribute("couponError");
    
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

<% if (couponMessage != null) { %>
<p style="color: green;"><b><%=couponMessage%></b></p>
<% } %>
<% if (couponError != null) { %>
<p style="color: red;"><b><%=couponError%></b></p>
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
<div class="cart-footer" style="display: grid; grid-template-columns: 1fr 350px; gap: 30px; margin-top: 30px;">
    <div class="footer-left">
        <form method="post" action="cart" style="margin-bottom: 20px;">
            <input type="hidden" name="action" value="clear">
            <button type="submit" style="background:#94a3b8; border:none;">Xóa tất cả giỏ hàng</button>
        </form>

        <div class="voucher-container">
            <div class="voucher-title">
                <span>🎟️</span> Ưu đãi & Mã giảm giá
            </div>
            <form class="voucher-form" method="post" action="cart">
                <input type="hidden" name="action" value="applyCoupon">
                <input type="text" class="voucher-input" name="couponCode" placeholder="Nhập mã voucher tại đây..." 
                       value="<%= session.getAttribute("appliedCoupon") != null ? session.getAttribute("appliedCoupon") : "" %>">
                <button type="submit" class="btn-apply">Áp dụng</button>
            </form>
            
            <% if (session.getAttribute("appliedCoupon") != null) { %>
                <div class="voucher-applied">
                    <div>
                        <span class="voucher-tag">Đã áp dụng</span> 
                        <strong style="margin-left: 8px;"><%= session.getAttribute("appliedCoupon") %></strong>
                    </div>
                    <a href="cart?action=applyCoupon&couponCode=" class="btn-remove-voucher">Gỡ bỏ</a>
                </div>
            <% } %>
        </div>
    </div>

    <div class="footer-right">
        <div class="summary-card" style="padding: 20px; border: 1px solid #e2e8f0; border-radius: 12px; background: #fff;">
            <h3 style="margin-bottom: 15px; font-size: 18px; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">Tóm tắt đơn hàng</h3>
            
            <div class="total-breakdown">
                <div class="total-row">
                    <span>Tạm tính</span>
                    <span><%=String.format("%,.0f", total)%>đ</span>
                </div>
                <% if (discountAmount > 0) { %>
                <div class="total-row discount">
                    <span>Giảm giá</span>
                    <span>-<%=String.format("%,.0f", discountAmount)%>đ</span>
                </div>
                <% } %>
                <div class="total-row grand-total">
                    <span>Tổng cộng</span>
                    <span><%=String.format("%,.0f", finalTotal)%>đ</span>
                </div>
            </div>

            <form method="post" action="checkout" style="margin-top: 25px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px;">Địa chỉ giao hàng</label>
                <select name="addressId" required style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 15px;">
                    <option value="">-- Chọn địa chỉ --</option>
                    <% if (addresses != null) { for(Address addr : addresses) { %>
                        <option value="<%=addr.getId()%>" <%=addr.isDefault() ? "selected" : ""%>>
                            <%=addr.getReceiverName()%> (<%=addr.getAddressDetail()%>)
                        </option>
                    <% }} %>
                </select>
                
                <label style="display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px;">Thanh toán</label>
                <select name="paymentMethod" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 20px;">
                    <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                    <option value="VNPay">Chuyển khoản VNPay</option>
                    <option value="Momo">Ví điện tử Momo</option>
                </select>
                
                <button type="submit" style="width: 100%; background:#27ae60; color:white; padding: 14px; border:none; border-radius:8px; font-size: 16px; font-weight:700; cursor:pointer; box-shadow: 0 4px 14px rgba(39, 174, 96, 0.3);">
                    ĐẶT HÀNG NGAY
                </button>
            </form>
            <div style="text-align: center; margin-top: 15px;">
                <small><a href="<%=request.getContextPath()%>/profile/addresses" style="color: #64748b;">Quản lý sổ địa chỉ</a></small>
            </div>
        </div>
    </div>
</div>
</div>
</body>
</html>

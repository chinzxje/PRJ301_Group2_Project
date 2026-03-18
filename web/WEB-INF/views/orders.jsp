<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Order"%>
<%@page import="model.User"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    User currentUser = (User) session.getAttribute("user");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lịch sử đơn hàng</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-topbar">
        <div class="menu-left">
            <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
            <a href="<%=request.getContextPath()%>/profile/addresses">Sổ địa chỉ</a>
            <a href="<%=request.getContextPath()%>/profile/orders">Đơn hàng của tôi</a>
        </div>
        <div class="menu-right">
            <span>Xin chào <b><%= currentUser.getFullName() %></b></span>
            <a class="icon-link" href="<%=request.getContextPath()%>/cart">🛒 Giỏ hàng</a>
            <a class="icon-link" href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
        </div>
    </div>

    <h2>Lịch sử Đơn Hàng</h2>
    <hr>
    
    <% if (orders != null && !orders.isEmpty()) { %>
        <table border="1" cellpadding="8" cellspacing="0" style="width: 100%;">
            <tr style="background:#f2f2f2;">
                <th>Mã ĐH</th>
                <th>Ngày đặt</th>
                <th>Tổng tiền</th>
                <th>Trạng thái</th>
                <th>Thông tin giao hàng</th>
            </tr>
            <% for(Order order : orders) { %>
                <tr>
                    <td style="text-align:center;"><b>#<%= order.getId() %></b></td>
                    <td style="text-align:center;"><%= (order.getCreatedAt() != null) ? sdf.format(order.getCreatedAt()) : "" %></td>
                    <td style="text-align:right;">
                        <span style="font-weight:bold; color:#e74c3c;"><%= String.format("%,.0f", order.getTotalAmount()) %> đ</span>
                        <% if(order.getCoupon() != null) { %>
                            <div style="font-size: 11px; color: #27ae60; margin-top: 4px;">
                                <span style="background: #eefdf3; padding: 2px 5px; border-radius: 4px; border: 1px solid #bbf7d0;">
                                    🎟️ <%= order.getCoupon().getCode() %>
                                </span>
                            </div>
                        <% } %>
                    </td>
                    <td style="text-align:center;">
                        <span style="padding: 4px 8px; border-radius: 3px; font-weight:bold; 
                            <%= "Pending".equals(order.getStatus()) ? "background: #f1c40f; color:#fff;" : 
                               ("Completed".equals(order.getStatus()) ? "background: #2ecc71; color:#fff;" : "background: #e74c3c; color:#fff;") %>">
                            <%= order.getStatus() %>
                        </span>
                    </td>
                    <td>
                        <% if(order.getAddress() != null) { %>
                            <b><%= order.getAddress().getReceiverName() %></b> - <%= order.getAddress().getPhoneNumber() %><br>
                            <%= order.getAddress().getAddressDetail() %>
                        <% } else { %>
                            <i>Khách chọn nhận tại cửa hàng</i>
                        <% } %>
                    </td>
                </tr>
            <% } %>
        </table>
    <% } else { %>
        <p>Bạn chưa có đơn đặt hàng nào.</p>
    <% } %>
</div>
</body>
</html>

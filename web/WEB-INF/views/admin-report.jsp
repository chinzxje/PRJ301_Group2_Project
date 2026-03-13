<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Product"%>
<%
    int totalProducts = (Integer) request.getAttribute("totalProducts");
    int totalSold = (Integer) request.getAttribute("totalSold");
    double totalRevenue = (Double) request.getAttribute("totalRevenue");
    List<Product> products = (List<Product>) request.getAttribute("products");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Báo cáo</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
<h2>Thống kê - Báo cáo</h2>
<p class="nav">
    <a href="<%=request.getContextPath()%>/home">Trang chủ</a> |
    <a href="<%=request.getContextPath()%>/admin/products">Quản lý sản phẩm</a>
</p>

<ul>
    <li>Tổng số sản phẩm: <b><%=totalProducts%></b></li>
    <li>Tổng số lượng đã bán: <b><%=totalSold%></b></li>
    <li>Tổng doanh thu (tạm tính): <b><%=String.format("%,.0f", totalRevenue)%></b></li>
</ul>

<h3>Chi tiết đã bán theo sản phẩm</h3>
<table border="1" cellpadding="6" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>Tên</th>
        <th>Giá</th>
        <th>Đã bán</th>
        <th>Doanh thu</th>
    </tr>
    <% for (Product p : products) { %>
    <tr>
        <td><%=p.getId()%></td>
        <td><%=p.getName()%></td>
        <td><%=String.format("%,.0f", p.getPrice())%></td>
        <td><%=p.getSold()%></td>
        <td><%=String.format("%,.0f", p.getSold() * p.getPrice())%></td>
    </tr>
    <% } %>
</table>
</div>
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Product"%>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    Product editProduct = (Product) request.getAttribute("editProduct");
    boolean editing = editProduct != null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Product</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
<h2>Quản lý sản phẩm (Admin)</h2>
<p class="nav">
    <a href="<%=request.getContextPath()%>/home">Trang chủ</a> |
    <a href="<%=request.getContextPath()%>/admin/report">Báo cáo</a>
</p>

<h3><%=editing ? "Sửa sản phẩm" : "Thêm mới sản phẩm"%></h3>
<form method="post" action="<%=request.getContextPath()%>/admin/products">
    <input type="hidden" name="id" value="<%=editing ? editProduct.getId() : 0%>">
    Tên: <input type="text" name="name" value="<%=editing ? editProduct.getName() : ""%>" required><br><br>
    Thương hiệu: <input type="text" name="brand" value="<%=editing ? editProduct.getBrand() : ""%>" required><br><br>
    Giá: <input type="number" name="price" value="<%=editing ? editProduct.getPrice() : 0%>" required><br><br>
    Tồn kho: <input type="number" name="stock" value="<%=editing ? editProduct.getStock() : 0%>" required><br><br>
    Đã bán: <input type="number" name="sold" value="<%=editing ? editProduct.getSold() : 0%>" required><br><br>
    Image URL: <input type="text" name="imageUrl" value="<%=editing ? editProduct.getImageUrl() : "https://picsum.photos/seed/new-computer/640/400"%>" size="60"><br><br>
    Mô tả: <input type="text" name="description" value="<%=editing ? editProduct.getDescription() : ""%>" size="60"><br><br>
    <button type="submit"><%=editing ? "Cập nhật" : "Thêm mới"%></button>
    <% if (editing) { %>
    <a href="<%=request.getContextPath()%>/admin/products">Hủy</a>
    <% } %>
</form>

<h3>Danh sách sản phẩm</h3>
<table border="1" cellpadding="6" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>Ảnh</th>
        <th>Tên</th>
        <th>Thương hiệu</th>
        <th>Giá</th>
        <th>Tồn kho</th>
        <th>Đã bán</th>
        <th>Hành động</th>
    </tr>
    <% for (Product p : products) { %>
    <tr>
        <td><%=p.getId()%></td>
        <td><img class="admin-thumb" src="<%=p.getImageUrl() == null || p.getImageUrl().trim().isEmpty() ? "https://picsum.photos/seed/admin-computer/160/100" : p.getImageUrl()%>" alt="<%=p.getName()%>" loading="lazy" decoding="async"></td>
        <td><%=p.getName()%></td>
        <td><%=p.getBrand()%></td>
        <td><%=String.format("%,.0f", p.getPrice())%></td>
        <td><%=p.getStock()%></td>
        <td><%=p.getSold()%></td>
        <td>
            <a href="<%=request.getContextPath()%>/admin/products?editId=<%=p.getId()%>">Sửa</a>
            <form method="post" action="<%=request.getContextPath()%>/admin/products" style="display:inline;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%=p.getId()%>">
                <button type="submit" onclick="return confirm('Xóa sản phẩm này?');">Xóa</button>
            </form>
        </td>
    </tr>
    <% } %>
</table>
</div>
</body>
</html>

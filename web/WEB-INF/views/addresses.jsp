<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Address"%>
<%@page import="model.User"%>
<%
    User currentUser = (User) session.getAttribute("user");
    List<Address> addresses = (List<Address>) request.getAttribute("addresses");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sổ địa chỉ</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-topbar">
        <div class="menu-left">
            <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
            <a href="<%=request.getContextPath()%>/profile/addresses">Sổ địa chỉ</a>
        </div>
        <div class="menu-right">
            <span>Xin chào <b><%= currentUser.getFullName() %></b></span>
            <a class="icon-link" href="<%=request.getContextPath()%>/cart">🛒 Giỏ hàng</a>
            <a class="icon-link" href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
        </div>
    </div>

    <h2>Quản lý Sổ Địa Chỉ</h2>
    <hr>
    
    <div style="display: flex; gap: 20px;">
        <div style="flex: 2;">
            <h3>Danh sách địa chỉ của bạn</h3>
            <% if (addresses != null && !addresses.isEmpty()) { %>
                <table border="1" cellpadding="8" cellspacing="0" style="width: 100%;">
                    <tr>
                        <th>Người nhận</th>
                        <th>Điện thoại</th>
                        <th>Địa chỉ chi tiết</th>
                        <th>Mặc định</th>
                        <th>Thao tác</th>
                    </tr>
                    <% for(Address addr : addresses) { %>
                        <tr>
                            <td><%= addr.getReceiverName() %></td>
                            <td><%= addr.getPhoneNumber() %></td>
                            <td><%= addr.getAddressDetail() %></td>
                            <td style="text-align:center;">
                                <% if(addr.isDefault()) { %> 
                                    <span style="color: green; font-weight: bold;">✓ Default</span> 
                                <% } %>
                            </td>
                            <td>
                                <form method="post" action="<%=request.getContextPath()%>/profile/addresses" onsubmit="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= addr.getId() %>">
                                    <button type="submit" style="background:#e74c3c; color:white; padding: 4px 8px; border:none; border-radius:3px; cursor:pointer;">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </table>
            <% } else { %>
                <p>Bạn chưa thêm địa chỉ nào vào sổ.</p>
            <% } %>
        </div>
        
        <div style="flex: 1; padding: 20px; background: #f9f9f9; border: 1px solid #ddd; border-radius: 5px;">
            <h3>Thêm Địa Chỉ Mới</h3>
            <form method="post" action="<%=request.getContextPath()%>/profile/addresses">
                <input type="hidden" name="action" value="add">
                
                <div style="margin-bottom: 10px;">
                    <label style="display:block; margin-bottom:5px;">Họ tên người nhận:</label>
                    <input type="text" name="receiverName" required style="width:100%; padding:8px;">
                </div>
                
                <div style="margin-bottom: 10px;">
                    <label style="display:block; margin-bottom:5px;">Số điện thoại:</label>
                    <input type="text" name="phoneNumber" required style="width:100%; padding:8px;">
                </div>
                
                <div style="margin-bottom: 10px;">
                    <label style="display:block; margin-bottom:5px;">Địa chỉ chi tiết:</label>
                    <textarea name="addressDetail" required style="width:100%; padding:8px;" rows="3"></textarea>
                </div>
                
                <div style="margin-bottom: 15px;">
                    <label>
                        <input type="checkbox" name="isDefault" value="true"> Đặt làm địa chỉ mặc định
                    </label>
                </div>
                
                <button type="submit" style="background:#3498db; color:white; padding: 10px; width: 100%; border:none; border-radius:4px; font-weight:bold; cursor:pointer;">Thêm Địa Chỉ</button>
            </form>
        </div>
    </div>
</div>
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng ký</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
<div class="page-topbar">
    <div class="menu-left">
        <a href="home">Trang chủ</a>
        <a href="login">Đăng nhập</a>
    </div>
    <div class="menu-right">
        <a class="icon-link" href="login">👤 Tài khoản</a>
        <a class="icon-link" href="cart">🛒 Giỏ hàng</a>
    </div>
</div>

<div class="auth-box">
<h2>Đăng ký tài khoản</h2>

<% if (error != null) { %>
<p class="msg-error"><%=error%></p>
<% } %>

<form method="post" action="register">
    Họ tên: <input type="text" name="fullName" required><br><br>
    Email: <input type="email" name="email" required><br><br>
    Mật khẩu: <input type="password" name="password" required><br><br>
    <button type="submit">Đăng ký</button>
</form>

<p><a href="login">Đã có tài khoản? Đăng nhập</a></p>
</div>
</div>
</body>
</html>

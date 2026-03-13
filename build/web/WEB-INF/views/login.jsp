<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
    String registered = request.getParameter("registered");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
<div class="page-topbar">
    <div class="menu-left">
        <a href="home">Trang chủ</a>
        <a href="register">Đăng ký</a>
    </div>
    <div class="menu-right">
        <a class="icon-link" href="login">👤 Tài khoản</a>
        <a class="icon-link" href="cart">🛒 Giỏ hàng</a>
    </div>
</div>

<div class="auth-box">
<h2>Đăng nhập</h2>
<% if ("1".equals(registered)) { %>
<p class="msg-success">Đăng ký thành công. Mời bạn đăng nhập.</p>
<% } %>
<% if (error != null) { %>
<p class="msg-error"><%=error%></p>
<% } %>

<form method="post" action="login">
    Email: <input type="email" name="email" required><br><br>
    Mật khẩu: <input type="password" name="password" required><br><br>
    <button type="submit">Đăng nhập</button>
</form>

<p>
    <a href="register">Đăng ký</a> |
    <a href="forgot-password">Quên mật khẩu</a>
</p>

<hr>
<p>Account demo:</p>
<ul>
    <li>admin@gmail.com / 123</li>
    <li>user@gmail.com / 123</li>
</ul>
</div>
</div>
</body>
</html>

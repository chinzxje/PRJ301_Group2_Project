<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quên mật khẩu</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="container">
<h2>Quên mật khẩu (demo)</h2>
<p><a href="login">Quay lại đăng nhập</a></p>

<% if (error != null) { %>
<p class="msg-error"><%=error%></p>
<% } %>
<% if (message != null) { %>
<p class="msg-success"><%=message%></p>
<% } %>

<form method="post" action="forgot-password">
    Nhập email: <input type="email" name="email" required>
    <button type="submit">Tìm mật khẩu</button>
</form>
</div>
</body>
</html>

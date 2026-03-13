<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="model.Product" %>
        <% Product p=(Product) request.getAttribute("product"); %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Chi tiết sản phẩm</title>
                <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
            </head>

            <body>
                <div class="container">
                    <h2>Chi tiết sản phẩm</h2>
                    <p class="nav"><a href="home">Trang chủ</a> | <a href="cart">Giỏ hàng</a></p>

                    <img class="detail-image" src="<%=p.getImageUrl() == null || p.getImageUrl().trim().isEmpty() ? "
                        https://picsum.photos/seed/default-detail/900/500" : p.getImageUrl()%>" alt="<%=p.getName()%>"
                        loading="lazy" decoding="async">

                        <table border="1" cellpadding="6" cellspacing="0">
                            <tr>
                                <td>ID</td>
                                <td>
                                    <%=p.getId()%>
                                </td>
                            </tr>
                            <tr>
                                <td>Tên</td>
                                <td>
                                    <%=p.getName()%>
                                </td>
                            </tr>
                            <tr>
                                <td>Thương hiệu</td>
                                <td>
                                    <%=p.getBrand()%>
                                </td>
                            </tr>
                            <tr>
                                <td>Giá</td>
                                <td>
                                    <%=String.format("%,.0f", p.getPrice())%>
                                </td>
                            </tr>
                            <tr>
                                <td>Tồn kho</td>
                                <td>
                                    <%=p.getStock()%>
                                </td>
                            </tr>
                            <tr>
                                <td>Đã bán</td>
                                <td>
                                    <%=p.getSold()%>
                                </td>
                            </tr>
                            <tr>
                                <td>Mô tả</td>
                                <td>
                                    <%=p.getDescription()%>
                                </td>
                            </tr>
                        </table>

                        <h3>Thêm vào giỏ</h3>
                        <% if (p.getStock()> 0) { %>
                            <form method="post" action="cart/add">
                                <input type="hidden" name="productId" value="<%=p.getId()%>">
                                Số lượng: <input type="number" name="quantity" value="1" min="1"
                                    max="<%=p.getStock()%>">
                                <button type="submit">Thêm</button>
                            </form>
                            <% } else { %>
                                <p class="msg-error" style="font-weight:700; font-size:16px;">⚠️ Sản phẩm này đã hết
                                    hàng, không thể thêm vào giỏ.</p>
                                <% } %>
                </div>
            </body>

            </html>
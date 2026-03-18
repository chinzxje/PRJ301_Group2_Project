<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="model.Product" %>
<%@page import="model.Review" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<% 
    Product p = (Product) request.getAttribute("product"); 
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    Boolean inWishlist = (Boolean) request.getAttribute("inWishlist");
    if(inWishlist == null) inWishlist = false;
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if(successMsg != null) session.removeAttribute("successMsg");
    if(errorMsg != null) session.removeAttribute("errorMsg");
%>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Chi tiết sản phẩm</title>
                <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
            </head>

            <body>
                <div class="container">
                    <div style="display:flex; justify-content: space-between; align-items: center;">
                        <h2>Chi tiết sản phẩm</h2>
                        <% if(session.getAttribute("user") != null) { %>
                            <a href="<%=request.getContextPath()%>/wishlist/toggle?productId=<%=p.getId()%>" style="font-size: 24px; text-decoration: none; padding: 10px; border: 1px solid #ccc; border-radius: 5px; background: #fff;">
                                <%= inWishlist ? "❤️ Đã lưu" : "🤍 Lưu yêu thích" %>
                            </a>
                        <% } else { %>
                            <a href="<%=request.getContextPath()%>/login" style="font-size: 14px; text-decoration: none; padding: 10px; border: 1px solid #ccc; border-radius: 5px; background: #fff; color: #666;">
                                🤍 Đăng nhập để lưu YT
                            </a>
                        <% } %>
                    </div>
                    
                    <% if(successMsg != null) { %><p style="color: green; font-weight: bold;"><%=successMsg%></p><% } %>
                    <% if(errorMsg != null) { %><p style="color: red; font-weight: bold;"><%=errorMsg%></p><% } %>

                    <p class="nav">
                        <a href="<%=request.getContextPath()%>/home">Trang chủ</a> | 
                        <a href="<%=request.getContextPath()%>/cart">Giỏ hàng</a>
                        <% if(session.getAttribute("user") != null) { %>
                            | <a href="<%=request.getContextPath()%>/profile/wishlists">Yêu thích</a>
                            | <a href="<%=request.getContextPath()%>/profile/orders">Đơn hàng</a>
                            | <a href="<%=request.getContextPath()%>/profile/addresses">Địa chỉ</a>
                        <% } %>
                    </p>

                    <img class="detail-image" src="<%=p.getImageUrl() == null || p.getImageUrl().trim().isEmpty() ? "https://picsum.photos/seed/default-detail/900/500" : p.getImageUrl()%>" alt="<%=p.getName()%>" loading="lazy" decoding="async">

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
                                <td>Danh mục</td>
                                <td>
                                    <%= (p.getCategory() != null) ? p.getCategory().getName() : "N/A" %>
                                </td>
                            </tr>
                            <tr>
                                <td>Thương hiệu</td>
                                <td>
                                    <%= (p.getBrand() != null) ? p.getBrand().getName() : "N/A" %>
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
                            <form method="post" action="<%=request.getContextPath()%>/cart/add">
                                <input type="hidden" name="productId" value="<%=p.getId()%>">
                                Số lượng: <input type="number" name="quantity" value="1" min="1"
                                    max="<%=p.getStock()%>">
                                <button type="submit">Thêm</button>
                            </form>
                            <% } else { %>
                                <p class="msg-error" style="font-weight:700; font-size:16px;">⚠️ Sản phẩm này đã hết
                                    hàng, không thể thêm vào giỏ.</p>
                                <% } %>

                    <hr style="margin-top: 40px; margin-bottom: 20px;">
                    
                    <div class="reviews-section" style="background: #fdfdfd; padding: 20px; border: 1px solid #eee; border-radius: 8px;">
                        <h3>Đánh giá sản phẩm (<%= reviews != null ? reviews.size() : 0 %>)</h3>
                        
                        <% if(session.getAttribute("user") != null) { %>
                            <div style="margin-bottom: 30px; padding: 15px; background: #eef2f5; border-radius: 5px;">
                                <h4>Viết đánh giá của bạn</h4>
                                <form method="post" action="<%=request.getContextPath()%>/review/add">
                                    <input type="hidden" name="productId" value="<%=p.getId()%>">
                                    
                                    <div style="margin-bottom: 10px;">
                                        <label>Chất lượng (1-5 sao):</label>
                                        <select name="rating" required>
                                            <option value="5">⭐⭐⭐⭐⭐ (5) Tuyệt vời</option>
                                            <option value="4">⭐⭐⭐⭐ (4) Tốt</option>
                                            <option value="3">⭐⭐⭐ (3) Bình thường</option>
                                            <option value="2">⭐⭐ (2) Kém</option>
                                            <option value="1">⭐ (1) Quá tệ</option>
                                        </select>
                                    </div>
                                    
                                    <div style="margin-bottom: 10px;">
                                        <label style="display:block; margin-bottom: 5px;">Bình luận:</label>
                                        <textarea name="comment" rows="3" style="width: 100%; padding: 8px;" required placeholder="Chia sẻ cảm nhận của bạn về sản phẩm này..."></textarea>
                                    </div>
                                    
                                    <button type="submit" style="background: #3498db; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">Gửi đánh giá</button>
                                </form>
                            </div>
                        <% } else { %>
                            <p style="font-style: italic; color: #666;"><a href="<%=request.getContextPath()%>/login">Đăng nhập</a> để viết đánh giá cho sản phẩm này.</p>
                        <% } %>

                        <div class="review-list">
                            <% if (reviews != null && !reviews.isEmpty()) { 
                                for(Review r : reviews) {
                            %>
                                <div style="border-bottom: 1px solid #ddd; padding-bottom: 15px; margin-bottom: 15px;">
                                    <h4 style="margin: 0 0 5px 0;">
                                        <%= r.getUser() != null ? r.getUser().getFullName() : r.getUserEmail() %>
                                        <span style="color: #f39c12; font-size: 14px;">
                                            <% for(int i=0; i<r.getRating(); i++) { %>⭐<% } %>
                                        </span>
                                    </h4>
                                    <small style="color: #999;"><%= (r.getCreatedAt() != null) ? sdf.format(r.getCreatedAt()) : "" %></small>
                                    <p style="margin-top: 5px; color: #333;"><%= r.getComment() %></p>
                                </div>
                            <%  } 
                               } else { %>
                                <p>Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá sản phẩm này!</p>
                            <% } %>
                        </div>
                    </div>

                </div>
            </body>

            </html>
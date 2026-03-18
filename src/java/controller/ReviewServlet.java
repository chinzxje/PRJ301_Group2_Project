package controller;

import java.io.IOException;
import java.sql.Connection;
import utils.ReviewUtils;
import utils.DBUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Review;
import model.User;

@WebServlet(urlPatterns = {"/review/add"})
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        String productIdStr = request.getParameter("productId");
        
        if (user == null) {
            session.setAttribute("errorMsg", "Bạn cần đăng nhập để đánh giá sản phẩm.");
            response.sendRedirect(request.getContextPath() + "/product?id=" + productIdStr);
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            
            if(rating < 1 || rating > 5) {
                throw new IllegalArgumentException("Rating must be between 1 and 5");
            }

            try (Connection conn = DBUtils.getConnection()) {
                Review r = new Review();
                r.setUserEmail(user.getEmail());
                r.setProductId(productId);
                r.setRating(rating);
                r.setComment(comment);
                ReviewUtils.insertReview(conn, r);
            }
            
            session.setAttribute("successMsg", "Cảm ơn bạn đã đánh giá!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }

        // Redirect back to product detail page
        response.sendRedirect(request.getContextPath() + "/product?id=" + productIdStr);
    }
}

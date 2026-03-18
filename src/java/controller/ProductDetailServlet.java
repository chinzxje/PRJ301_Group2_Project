package controller;

import java.io.IOException;
import utils.ProductUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.util.List;
import model.Product;
import model.User;
import model.Review;
import utils.ReviewUtils;
import utils.WishlistUtils;
import utils.DBUtils;

@WebServlet(urlPatterns = {"/product"})
public class ProductDetailServlet extends HttpServlet {
    private final ProductUtils productUtils = new ProductUtils();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parseInt(request.getParameter("id"), -1);
        Product product = productUtils.getProductById(id);
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        request.setAttribute("product", product);
        
        try (Connection conn = DBUtils.getConnection()) {
            List<Review> reviews = ReviewUtils.getReviewsByProduct(conn, id);
            request.setAttribute("reviews", reviews);
            
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            boolean inWishlist = false;
            if(user != null) {
                inWishlist = WishlistUtils.checkInWishlist(conn, user.getEmail(), id);
            }
            request.setAttribute("inWishlist", inWishlist);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/WEB-INF/views/product-detail.jsp").forward(request, response);
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}

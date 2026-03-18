package controller;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import utils.WishlistUtils;
import utils.DBUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Wishlist;
import model.User;

@WebServlet(urlPatterns = {"/profile/wishlists", "/wishlist/toggle"})
public class WishlistServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/wishlist/toggle".equals(servletPath)) {
            toggleWishlist(request, response);
            return;
        }

        // Handle /profile/wishlists
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try (Connection conn = DBUtils.getConnection()) {
            List<Wishlist> wishlists = WishlistUtils.getWishlistByUser(conn, user.getEmail());
            request.setAttribute("wishlists", wishlists);
            request.getRequestDispatcher("/WEB-INF/views/wishlists.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi lấy danh sách yêu thích");
        }
    }

    private void toggleWishlist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String productIdStr = request.getParameter("productId");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            try (Connection conn = DBUtils.getConnection()) {
                WishlistUtils.toggleWishlist(conn, user.getEmail(), productId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        String referer = request.getHeader("Referer");
        if(referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/product?id=" + productIdStr);
        }
    }
}

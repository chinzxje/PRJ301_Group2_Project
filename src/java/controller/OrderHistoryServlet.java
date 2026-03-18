package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import utils.DBUtils;
import utils.AddressUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.User;
import model.Address;

@WebServlet(urlPatterns = {"/profile/orders"})
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try (Connection conn = DBUtils.getConnection()) {
            List<Order> orders = getOrdersByUser(conn, user.getEmail());
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/WEB-INF/views/orders.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi truy xuất lịch sử đơn hàng");
        }
    }

    private List<Order> getOrdersByUser(Connection conn, String email) throws SQLException {
        String sql = "SELECT * FROM orders WHERE user_email = ? ORDER BY id DESC";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, email);
        ResultSet rs = pstm.executeQuery();
        List<Order> list = new ArrayList<>();
        while (rs.next()) {
            Order order = new Order();
            order.setId(rs.getInt("id"));
            order.setUserEmail(rs.getString("user_email"));
            order.setAddressId(rs.getInt("address_id"));
            order.setCouponId(rs.getInt("coupon_id"));
            order.setStatus(rs.getString("status"));
            order.setTotalAmount(rs.getDouble("total_amount"));
            order.setCreatedAt(rs.getTimestamp("created_at"));
            
            // Fetch associated address details
            if(order.getAddressId() > 0) {
                Address addr = AddressUtils.getAddressById(conn, order.getAddressId());
                order.setAddress(addr);
            }
            
            // Fetch associated coupon details
            if(order.getCouponId() > 0) {
                model.Coupon coupon = utils.CouponUtils.getCouponById(conn, order.getCouponId());
                order.setCoupon(coupon);
            }
            
            list.add(order);
        }
        return list;
    }
}

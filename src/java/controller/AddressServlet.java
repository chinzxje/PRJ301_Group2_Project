package controller;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import utils.AddressUtils;
import utils.DBUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Address;
import model.User;

@WebServlet(urlPatterns = {"/profile/addresses"})
public class AddressServlet extends HttpServlet {

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
            List<Address> addresses = AddressUtils.getAddressesByUser(conn, user.getEmail());
            request.setAttribute("addresses", addresses);
            request.getRequestDispatcher("/WEB-INF/views/addresses.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi lấy thông tin địa chỉ");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String receiverName = request.getParameter("receiverName");
        String phoneNumber = request.getParameter("phoneNumber");
        String addressDetail = request.getParameter("addressDetail");
        boolean isDefault = request.getParameter("isDefault") != null;

        try (Connection conn = DBUtils.getConnection()) {
            if ("add".equals(action)) {
                Address addr = new Address(0, user.getEmail(), receiverName, phoneNumber, addressDetail, isDefault);
                AddressUtils.insertAddress(conn, addr);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                AddressUtils.deleteAddress(conn, id, user.getEmail());
            }
            // Mở rộng thêm update nếu cần
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/profile/addresses");
    }
}

package controller;

import java.io.IOException;
import utils.ProductUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet(urlPatterns = {"/admin/report"})
public class AdminReportServlet extends HttpServlet {
    private final ProductUtils productUtils = new ProductUtils();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("totalProducts", productUtils.getTotalProducts());
        request.setAttribute("totalSold", productUtils.getTotalSold());
        request.setAttribute("totalRevenue", productUtils.getTotalRevenue());
        request.setAttribute("products", productUtils.getProducts());
        request.getRequestDispatcher("/WEB-INF/views/admin-report.jsp").forward(request, response);
    }

    private boolean isAdmin(HttpServletRequest request) {
        Object obj = request.getSession().getAttribute("user");
        if (!(obj instanceof User)) {
            return false;
        }
        User user = (User) obj;
        return "ADMIN".equalsIgnoreCase(user.getRole());
    }
}

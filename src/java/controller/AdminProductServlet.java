package controller;

import java.io.IOException;
import utils.ProductUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import model.User;

@WebServlet(urlPatterns = {"/admin/products"})
public class AdminProductServlet extends HttpServlet {
    private final ProductUtils productUtils = new ProductUtils();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int editId = parseInt(request.getParameter("editId"), -1);
        if (editId > 0) {
            request.setAttribute("editProduct", productUtils.getProductById(editId));
        }

        request.setAttribute("products", productUtils.getProducts());
        request.getRequestDispatcher("/WEB-INF/views/admin-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = parseInt(request.getParameter("id"), -1);
            productUtils.deleteProduct(id);
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        Product product = new Product();
        product.setId(parseInt(request.getParameter("id"), 0));
        product.setName(request.getParameter("name"));
        product.setBrand(request.getParameter("brand"));
        product.setPrice(parseDouble(request.getParameter("price"), 0));
        product.setStock(parseInt(request.getParameter("stock"), 0));
        product.setSold(parseInt(request.getParameter("sold"), 0));
        product.setDescription(request.getParameter("description"));
        product.setImageUrl(request.getParameter("imageUrl"));

        productUtils.saveProduct(product);
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }

    private boolean isAdmin(HttpServletRequest request) {
        Object obj = request.getSession().getAttribute("user");
        if (!(obj instanceof User)) {
            return false;
        }
        User user = (User) obj;
        return "ADMIN".equalsIgnoreCase(user.getRole());
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private double parseDouble(String value, double defaultValue) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}

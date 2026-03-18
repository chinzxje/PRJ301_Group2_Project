package controller;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import utils.ProductUtils;
import utils.CategoryUtils;
import utils.BrandUtils;
import utils.DBUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import model.Category;
import model.Brand;

@WebServlet(urlPatterns = {"/admin/products"})
public class AdminProductServlet extends HttpServlet {
    private final ProductUtils productUtils = new ProductUtils();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String editIdStr = request.getParameter("editId");
        if (editIdStr != null && !editIdStr.isEmpty()) {
            try {
                int editId = Integer.parseInt(editIdStr);
                Product editProduct = productUtils.getProductById(editId);
                request.setAttribute("editProduct", editProduct);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        try (Connection conn = DBUtils.getConnection()) {
            request.setAttribute("categories", CategoryUtils.getAllCategories(conn));
            request.setAttribute("brands", BrandUtils.getAllBrands(conn));
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("products", productUtils.getProducts());
        request.getRequestDispatcher("/WEB-INF/views/admin-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        int id = parseInt(request.getParameter("id"), 0);

        if ("delete".equals(action)) {
            productUtils.deleteProduct(id);
        } else {
            // Add or Update
            String name = request.getParameter("name");
            int categoryId = parseInt(request.getParameter("categoryId"), 0);
            int brandId = parseInt(request.getParameter("brandId"), 0);
            double price = parseDouble(request.getParameter("price"), 0.0);
            int stock = parseInt(request.getParameter("stock"), 0);
            int sold = parseInt(request.getParameter("sold"), 0);
            String description = request.getParameter("description");
            String imageUrl = request.getParameter("imageUrl");

            Product p = new Product(id, categoryId, brandId, name, price, stock, sold, description, imageUrl);
            productUtils.saveProduct(p);
        }

        response.sendRedirect(request.getContextPath() + "/admin/products");
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

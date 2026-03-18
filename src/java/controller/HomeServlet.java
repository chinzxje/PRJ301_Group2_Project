package controller;

import java.io.IOException;
import java.sql.Connection;
import java.util.Collections;
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

@WebServlet(urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    private final ProductUtils productUtils = new ProductUtils();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        Double minPrice = parseDouble(request.getParameter("min"));
        Double maxPrice = parseDouble(request.getParameter("max"));
        Integer categoryId = parseIntObj(request.getParameter("categoryId"));
        Integer brandId = parseIntObj(request.getParameter("brandId"));

        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = 10;
        
        // Fetch Categories and Brands to render the menus and filters
        try (Connection conn = DBUtils.getConnection()) {
            List<Category> categories = CategoryUtils.getAllCategories(conn);
            List<Brand> brands = BrandUtils.getAllBrands(conn);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<Product> filtered = productUtils.searchProducts(keyword, minPrice, maxPrice, categoryId, brandId);
        int totalItems = filtered.size();
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        totalPages = Math.max(totalPages, 1);
        page = Math.min(Math.max(page, 1), totalPages);

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalItems);
        List<Product> pageItems = totalItems == 0 ? Collections.emptyList() : filtered.subList(fromIndex, toIndex);

        request.setAttribute("products", pageItems);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("q", keyword == null ? "" : keyword);
        request.setAttribute("min", request.getParameter("min") == null ? "" : request.getParameter("min"));
        request.setAttribute("max", request.getParameter("max") == null ? "" : request.getParameter("max"));
        request.setAttribute("categoryId", request.getParameter("categoryId") == null ? "" : request.getParameter("categoryId"));
        request.setAttribute("brandId", request.getParameter("brandId") == null ? "" : request.getParameter("brandId"));

        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
    
    private Integer parseIntObj(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            return Integer.parseInt(value);
        } catch (Exception e) {
            return null;
        }
    }

    private Double parseDouble(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            return Double.parseDouble(value);
        } catch (Exception e) {
            return null;
        }
    }
}

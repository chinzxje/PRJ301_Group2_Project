package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import utils.ProductUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Product;
import model.User;

@WebServlet(urlPatterns = {"/cart", "/cart/add", "/checkout"})
public class CartServlet extends HttpServlet {
    private final ProductUtils productUtils = new ProductUtils();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<CartItem> items = buildCartItems(request.getSession());
        double total = 0;
        for (CartItem item : items) {
            total += item.getLineTotal();
        }

        request.setAttribute("items", items);
        request.setAttribute("total", total);
        request.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/cart/add".equals(servletPath)) {
            addToCart(request);
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if ("/checkout".equals(servletPath)) {
            processCheckout(request, response);
            return;
        }

        updateCart(request);
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void addToCart(HttpServletRequest request) {
        int productId = parseInt(request.getParameter("productId"), -1);
        int quantity = parseInt(request.getParameter("quantity"), 1);
        quantity = Math.max(1, quantity);

        Product product = productUtils.getProductById(productId);
        if (product == null) {
            return;
        }

        Map<Integer, Integer> cart = getCart(request.getSession());
        int currentQuantity = cart.getOrDefault(productId, 0);
        int newQuantity = Math.min(currentQuantity + quantity, product.getStock());
        if (newQuantity > 0) {
            cart.put(productId, newQuantity);
        }
    }

    private void updateCart(HttpServletRequest request) {
        Map<Integer, Integer> cart = getCart(request.getSession());
        String action = request.getParameter("action");
        int productId = parseInt(request.getParameter("productId"), -1);

        if ("remove".equals(action)) {
            cart.remove(productId);
            return;
        }

        if ("clear".equals(action)) {
            cart.clear();
            return;
        }

        if ("update".equals(action)) {
            int quantity = parseInt(request.getParameter("quantity"), 1);
            Product product = productUtils.getProductById(productId);
            if (product == null) {
                return;
            }
            quantity = Math.max(1, quantity);
            quantity = Math.min(quantity, product.getStock());
            cart.put(productId, quantity);
        }
    }

    private void processCheckout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<Integer, Integer> cart = getCart(session);
        User user = (User) session.getAttribute("user");
        String message = productUtils.checkout(cart, user.getEmail());
        if (message.startsWith("Đặt hàng thành công")) {
            cart.clear();
        }
        session.setAttribute("checkoutMessage", message);
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private List<CartItem> buildCartItems(HttpSession session) {
        Map<Integer, Integer> cart = getCart(session);
        List<CartItem> items = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            Product product = productUtils.getProductById(entry.getKey());
            if (product != null) {
                items.add(new CartItem(product, entry.getValue()));
            }
        }
        return items;
    }

    @SuppressWarnings("unchecked")
    private Map<Integer, Integer> getCart(HttpSession session) {
        Object obj = session.getAttribute("cart");
        if (obj instanceof Map) {
            return (Map<Integer, Integer>) obj;
        }
        Map<Integer, Integer> cart = new HashMap<>();
        session.setAttribute("cart", cart);
        return cart;
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}

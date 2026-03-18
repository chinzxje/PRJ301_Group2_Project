package controller;

import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.Connection;
import utils.ProductUtils;
import utils.AddressUtils;
import utils.DBUtils;
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

        HttpSession session = request.getSession();
        
        // Handle action from GET (e.g., cancel coupon)
        String action = request.getParameter("action");
        if ("applyCoupon".equals(action)) {
            String couponCode = request.getParameter("couponCode");
            if (couponCode == null || couponCode.trim().isEmpty()) {
                session.removeAttribute("appliedCoupon");
            }
        }
        
        // Handle coupon logic
        String appliedCouponCode = (String) session.getAttribute("appliedCoupon");
        double discountAmount = 0;
        model.Coupon appliedCoupon = null;
        if (appliedCouponCode != null) {
            appliedCoupon = utils.CouponUtils.getCouponByCode(appliedCouponCode);
            if (appliedCoupon != null) {
                if (total >= appliedCoupon.getMinOrderValue()) {
                    long now = System.currentTimeMillis();
                    if (now >= appliedCoupon.getStartDate().getTime() && now <= appliedCoupon.getEndDate().getTime()) {
                        if (appliedCoupon.getUsedCount() < appliedCoupon.getUsageLimit()) {
                            discountAmount = total * (appliedCoupon.getDiscountPercent() / 100.0);
                            request.setAttribute("couponMessage", "Áp dụng mã giảm giá thành công: -" + appliedCoupon.getDiscountPercent() + "%");
                            request.setAttribute("coupon", appliedCoupon);
                        } else {
                            request.setAttribute("couponError", "Mã giảm giá đã hết lượt sử dụng.");
                            session.removeAttribute("appliedCoupon");
                        }
                    } else {
                        request.setAttribute("couponError", "Mã giảm giá không trong thời gian có hiệu lực.");
                        session.removeAttribute("appliedCoupon");
                    }
                } else {
                    request.setAttribute("couponError", "Đơn hàng chưa đạt giá trị tối thiểu " + String.format("%,.0f", appliedCoupon.getMinOrderValue()) + "đ.");
                    session.removeAttribute("appliedCoupon");
                }
            } else {
                request.setAttribute("couponError", "Mã giảm giá không tồn tại.");
                session.removeAttribute("appliedCoupon");
            }
        }

        request.setAttribute("items", items);
        request.setAttribute("total", total);
        request.setAttribute("discountAmount", discountAmount);
        request.setAttribute("finalTotal", total - discountAmount);
        
        User user = (User) session.getAttribute("user");
        if(user != null) {
            try (Connection conn = DBUtils.getConnection()) {
                List<model.Address> addresses = AddressUtils.getAddressesByUser(conn, user.getEmail());
                request.setAttribute("addresses", addresses);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
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

        String action = request.getParameter("action");
        if ("applyCoupon".equals(action)) {
            String couponCode = request.getParameter("couponCode");
            if (couponCode != null && !couponCode.trim().isEmpty()) {
                request.getSession().setAttribute("appliedCoupon", couponCode.trim());
            } else {
                request.getSession().removeAttribute("appliedCoupon");
            }
            response.sendRedirect(request.getContextPath() + "/cart");
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
        int addressId = parseInt(request.getParameter("addressId"), -1); // Assume basic setup for now
        
        int couponId = -1;
        String appliedCouponCode = (String) session.getAttribute("appliedCoupon");
        if (appliedCouponCode != null) {
            model.Coupon coupon = utils.CouponUtils.getCouponByCode(appliedCouponCode);
            if (coupon != null) {
                couponId = coupon.getId();
            }
        }
        
        String paymentMethod = request.getParameter("paymentMethod");
        if(paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = "COD";
        }

        String message = utils.OrderUtils.checkout(cart, user.getEmail(), addressId, couponId, paymentMethod);
        if (message.startsWith("Đặt hàng thành công")) {
            cart.clear();
            session.removeAttribute("appliedCoupon");
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

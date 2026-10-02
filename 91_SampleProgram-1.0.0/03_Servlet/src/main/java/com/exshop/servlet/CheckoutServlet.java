package com.exshop.servlet;

import com.exshop.bean.CartBean;
import com.exshop.bean.OrderBean;
import com.exshop.bean.UserBean;
import com.exshop.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/checkout/*")
public class CheckoutServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if ("/complete".equals(pathInfo)) {
            String orderNumber = req.getParameter("orderNumber");
            try {
                OrderBean order = orderDAO.findByOrderNumber(orderNumber);
                req.setAttribute("order", order);
                forward(req, resp, "order/complete.jsp");
                return;
            } catch (Exception e) {
                throw new ServletException(e);
            }
        }

        CartBean cart = getOrCreateCart(req);
        if (cart.isEmpty()) {
            setFlashMessage(req, "warning", "カートに商品が入っていません。");
            redirect(req, resp, "products");
            return;
        }

        forward(req, resp, "order/checkout.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        CartBean cart = getOrCreateCart(req);
        if (cart.isEmpty()) {
            redirect(req, resp, "products");
            return;
        }

        try {
            OrderBean order = new OrderBean();
            UserBean loginUser = getLoginUser(req);
            if (loginUser != null) {
                order.setUserId(loginUser.getId());
            }

            String orderNumber = "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            order.setOrderNumber(orderNumber);
            order.setFullName(req.getParameter("fullName"));
            order.setPostalCode(req.getParameter("postalCode"));
            order.setAddress(req.getParameter("address"));
            order.setPhoneNumber(req.getParameter("phoneNumber"));
            order.setEmail(req.getParameter("email"));
            order.setPaymentMethod(req.getParameter("paymentMethod"));
            order.setTotalPrice(cart.getTotalPrice());
            order.setStatus("completed");

            boolean success = orderDAO.createOrder(order, cart);
            if (success) {
                cart.clear();
                setFlashMessage(req, "success", "ご注文が確定いたしました。");
                redirect(req, resp, "checkout/complete?orderNumber=" + orderNumber);
            } else {
                setFlashMessage(req, "danger", "注文処理に失敗しました。もう一度お試しください。");
                redirect(req, resp, "checkout");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

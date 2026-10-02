package com.exshop.servlet;

import com.exshop.bean.OrderBean;
import com.exshop.bean.UserBean;
import com.exshop.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/orders/*")
public class OrderListServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireLogin(req, resp)) return;
        UserBean user = getLoginUser(req);
        String pathInfo = req.getPathInfo();

        try {
            if ("/detail".equals(pathInfo)) {
                String orderNumber = req.getParameter("orderNumber");
                OrderBean order = orderDAO.findByOrderNumber(orderNumber);
                req.setAttribute("order", order);
                forward(req, resp, "order/detail.jsp");
            } else {
                List<OrderBean> orders = orderDAO.findByUserId(user.getId());
                req.setAttribute("orders", orders);
                forward(req, resp, "order/list.jsp");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

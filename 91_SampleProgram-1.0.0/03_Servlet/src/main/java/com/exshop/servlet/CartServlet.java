package com.exshop.servlet;

import com.exshop.bean.CartBean;
import com.exshop.bean.ProductBean;
import com.exshop.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/cart/*")
public class CartServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        forward(req, resp, "cart/cart.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        CartBean cart = getOrCreateCart(req);

        try {
            if ("/add".equals(pathInfo)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity = Integer.parseInt(req.getParameter("quantity"));
                ProductBean product = productDAO.findById(productId);

                if (product != null) {
                    cart.add(product, quantity);
                    setFlashMessage(req, "success", "「" + product.getName() + "」をカートに追加しました。");
                }
                redirect(req, resp, "cart");

            } else if ("/update".equals(pathInfo)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity = Integer.parseInt(req.getParameter("quantity"));
                cart.update(productId, quantity);
                redirect(req, resp, "cart");

            } else if ("/remove".equals(pathInfo)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                cart.remove(productId);
                setFlashMessage(req, "info", "カートから商品を削除しました。");
                redirect(req, resp, "cart");

            } else {
                redirect(req, resp, "cart");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

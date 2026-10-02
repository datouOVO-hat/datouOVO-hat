package com.exshop.servlet;

import com.exshop.bean.ProductBean;
import com.exshop.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/products/detail")
public class ProductDetailServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            ProductBean product = productDAO.findById(id);

            if (product == null) {
                setFlashMessage(req, "warning", "指定された商品は見つかりませんでした。");
                redirect(req, resp, "products");
                return;
            }

            List<ProductBean> relatedProducts = productDAO.findRelated(id, 4);

            req.setAttribute("product", product);
            req.setAttribute("relatedProducts", relatedProducts);

            forward(req, resp, "product/detail.jsp");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

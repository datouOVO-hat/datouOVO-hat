package com.exshop.servlet;

import com.exshop.bean.ProductBean;
import com.exshop.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/products/create")
public class ProductCreateServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireLogin(req, resp)) return;
        forward(req, resp, "product/form.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireLogin(req, resp)) return;

        try {
            String name = req.getParameter("name");
            String description = req.getParameter("description");
            int price = Integer.parseInt(req.getParameter("price"));
            int stock = Integer.parseInt(req.getParameter("stock"));
            String image = req.getParameter("image"); // 未入力時は null (no-image.png fallback)
            if (image != null && image.trim().isEmpty()) {
                image = null;
            }

            String[] tagParam = req.getParameterValues("tagIds");
            int[] tagIds = null;
            if (tagParam != null) {
                tagIds = new int[tagParam.length];
                for (int i = 0; i < tagParam.length; i++) {
                    tagIds[i] = Integer.parseInt(tagParam[i]);
                }
            }

            ProductBean p = new ProductBean();
            p.setName(name);
            p.setDescription(description);
            p.setPrice(price);
            p.setStock(stock);
            p.setImage(image);
            p.setActive(true);

            int newId = productDAO.insert(p, tagIds);

            setFlashMessage(req, "success", "商品「" + name + "」を出品・登録いたしました。");
            redirect(req, resp, "products/detail?id=" + newId);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

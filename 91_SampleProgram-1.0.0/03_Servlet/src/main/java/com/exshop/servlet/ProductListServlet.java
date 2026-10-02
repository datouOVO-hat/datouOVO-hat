package com.exshop.servlet;

import com.exshop.bean.ProductBean;
import com.exshop.bean.TagBean;
import com.exshop.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"", "/products"})
public class ProductListServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String query = req.getParameter("q");
            String tagSlug = req.getParameter("tag");
            String sort = req.getParameter("sort");
            if (sort == null || sort.isEmpty()) sort = "newest";

            int page = 1;
            try {
                page = Integer.parseInt(req.getParameter("page"));
            } catch (Exception ignored) {}
            if (page < 1) page = 1;

            int limit = 12;
            int offset = (page - 1) * limit;

            int totalCount = productDAO.countProducts(query, tagSlug);
            int totalPages = (int) Math.ceil((double) totalCount / limit);
            if (totalPages < 1) totalPages = 1;

            List<ProductBean> products = productDAO.findProducts(query, tagSlug, sort, limit, offset);

            TagBean selectedTag = null;
            if (tagSlug != null && !tagSlug.isEmpty()) {
                selectedTag = tagDAO.findBySlug(tagSlug);
            }

            req.setAttribute("products", products);
            req.setAttribute("query", query);
            req.setAttribute("tagSlug", tagSlug);
            req.setAttribute("selectedTag", selectedTag);
            req.setAttribute("sort", sort);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalCount", totalCount);

            forward(req, resp, "product/list.jsp");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

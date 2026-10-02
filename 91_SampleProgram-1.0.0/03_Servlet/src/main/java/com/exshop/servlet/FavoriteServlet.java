package com.exshop.servlet;

import com.exshop.bean.FavoriteBean;
import com.exshop.bean.UserBean;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/favorites/*")
public class FavoriteServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireLogin(req, resp)) return;
        UserBean user = getLoginUser(req);
        try {
            List<FavoriteBean> favorites = favoriteDAO.findByUserId(user.getId());
            req.setAttribute("favorites", favorites);
            forward(req, resp, "favorite/list.jsp");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!requireLogin(req, resp)) return;
        UserBean user = getLoginUser(req);
        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            boolean added = favoriteDAO.toggle(user.getId(), productId);

            if (added) {
                setFlashMessage(req, "success", "お気に入りに追加いたしました。");
            } else {
                setFlashMessage(req, "info", "お気に入りを解除いたしました。");
            }

            String referer = req.getHeader("Referer");
            if (referer != null && !referer.isEmpty()) {
                resp.sendRedirect(referer);
            } else {
                redirect(req, resp, "products");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

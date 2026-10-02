package com.exshop.servlet;

import com.exshop.bean.FavoriteBean;
import com.exshop.bean.OrderBean;
import com.exshop.bean.UserBean;
import com.exshop.dao.OrderDAO;
import com.exshop.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/auth/*")
public class AuthServlet extends CommonServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if ("/login".equals(path)) {
            forward(req, resp, "auth/login.jsp");
        } else if ("/signup".equals(path)) {
            forward(req, resp, "auth/signup.jsp");
        } else if ("/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.removeAttribute("loginUser");
            }
            setFlashMessage(req, "info", "ログアウトいたしました。");
            redirect(req, resp, "products");
        } else if ("/mypage".equals(path)) {
            if (!requireLogin(req, resp)) return;
            UserBean user = getLoginUser(req);
            try {
                List<OrderBean> recentOrders = orderDAO.findByUserId(user.getId());
                List<FavoriteBean> favorites = favoriteDAO.findByUserId(user.getId());
                req.setAttribute("recentOrders", recentOrders);
                req.setAttribute("favorites", favorites);
                forward(req, resp, "user/mypage.jsp");
            } catch (Exception e) {
                throw new ServletException(e);
            }
        } else {
            redirect(req, resp, "products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        try {
            if ("/login".equals(path)) {
                String u = req.getParameter("username");
                String p = req.getParameter("password");
                UserBean user = userDAO.authenticate(u, p);
                if (user != null) {
                    req.getSession(true).setAttribute("loginUser", user);
                    setFlashMessage(req, "success", "ようこそ、" + user.getUsername() + " 様。");
                    redirect(req, resp, "products");
                } else {
                    req.setAttribute("errorMessage", "ユーザー名またはパスワードが正しくありません。");
                    forward(req, resp, "auth/login.jsp");
                }
            } else if ("/signup".equals(path)) {
                String u = req.getParameter("username");
                String p = req.getParameter("password");
                String email = req.getParameter("email");
                String first = req.getParameter("firstName");
                String last = req.getParameter("lastName");

                if (userDAO.findByUsername(u) != null) {
                    req.setAttribute("errorMessage", "そのユーザー名は既に使用されています。");
                    forward(req, resp, "auth/signup.jsp");
                    return;
                }

                UserBean user = new UserBean();
                user.setUsername(u);
                user.setEmail(email);
                user.setFirstName(first);
                user.setLastName(last);
                user.setStaff(false);

                if (userDAO.register(user, p)) {
                    req.getSession(true).setAttribute("loginUser", user);
                    setFlashMessage(req, "success", "ご登録ありがとうございます。exShopへようこそ！");
                    redirect(req, resp, "products");
                } else {
                    req.setAttribute("errorMessage", "アカウント作成に失敗しました。");
                    forward(req, resp, "auth/signup.jsp");
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

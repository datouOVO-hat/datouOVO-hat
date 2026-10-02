package com.exshop.servlet;

import com.exshop.bean.CartBean;
import com.exshop.bean.UserBean;
import com.exshop.dao.FavoriteDAO;
import com.exshop.dao.TagDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

/**
 * すべてのサーブレットの基底クラス (フロントコントローラ兼共通処理ハンドラ)
 */
public abstract class CommonServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected TagDAO tagDAO = new TagDAO();
    protected FavoriteDAO favoriteDAO = new FavoriteDAO();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. 文字コード共通設定 (UTF-8)
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        try {
            // 2. 共通コンテキスト（タグ一覧、カート、お気に入り情報）をリクエストに注入
            req.setAttribute("allTags", tagDAO.findAllWithCount());

            CartBean cart = getOrCreateCart(req);
            req.setAttribute("cart", cart);

            UserBean loginUser = getLoginUser(req);
            if (loginUser != null) {
                Set<Integer> favIds = favoriteDAO.findProductIdsByUserId(loginUser.getId());
                req.setAttribute("favoriteProductIds", favIds);
                req.setAttribute("favoriteCount", favIds.size());
            }

            // フラッシュメッセージの転送（セッションからリクエストスコープへ取り出し）
            HttpSession session = req.getSession(false);
            if (session != null) {
                Object flashMsg = session.getAttribute("flashMessage");
                Object flashType = session.getAttribute("flashType");
                if (flashMsg != null) {
                    req.setAttribute("flashMessage", flashMsg);
                    req.setAttribute("flashType", flashType != null ? flashType : "info");
                    session.removeAttribute("flashMessage");
                    session.removeAttribute("flashType");
                }
            }

            // 3. 各具象サーブレットの処理 (doGet / doPost) を実行
            super.service(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMessage", "システムエラーが発生しました: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/common/error.jsp").forward(req, resp);
        }
    }

    /**
     * 指定した JSP パスへフォワード (/WEB-INF/views/ 配下)
     */
    protected void forward(HttpServletRequest req, HttpServletResponse resp, String jspPath) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/" + jspPath).forward(req, resp);
    }

    /**
     * コンテキストパス考慮のリダイレクト
     */
    protected void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        if (path.startsWith("/")) {
            resp.sendRedirect(req.getContextPath() + path);
        } else {
            resp.sendRedirect(req.getContextPath() + "/" + path);
        }
    }

    protected CartBean getOrCreateCart(HttpServletRequest req) {
        HttpSession session = req.getSession(true);
        CartBean cart = (CartBean) session.getAttribute("cart");
        if (cart == null) {
            cart = new CartBean();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    protected UserBean getLoginUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            return (UserBean) session.getAttribute("loginUser");
        }
        return null;
    }

    protected void setFlashMessage(HttpServletRequest req, String type, String message) {
        HttpSession session = req.getSession(true);
        session.setAttribute("flashType", type);
        session.setAttribute("flashMessage", message);
    }

    protected boolean requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (getLoginUser(req) == null) {
            setFlashMessage(req, "warning", "この操作にはログインが必要です。");
            redirect(req, resp, "auth/login");
            return false;
        }
        return true;
    }
}

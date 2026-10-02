package com.exshop.dao;

import com.exshop.bean.FavoriteBean;
import com.exshop.bean.ProductBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FavoriteDAO {

    public boolean toggle(int userId, int productId) throws SQLException {
        String checkSql = "SELECT id FROM favorites WHERE user_id = ? AND product_id = ?";
        String deleteSql = "DELETE FROM favorites WHERE user_id = ? AND product_id = ?";
        String insertSql = "INSERT INTO favorites (user_id, product_id) VALUES (?, ?)";

        try (Connection conn = DBManager.getConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, productId);
                    ps.executeUpdate();
                }
                return false; // 解除
            } else {
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, productId);
                    ps.executeUpdate();
                }
                return true; // 追加
            }
        }
    }

    public Set<Integer> findProductIdsByUserId(int userId) throws SQLException {
        Set<Integer> set = new HashSet<>();
        String sql = "SELECT product_id FROM favorites WHERE user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getInt("product_id"));
                }
            }
        }
        return set;
    }

    public List<FavoriteBean> findByUserId(int userId) throws SQLException {
        List<FavoriteBean> list = new ArrayList<>();
        String sql = "SELECT f.id, f.user_id, f.product_id, f.created_at, " +
                     "p.name, p.price, p.stock, p.image, p.is_active " +
                     "FROM favorites f " +
                     "JOIN products p ON f.product_id = p.id " +
                     "WHERE f.user_id = ? ORDER BY f.created_at DESC";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                TagDAO tagDAO = new TagDAO();
                while (rs.next()) {
                    FavoriteBean fav = new FavoriteBean();
                    fav.setId(rs.getInt("id"));
                    fav.setUserId(rs.getInt("user_id"));
                    fav.setProductId(rs.getInt("product_id"));
                    fav.setCreatedAt(rs.getTimestamp("created_at"));

                    ProductBean p = new ProductBean();
                    p.setId(fav.getProductId());
                    p.setName(rs.getString("name"));
                    p.setPrice(rs.getInt("price"));
                    p.setStock(rs.getInt("stock"));
                    p.setImage(rs.getString("image"));
                    p.setActive(rs.getBoolean("is_active"));
                    p.setTags(tagDAO.findByProductId(p.getId()));

                    fav.setProduct(p);
                    list.add(fav);
                }
            }
        }
        return list;
    }
}

package com.exshop.dao;

import com.exshop.bean.TagBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TagDAO {

    public List<TagBean> findAllWithCount() throws SQLException {
        List<TagBean> list = new ArrayList<>();
        String sql = "SELECT t.id, t.name, t.slug, t.color, COUNT(pt.product_id) AS prod_count " +
                     "FROM tags t " +
                     "LEFT JOIN product_tags pt ON t.id = pt.tag_id " +
                     "GROUP BY t.id, t.name, t.slug, t.color " +
                     "ORDER BY t.name ASC";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TagBean tag = new TagBean(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("slug"),
                    rs.getString("color")
                );
                tag.setProductCount(rs.getInt("prod_count"));
                list.add(tag);
            }
        }
        return list;
    }

    public TagBean findBySlug(String slug) throws SQLException {
        String sql = "SELECT id, name, slug, color FROM tags WHERE slug = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new TagBean(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("slug"),
                        rs.getString("color")
                    );
                }
            }
        }
        return null;
    }

    public List<TagBean> findByProductId(int productId) throws SQLException {
        List<TagBean> list = new ArrayList<>();
        String sql = "SELECT t.id, t.name, t.slug, t.color FROM tags t " +
                     "JOIN product_tags pt ON t.id = pt.tag_id " +
                     "WHERE pt.product_id = ? ORDER BY t.name ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TagBean(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("slug"),
                        rs.getString("color")
                    ));
                }
            }
        }
        return list;
    }
}

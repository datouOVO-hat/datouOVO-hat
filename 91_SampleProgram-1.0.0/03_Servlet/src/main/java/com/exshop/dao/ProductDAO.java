package com.exshop.dao;

import com.exshop.bean.ProductBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<ProductBean> findProducts(String query, String tagSlug, String sort, int limit, int offset) throws SQLException {
        List<ProductBean> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT p.id, p.name, p.description, p.price, p.stock, p.image, p.is_active, p.created_at, p.updated_at " +
            "FROM products p "
        );

        if (tagSlug != null && !tagSlug.trim().isEmpty()) {
            sql.append("JOIN product_tags pt ON p.id = pt.product_id ")
               .append("JOIN tags t ON pt.tag_id = t.id AND t.slug = ? ");
        }

        sql.append("WHERE p.is_active = TRUE ");

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (p.name ILIKE ? OR p.description ILIKE ?) ");
        }

        if ("price_asc".equals(sort)) {
            sql.append("ORDER BY p.price ASC, p.id DESC ");
        } else if ("price_desc".equals(sort)) {
            sql.append("ORDER BY p.price DESC, p.id DESC ");
        } else {
            sql.append("ORDER BY p.created_at DESC, p.id DESC ");
        }

        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (tagSlug != null && !tagSlug.trim().isEmpty()) {
                ps.setString(paramIndex++, tagSlug.trim());
            }
            if (query != null && !query.trim().isEmpty()) {
                String likeTerm = "%" + query.trim() + "%";
                ps.setString(paramIndex++, likeTerm);
                ps.setString(paramIndex++, likeTerm);
            }
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                TagDAO tagDAO = new TagDAO();
                while (rs.next()) {
                    ProductBean p = mapResultSetToProduct(rs);
                    p.setTags(tagDAO.findByProductId(p.getId()));
                    list.add(p);
                }
            }
        }
        return list;
    }

    public int countProducts(String query, String tagSlug) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT p.id) FROM products p ");
        if (tagSlug != null && !tagSlug.trim().isEmpty()) {
            sql.append("JOIN product_tags pt ON p.id = pt.product_id ")
               .append("JOIN tags t ON pt.tag_id = t.id AND t.slug = ? ");
        }
        sql.append("WHERE p.is_active = TRUE ");
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (p.name ILIKE ? OR p.description ILIKE ?) ");
        }

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (tagSlug != null && !tagSlug.trim().isEmpty()) {
                ps.setString(paramIndex++, tagSlug.trim());
            }
            if (query != null && !query.trim().isEmpty()) {
                String likeTerm = "%" + query.trim() + "%";
                ps.setString(paramIndex++, likeTerm);
                ps.setString(paramIndex++, likeTerm);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public ProductBean findById(int id) throws SQLException {
        String sql = "SELECT id, name, description, price, stock, image, is_active, created_at, updated_at " +
                     "FROM products WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductBean p = mapResultSetToProduct(rs);
                    p.setTags(new TagDAO().findByProductId(p.getId()));
                    return p;
                }
            }
        }
        return null;
    }

    public List<ProductBean> findRelated(int productId, int limit) throws SQLException {
        List<ProductBean> list = new ArrayList<>();
        String sql = "SELECT DISTINCT p.id, p.name, p.description, p.price, p.stock, p.image, p.is_active, p.created_at, p.updated_at " +
                     "FROM products p " +
                     "JOIN product_tags pt ON p.id = pt.product_id " +
                     "WHERE pt.tag_id IN (SELECT tag_id FROM product_tags WHERE product_id = ?) " +
                     "AND p.id <> ? AND p.is_active = TRUE " +
                     "LIMIT ?";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, productId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                TagDAO tagDAO = new TagDAO();
                while (rs.next()) {
                    ProductBean p = mapResultSetToProduct(rs);
                    p.setTags(tagDAO.findByProductId(p.getId()));
                    list.add(p);
                }
            }
        }
        return list;
    }

    public int insert(ProductBean product, int[] tagIds) throws SQLException {
        String sql = "INSERT INTO products (name, description, price, stock, image, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int newId;
                try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, product.getName());
                    ps.setString(2, product.getDescription());
                    ps.setInt(3, product.getPrice());
                    ps.setInt(4, product.getStock());
                    ps.setString(5, product.getImage());
                    ps.setBoolean(6, product.isActive());
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            newId = rs.getInt(1);
                        } else {
                            throw new SQLException("Creating product failed, no ID obtained.");
                        }
                    }
                }

                if (tagIds != null && tagIds.length > 0) {
                    String tagSql = "INSERT INTO product_tags (product_id, tag_id) VALUES (?, ?)";
                    try (PreparedStatement psTag = conn.prepareStatement(tagSql)) {
                        for (int tId : tagIds) {
                            psTag.setInt(1, newId);
                            psTag.setInt(2, tId);
                            psTag.addBatch();
                        }
                        psTag.executeBatch();
                    }
                }

                conn.commit();
                return newId;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private ProductBean mapResultSetToProduct(ResultSet rs) throws SQLException {
        ProductBean p = new ProductBean();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getInt("price"));
        p.setStock(rs.getInt("stock"));
        p.setImage(rs.getString("image"));
        p.setActive(rs.getBoolean("is_active"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }
}

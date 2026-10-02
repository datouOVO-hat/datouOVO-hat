package com.exshop.dao;

import com.exshop.bean.CartBean;
import com.exshop.bean.CartItemBean;
import com.exshop.bean.OrderBean;
import com.exshop.bean.OrderItemBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public boolean createOrder(OrderBean order, CartBean cart) throws SQLException {
        String insertOrderSql = "INSERT INTO orders (user_id, order_number, full_name, postal_code, address, phone_number, email, payment_method, total_price, status) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertItemSql = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity) VALUES (?, ?, ?, ?, ?)";
        String updateStockSql = "UPDATE products SET stock = GREATEST(0, stock - ?) WHERE id = ?";

        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId;
                try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    if (order.getUserId() != null) {
                        ps.setInt(1, order.getUserId());
                    } else {
                        ps.setNull(1, Types.INTEGER);
                    }
                    ps.setString(2, order.getOrderNumber());
                    ps.setString(3, order.getFullName());
                    ps.setString(4, order.getPostalCode());
                    ps.setString(5, order.getAddress());
                    ps.setString(6, order.getPhoneNumber());
                    ps.setString(7, order.getEmail());
                    ps.setString(8, order.getPaymentMethod());
                    ps.setInt(9, order.getTotalPrice());
                    ps.setString(10, order.getStatus());

                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                            order.setId(orderId);
                        } else {
                            throw new SQLException("Creating order failed, no ID obtained.");
                        }
                    }
                }

                try (PreparedStatement psItem = conn.prepareStatement(insertItemSql);
                     PreparedStatement psStock = conn.prepareStatement(updateStockSql)) {
                    for (CartItemBean item : cart.getItems()) {
                        psItem.setInt(1, orderId);
                        psItem.setInt(2, item.getProduct().getId());
                        psItem.setString(3, item.getProduct().getName());
                        psItem.setInt(4, item.getPrice());
                        psItem.setInt(5, item.getQuantity());
                        psItem.addBatch();

                        psStock.setInt(1, item.getQuantity());
                        psStock.setInt(2, item.getProduct().getId());
                        psStock.addBatch();
                    }
                    psItem.executeBatch();
                    psStock.executeBatch();
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public List<OrderBean> findByUserId(int userId) throws SQLException {
        List<OrderBean> list = new ArrayList<>();
        String sql = "SELECT id, user_id, order_number, full_name, postal_code, address, phone_number, email, payment_method, total_price, status, created_at " +
                     "FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderBean o = mapOrder(rs);
                    o.setItems(findItemsByOrderId(conn, o.getId()));
                    list.add(o);
                }
            }
        }
        return list;
    }

    public OrderBean findByOrderNumber(String orderNumber) throws SQLException {
        String sql = "SELECT id, user_id, order_number, full_name, postal_code, address, phone_number, email, payment_method, total_price, status, created_at " +
                     "FROM orders WHERE order_number = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    OrderBean o = mapOrder(rs);
                    o.setItems(findItemsByOrderId(conn, o.getId()));
                    return o;
                }
            }
        }
        return null;
    }

    private List<OrderItemBean> findItemsByOrderId(Connection conn, int orderId) throws SQLException {
        List<OrderItemBean> list = new ArrayList<>();
        String sql = "SELECT id, order_id, product_id, product_name, price, quantity FROM order_items WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItemBean item = new OrderItemBean();
                    item.setId(rs.getInt("id"));
                    item.setOrderId(rs.getInt("order_id"));
                    int pId = rs.getInt("product_id");
                    if (!rs.wasNull()) {
                        item.setProductId(pId);
                    }
                    item.setProductName(rs.getString("product_name"));
                    item.setPrice(rs.getInt("price"));
                    item.setQuantity(rs.getInt("quantity"));
                    list.add(item);
                }
            }
        }
        return list;
    }

    private OrderBean mapOrder(ResultSet rs) throws SQLException {
        OrderBean o = new OrderBean();
        o.setId(rs.getInt("id"));
        int uId = rs.getInt("user_id");
        if (!rs.wasNull()) o.setUserId(uId);
        o.setOrderNumber(rs.getString("order_number"));
        o.setFullName(rs.getString("full_name"));
        o.setPostalCode(rs.getString("postal_code"));
        o.setAddress(rs.getString("address"));
        o.setPhoneNumber(rs.getString("phone_number"));
        o.setEmail(rs.getString("email"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setTotalPrice(rs.getInt("total_price"));
        o.setStatus(rs.getString("status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }
}

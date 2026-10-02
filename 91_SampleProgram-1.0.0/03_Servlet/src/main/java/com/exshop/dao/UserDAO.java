package com.exshop.dao;

import com.exshop.bean.UserBean;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

public class UserDAO {

    public UserBean findByUsername(String username) throws SQLException {
        String sql = "SELECT id, username, password_hash, email, first_name, last_name, is_staff, created_at " +
                     "FROM users WHERE username = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public UserBean findById(int id) throws SQLException {
        String sql = "SELECT id, username, password_hash, email, first_name, last_name, is_staff, created_at " +
                     "FROM users WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public UserBean authenticate(String username, String rawPassword) throws SQLException {
        UserBean user = findByUsername(username);
        if (user != null && BCrypt.checkpw(rawPassword, user.getPasswordHash())) {
            return user;
        }
        return null;
    }

    public boolean register(UserBean user, String rawPassword) throws SQLException {
        String hash = BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));
        String sql = "INSERT INTO users (username, password_hash, email, first_name, last_name, is_staff) " +
                     "VALUES (?, ?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, hash);
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getFirstName());
            ps.setString(5, user.getLastName());
            ps.setBoolean(6, user.isStaff());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user.setId(rs.getInt(1));
                    user.setPasswordHash(hash);
                    return true;
                }
            }
        }
        return false;
    }

    private UserBean mapUser(ResultSet rs) throws SQLException {
        UserBean u = new UserBean();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setEmail(rs.getString("email"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setStaff(rs.getBoolean("is_staff"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}

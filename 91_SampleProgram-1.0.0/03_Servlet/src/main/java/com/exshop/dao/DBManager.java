package com.exshop.dao;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DBManager {
    private static HikariDataSource dataSource;
    private static boolean isH2 = false;

    static {
        try {
            Properties props = new Properties();
            try (InputStream in = DBManager.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (in != null) {
                    props.load(in);
                }
            }

            String envUrl = System.getenv("JDBC_DATABASE_URL");
            String envUser = System.getenv("JDBC_DATABASE_USERNAME");
            String envPassword = System.getenv("JDBC_DATABASE_PASSWORD");

            String targetUrl = envUrl != null && !envUrl.isEmpty() ? envUrl : props.getProperty("db.url", "jdbc:postgresql://localhost:5432/exshop_db");
            String targetUser = envUser != null ? envUser : props.getProperty("db.user", "postgres");
            String targetPass = envPassword != null ? envPassword : props.getProperty("db.password", "postgres");

            boolean pgAvailable = false;
            // PostgreSQL が利用可能か事前チェック
            if (targetUrl.contains("postgresql")) {
                try {
                    Class.forName("org.postgresql.Driver");
                    DriverManager.setLoginTimeout(2);
                    try (Connection testConn = DriverManager.getConnection(targetUrl, targetUser, targetPass)) {
                        pgAvailable = true;
                        System.out.println("[DBManager] Connected to PostgreSQL successfully: " + targetUrl);
                    }
                } catch (Exception e) {
                    System.out.println("[DBManager] PostgreSQL not available (" + e.getMessage() + "). Falling back to embedded H2 Database.");
                }
            }

            HikariConfig config = new HikariConfig();
            if (pgAvailable) {
                config.setDriverClassName("org.postgresql.Driver");
                config.setJdbcUrl(targetUrl);
                config.setUsername(targetUser);
                config.setPassword(targetPass);
            } else {
                // H2 Database 組み込みモード (PostgreSQL互換モード, ファイル永続化)
                isH2 = true;
                String userHome = System.getProperty("user.home");
                File dbDir = new File(userHome, ".exshop");
                dbDir.mkdirs();
                String h2Path = new File(dbDir, "exshop_h2").getAbsolutePath().replace('\\', '/');
                String h2Url = "jdbc:h2:" + h2Path + ";MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;AUTO_SERVER=TRUE";

                config.setDriverClassName("org.h2.Driver");
                config.setJdbcUrl(h2Url);
                config.setUsername("sa");
                config.setPassword("");
                System.out.println("[DBManager] Using embedded H2 Database: " + h2Url);
            }

            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("pool.maximumPoolSize", "10")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("pool.minimumIdle", "2")));
            config.setPoolName("exShopPool");

            dataSource = new HikariDataSource(config);

            // H2 初期テーブル作成 & シードデータ投入
            if (isH2) {
                initH2Database();
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Database Pool Initialization Failed: " + e.getMessage(), e);
        }
    }

    private static void initH2Database() {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            
            boolean needInit = false;
            try (ResultSet rs = stmt.executeQuery("SELECT count(*) FROM information_schema.tables WHERE table_name = 'products'")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    needInit = true;
                }
            }

            if (needInit) {
                System.out.println("[DBManager] Initializing H2 Schema and Sample Data...");
                executeSqlScript(conn, "sql/schema.sql");
                executeSqlScript(conn, "sql/data.sql");
                try (Statement restartStmt = conn.createStatement()) {
                    restartStmt.execute("ALTER TABLE orders ALTER COLUMN id RESTART WITH 100");
                    restartStmt.execute("ALTER TABLE order_items ALTER COLUMN id RESTART WITH 100");
                    restartStmt.execute("ALTER TABLE products ALTER COLUMN id RESTART WITH 100");
                    restartStmt.execute("ALTER TABLE users ALTER COLUMN id RESTART WITH 100");
                    restartStmt.execute("ALTER TABLE tags ALTER COLUMN id RESTART WITH 100");
                    restartStmt.execute("ALTER TABLE favorites ALTER COLUMN id RESTART WITH 100");
                } catch (Exception e) {}
                System.out.println("[DBManager] H2 Database initialized successfully!");
            }
        } catch (Exception e) {
            System.err.println("[DBManager] H2 Init warning: " + e.getMessage());
        }
    }

    private static void executeSqlScript(Connection conn, String scriptPath) {
        try (InputStream in = DBManager.class.getClassLoader().getResourceAsStream(scriptPath)) {
            if (in == null) return;
            BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.startsWith("--") || line.isEmpty()) continue;
                // setval は H2 では不要またはスキップ
                if (line.toLowerCase().startsWith("select setval")) continue;
                sb.append(line).append(" ");
                if (line.endsWith(";")) {
                    try (Statement stmt = conn.createStatement()) {
                        stmt.execute(sb.toString());
                    } catch (Exception e) {
                        // ignore drop table or non-fatal errors
                    }
                    sb.setLength(0);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}

package com.face.util;

import com.alibaba.druid.pool.DruidDataSource;
import com.alibaba.druid.pool.DruidDataSourceFactory;

import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * 数据库工具类 - 使用Druid连接池
 */
public class DBUtil {

    private static DataSource dataSource;

    static {
        try {
            InputStream is = DBUtil.class.getClassLoader().getResourceAsStream("db.properties");
            Properties props = new Properties();
            props.load(is);

            // 创建Druid数据源
            DruidDataSource druidDS = new DruidDataSource();
            druidDS.setDriverClassName(props.getProperty("db.driver"));
            druidDS.setUrl(props.getProperty("db.url"));
            druidDS.setUsername(props.getProperty("db.username"));
            druidDS.setPassword(props.getProperty("db.password"));
            druidDS.setInitialSize(Integer.parseInt(props.getProperty("db.initialSize", "5")));
            druidDS.setMaxActive(Integer.parseInt(props.getProperty("db.maxActive", "20")));
            druidDS.setMinIdle(Integer.parseInt(props.getProperty("db.minIdle", "5")));
            druidDS.setMaxWait(Long.parseLong(props.getProperty("db.maxWait", "60000")));
            // 连接验证
            druidDS.setValidationQuery("SELECT 1");
            druidDS.setTestWhileIdle(true);
            druidDS.setTestOnBorrow(false);
            druidDS.setTestOnReturn(false);

            dataSource = druidDS;
            System.out.println(">>> 数据库连接池初始化成功！");
        } catch (Exception e) {
            System.err.println("!!! 数据库连接池初始化失败: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("数据库连接池初始化失败", e);
        }
    }

    /**
     * 获取数据库连接
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * 获取数据源
     */
    public static DataSource getDataSource() {
        return dataSource;
    }

    /**
     * 关闭连接
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}

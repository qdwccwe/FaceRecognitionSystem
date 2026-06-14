package com.face.dao;

import com.face.model.User;
import com.face.util.DBUtil;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

import java.sql.SQLException;
import java.util.List;

/**
 * 用户数据访问层
 */
public class UserDao {

    private final QueryRunner qr = new QueryRunner(DBUtil.getDataSource());

    /**
     * 根据用户名查找用户
     */
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users WHERE username = ?";
        return qr.query(sql, new BeanHandler<>(User.class), username);
    }

    /**
     * 根据ID查找用户
     */
    public User findById(int id) throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users WHERE id = ?";
        return qr.query(sql, new BeanHandler<>(User.class), id);
    }

    /**
     * 查询所有用户
     */
    public List<User> findAll() throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users ORDER BY id DESC";
        return qr.query(sql, new BeanListHandler<>(User.class));
    }

    /**
     * 分页查询用户
     */
    public List<User> findByPage(int page, int pageSize) throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users ORDER BY id DESC LIMIT ?, ?";
        int offset = (page - 1) * pageSize;
        return qr.query(sql, new BeanListHandler<>(User.class), offset, pageSize);
    }

    /**
     * 查询用户总数
     */
    public long count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        return qr.query(sql, new ScalarHandler<>());
    }

    /**
     * 新增用户
     */
    public int insert(User user) throws SQLException {
        String sql = "INSERT INTO users (username, password, real_name, phone, email, role, face_status, face_image_path, face_feature) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return qr.update(sql,
                user.getUsername(),
                user.getPassword(),
                user.getRealName(),
                user.getPhone(),
                user.getEmail(),
                user.getRole(),
                user.getFaceStatus(),
                user.getFaceImagePath(),
                user.getFaceFeature()
        );
    }

    /**
     * 更新用户信息
     */
    public int update(User user) throws SQLException {
        String sql = "UPDATE users SET real_name=?, phone=?, email=? WHERE id=?";
        return qr.update(sql, user.getRealName(), user.getPhone(), user.getEmail(), user.getId());
    }

    /**
     * 更新密码
     */
    public int updatePassword(int userId, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password=? WHERE id=?";
        return qr.update(sql, newPassword, userId);
    }

    /**
     * 更新人脸信息
     */
    public int updateFaceInfo(int userId, int faceStatus, String faceImagePath, String faceFeature) throws SQLException {
        String sql = "UPDATE users SET face_status=?, face_image_path=?, face_feature=? WHERE id=?";
        return qr.update(sql, faceStatus, faceImagePath, faceFeature, userId);
    }

    /**
     * 删除用户
     */
    public int delete(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE id=?";
        return qr.update(sql, userId);
    }

    /**
     * 查询所有已注册人脸的用户
     */
    public List<User> findUsersWithFace() throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users WHERE face_status = 1 AND face_image_path != ''";
        return qr.query(sql, new BeanListHandler<>(User.class));
    }

    /**
     * 根据角色查询用户
     */
    public List<User> findByRole(String role) throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users WHERE role = ? ORDER BY id DESC";
        return qr.query(sql, new BeanListHandler<>(User.class), role);
    }

    /**
     * 搜索用户
     */
    public List<User> search(String keyword) throws SQLException {
        String sql = "SELECT id, username, password, real_name AS realName, phone, email, " +
                "role, face_status AS faceStatus, face_image_path AS faceImagePath, " +
                "face_feature AS faceFeature, created_at AS createdAt, updated_at AS updatedAt " +
                "FROM users WHERE username LIKE ? OR real_name LIKE ? ORDER BY id DESC";
        String kw = "%" + keyword + "%";
        return qr.query(sql, new BeanListHandler<>(User.class), kw, kw);
    }
}

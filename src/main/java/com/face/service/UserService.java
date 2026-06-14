package com.face.service;

import com.face.dao.UserDao;
import com.face.model.User;
import com.face.util.MD5Util;

import java.sql.SQLException;
import java.util.List;

/**
 * 用户业务逻辑层
 */
public class UserService {

    private final UserDao userDao = new UserDao();

    /**
     * 用户登录（账密方式）
     * @return 登录成功返回User对象，失败返回null
     */
    public User login(String username, String password) throws SQLException {
        User user = userDao.findByUsername(username);
        if (user != null && MD5Util.verify(password, user.getPassword())) {
            // 不返回密码
            user.setPassword(null);
            return user;
        }
        return null;
    }

    /**
     * 用户注册
     * @return 1=成功, -1=用户名已存在, 0=失败
     */
    public int register(User user) throws SQLException {
        // 检查用户名是否已存在
        User existUser = userDao.findByUsername(user.getUsername());
        if (existUser != null) {
            return -1; // 用户名已存在
        }

        // 密码加密
        user.setPassword(MD5Util.md5(user.getPassword()));
        // 默认角色
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole("user");
        }
        // 默认人脸状态
        user.setFaceStatus(0);

        int result = userDao.insert(user);
        return result > 0 ? 1 : 0;
    }

    /**
     * 获取用户信息
     */
    public User getUserById(int userId) throws SQLException {
        User user = userDao.findById(userId);
        if (user != null) {
            user.setPassword(null);
        }
        return user;
    }

    /**
     * 更新用户信息
     */
    public boolean updateUser(User user) throws SQLException {
        return userDao.update(user) > 0;
    }

    /**
     * 修改密码
     */
    public boolean updatePassword(int userId, String oldPassword, String newPassword) throws SQLException {
        User user = userDao.findById(userId);
        if (user == null || !MD5Util.verify(oldPassword, user.getPassword())) {
            return false; // 旧密码不正确
        }
        return userDao.updatePassword(userId, MD5Util.md5(newPassword)) > 0;
    }

    /**
     * 管理员：获取所有用户（分页）
     */
    public List<User> getAllUsers(int page, int pageSize) throws SQLException {
        return userDao.findByPage(page, pageSize);
    }

    /**
     * 管理员：获取用户总数
     */
    public long getUserCount() throws SQLException {
        return userDao.count();
    }

    /**
     * 管理员：删除用户
     */
    public boolean deleteUser(int userId) throws SQLException {
        return userDao.delete(userId) > 0;
    }

    /**
     * 管理员：搜索用户
     */
    public List<User> searchUsers(String keyword) throws SQLException {
        return userDao.search(keyword);
    }

    /**
     * 获取所有已注册人脸的用户
     */
    public List<User> getUsersWithFace() throws SQLException {
        return userDao.findUsersWithFace();
    }
}

package com.face.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * 用户实体类
 */
public class User implements Serializable {

    private int id;
    private String username;
    private String password;
    private String realName;
    private String phone;
    private String email;
    private String role;          // admin / user
    private int faceStatus;       // 0=未注册人脸, 1=已注册
    private String faceImagePath; // 人脸照片存储路径
    private String faceFeature;   // 人脸特征数据
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public User() {}

    public User(int id, String username, String realName, String role) {
        this.id = id;
        this.username = username;
        this.realName = realName;
        this.role = role;
    }

    // ==================== Getters & Setters ====================

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getFaceStatus() { return faceStatus; }
    public void setFaceStatus(int faceStatus) { this.faceStatus = faceStatus; }

    public String getFaceImagePath() { return faceImagePath; }
    public void setFaceImagePath(String faceImagePath) { this.faceImagePath = faceImagePath; }

    public String getFaceFeature() { return faceFeature; }
    public void setFaceFeature(String faceFeature) { this.faceFeature = faceFeature; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // ==================== 业务方法 ====================

    public boolean isAdmin() {
        return "admin".equals(role);
    }

    public boolean hasFaceRegistered() {
        return faceStatus == 1;
    }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', realName='" + realName + "', role='" + role + "'}";
    }
}

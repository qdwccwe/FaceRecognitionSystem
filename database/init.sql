-- ==========================================
-- 人脸考勤打卡系统 - 数据库初始化脚本
-- 使用方法：在MySQL中执行此脚本即可创建数据库和表
-- ==========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS face_attendance
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE face_attendance;

-- ==========================================
-- 1. 用户表
-- ==========================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(128) NOT NULL COMMENT '密码(MD5加密)',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    phone VARCHAR(20) DEFAULT '' COMMENT '手机号',
    email VARCHAR(100) DEFAULT '' COMMENT '邮箱',
    role VARCHAR(20) DEFAULT 'user' COMMENT '角色: admin(管理员) / user(普通用户)',
    face_status TINYINT DEFAULT 0 COMMENT '人脸注册状态: 0未注册 1已注册',
    face_image_path VARCHAR(255) DEFAULT '' COMMENT '人脸照片路径',
    face_feature TEXT COMMENT '人脸特征数据(JSON格式)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ==========================================
-- 2. 考勤记录表
-- ==========================================
DROP TABLE IF EXISTS attendance_logs;
CREATE TABLE attendance_logs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id INT NOT NULL COMMENT '用户ID',
    attendance_date DATE NOT NULL COMMENT '考勤日期',
    check_in_time DATETIME COMMENT '打卡时间',
    check_type VARCHAR(20) DEFAULT 'face' COMMENT '打卡方式: face(人脸) / password(密码)',
    status VARCHAR(20) DEFAULT 'normal' COMMENT '状态: normal(正常) / late(迟到) / early(早退)',
    match_score DECIMAL(5,2) COMMENT '人脸匹配置信度',
    photo_path VARCHAR(255) DEFAULT '' COMMENT '本次打卡照片路径',
    remark VARCHAR(255) DEFAULT '' COMMENT '备注',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, attendance_date),
    INDEX idx_date (attendance_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤记录表';

-- ==========================================
-- 3. 系统配置表（考勤时间设置等）
-- ==========================================
DROP TABLE IF EXISTS system_config;
CREATE TABLE system_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(50) NOT NULL UNIQUE COMMENT '配置键',
    config_value VARCHAR(255) NOT NULL COMMENT '配置值',
    description VARCHAR(255) DEFAULT '' COMMENT '配置说明',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- 插入默认配置
INSERT INTO system_config (config_key, config_value, description) VALUES
('work_start_time', '09:00', '上班打卡截止时间，超过算迟到'),
('work_end_time', '18:00', '下班时间'),
('late_threshold', '09:00', '迟到判定时间点');

-- ==========================================
-- 4. 插入默认管理员账号
-- 密码: admin123 (MD5加密)
-- ==========================================
INSERT INTO users (username, password, real_name, role, face_status)
VALUES ('admin', '0192023a7bbd73250516f069df18b500', '系统管理员', 'admin', 0);

-- 插入一个测试用户
-- 密码: 123456 (MD5加密)
INSERT INTO users (username, password, real_name, role, face_status)
VALUES ('zhangsan', 'e10adc3949ba59abbe56e057f20f883e', '张三', 'user', 0);

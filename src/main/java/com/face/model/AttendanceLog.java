package com.face.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * 考勤记录实体类
 */
public class AttendanceLog implements Serializable {

    private int id;
    private int userId;
    private String realName;     // 联表查询用（用户姓名）
    private Date attendanceDate;
    private Timestamp checkInTime;
    private String checkType;    // face / password
    private String status;       // normal / late / early / absent
    private double matchScore;   // 人脸匹配置信度
    private String photoPath;    // 打卡照片
    private String remark;
    private Timestamp createdAt;

    public AttendanceLog() {}

    // ==================== Getters & Setters ====================

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }

    public Date getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(Date attendanceDate) { this.attendanceDate = attendanceDate; }

    public Timestamp getCheckInTime() { return checkInTime; }
    public void setCheckInTime(Timestamp checkInTime) { this.checkInTime = checkInTime; }

    public String getCheckType() { return checkType; }
    public void setCheckType(String checkType) { this.checkType = checkType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public double getMatchScore() { return matchScore; }
    public void setMatchScore(double matchScore) { this.matchScore = matchScore; }

    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // ==================== 业务方法 ====================

    public String getStatusText() {
        if (status == null) return "未知";
        switch (status) {
            case "normal": return "✅正常";
            case "late": return "⚠️迟到";
            case "early": return "🔶早退";
            case "absent": return "❌缺勤";
            default: return status;
        }
    }

    public String getCheckTypeText() {
        if (checkType == null) return "-";
        switch (checkType) {
            case "face": return "人脸识别";
            case "password": return "密码打卡";
            default: return checkType;
        }
    }

    @Override
    public String toString() {
        return "AttendanceLog{id=" + id + ", userId=" + userId + ", date=" + attendanceDate + ", status=" + status + "}";
    }
}

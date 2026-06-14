package com.face.dao;

import com.face.model.AttendanceLog;
import com.face.util.DBUtil;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

import java.sql.Date;
import java.sql.SQLException;
import java.util.List;

/**
 * 考勤记录数据访问层
 */
public class AttendanceDao {

    private final QueryRunner qr = new QueryRunner(DBUtil.getDataSource());

    /**
     * 插入考勤记录
     */
    public int insert(AttendanceLog log) throws SQLException {
        String sql = "INSERT INTO attendance_logs (user_id, attendance_date, check_in_time, check_type, status, match_score, photo_path, remark) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        return qr.update(sql,
                log.getUserId(),
                new Date(System.currentTimeMillis()),
                log.getCheckInTime(),
                log.getCheckType(),
                log.getStatus(),
                log.getMatchScore(),
                log.getPhotoPath(),
                log.getRemark()
        );
    }

    /**
     * 检查用户今天是否已打卡
     */
    public AttendanceLog findTodayByUserId(int userId) throws SQLException {
        String sql = "SELECT a.id, a.user_id AS userId, u.real_name AS realName, " +
                "a.attendance_date AS attendanceDate, a.check_in_time AS checkInTime, " +
                "a.check_type AS checkType, a.status, a.match_score AS matchScore, " +
                "a.photo_path AS photoPath, a.remark, a.created_at AS createdAt " +
                "FROM attendance_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "WHERE a.user_id = ? AND a.attendance_date = ?";
        return qr.query(sql, new BeanHandler<>(AttendanceLog.class), userId, new Date(System.currentTimeMillis()));
    }

    /**
     * 查询用户的考勤记录（分页）
     */
    public List<AttendanceLog> findByUserId(int userId, int page, int pageSize) throws SQLException {
        String sql = "SELECT a.id, a.user_id AS userId, u.real_name AS realName, " +
                "a.attendance_date AS attendanceDate, a.check_in_time AS checkInTime, " +
                "a.check_type AS checkType, a.status, a.match_score AS matchScore, " +
                "a.photo_path AS photoPath, a.remark, a.created_at AS createdAt " +
                "FROM attendance_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "WHERE a.user_id = ? ORDER BY a.attendance_date DESC, a.check_in_time DESC LIMIT ?, ?";
        int offset = (page - 1) * pageSize;
        return qr.query(sql, new BeanListHandler<>(AttendanceLog.class), userId, offset, pageSize);
    }

    /**
     * 查询用户的考勤记录总数
     */
    public long countByUserId(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM attendance_logs WHERE user_id = ?";
        return qr.query(sql, new ScalarHandler<>(), userId);
    }

    /**
     * 查询某用户指定月份的考勤记录
     */
    public List<AttendanceLog> findByUserIdAndMonth(int userId, int year, int month) throws SQLException {
        String sql = "SELECT a.id, a.user_id AS userId, u.real_name AS realName, " +
                "a.attendance_date AS attendanceDate, a.check_in_time AS checkInTime, " +
                "a.check_type AS checkType, a.status, a.match_score AS matchScore, " +
                "a.photo_path AS photoPath, a.remark, a.created_at AS createdAt " +
                "FROM attendance_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "WHERE a.user_id = ? AND YEAR(a.attendance_date)=? AND MONTH(a.attendance_date)=? " +
                "ORDER BY a.attendance_date DESC";
        return qr.query(sql, new BeanListHandler<>(AttendanceLog.class), userId, year, month);
    }

    /**
     * 查询所有考勤记录（管理员用，分页）
     */
    public List<AttendanceLog> findAllByPage(int page, int pageSize) throws SQLException {
        String sql = "SELECT a.id, a.user_id AS userId, u.real_name AS realName, " +
                "a.attendance_date AS attendanceDate, a.check_in_time AS checkInTime, " +
                "a.check_type AS checkType, a.status, a.match_score AS matchScore, " +
                "a.photo_path AS photoPath, a.remark, a.created_at AS createdAt " +
                "FROM attendance_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "ORDER BY a.attendance_date DESC, a.check_in_time DESC LIMIT ?, ?";
        int offset = (page - 1) * pageSize;
        return qr.query(sql, new BeanListHandler<>(AttendanceLog.class), offset, pageSize);
    }

    /**
     * 查询考勤记录总数
     */
    public long countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM attendance_logs";
        return qr.query(sql, new ScalarHandler<>());
    }

    /**
     * 按日期范围查询（管理员用）
     */
    public List<AttendanceLog> findByDateRange(Date startDate, Date endDate, int page, int pageSize) throws SQLException {
        String sql = "SELECT a.id, a.user_id AS userId, u.real_name AS realName, " +
                "a.attendance_date AS attendanceDate, a.check_in_time AS checkInTime, " +
                "a.check_type AS checkType, a.status, a.match_score AS matchScore, " +
                "a.photo_path AS photoPath, a.remark, a.created_at AS createdAt " +
                "FROM attendance_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "WHERE a.attendance_date BETWEEN ? AND ? " +
                "ORDER BY a.attendance_date DESC, a.check_in_time DESC LIMIT ?, ?";
        int offset = (page - 1) * pageSize;
        return qr.query(sql, new BeanListHandler<>(AttendanceLog.class), startDate, endDate, offset, pageSize);
    }

    /**
     * 获取用户本月统计
     * 返回数组: [正常天数, 迟到天数, 早退天数, 缺勤天数]
     */
    public int[] getMonthStats(int userId, int year, int month) throws SQLException {
        String sql = "SELECT " +
                "SUM(CASE WHEN status='normal' THEN 1 ELSE 0 END) AS normalCount, " +
                "SUM(CASE WHEN status='late' THEN 1 ELSE 0 END) AS lateCount, " +
                "SUM(CASE WHEN status='early' THEN 1 ELSE 0 END) AS earlyCount, " +
                "SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) AS absentCount " +
                "FROM attendance_logs " +
                "WHERE user_id=? AND YEAR(attendance_date)=? AND MONTH(attendance_date)=?";
        Object[] result = qr.query(sql, (rs) -> {
            if (rs.next()) {
                return new Object[]{
                        rs.getInt("normalCount"),
                        rs.getInt("lateCount"),
                        rs.getInt("earlyCount"),
                        rs.getInt("absentCount")
                };
            }
            return new Object[]{0, 0, 0, 0};
        }, userId, year, month);

        if (result != null) {
            return new int[]{(int) result[0], (int) result[1], (int) result[2], (int) result[3]};
        }
        return new int[]{0, 0, 0, 0};
    }
}

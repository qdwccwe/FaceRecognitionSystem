package com.face.service;

import com.face.dao.AttendanceDao;
import com.face.model.AttendanceLog;

import java.sql.Date;
import java.sql.SQLException;
import java.util.List;

/**
 * 考勤记录业务逻辑层
 */
public class AttendanceService {

    private final AttendanceDao attendanceDao = new AttendanceDao();

    /**
     * 获取用户考勤记录（分页）
     */
    public List<AttendanceLog> getUserLogs(int userId, int page, int pageSize) throws SQLException {
        return attendanceDao.findByUserId(userId, page, pageSize);
    }

    /**
     * 获取用户考勤记录总数
     */
    public long getUserLogCount(int userId) throws SQLException {
        return attendanceDao.countByUserId(userId);
    }

    /**
     * 获取用户本月考勤记录
     */
    public List<AttendanceLog> getUserMonthLogs(int userId, int year, int month) throws SQLException {
        return attendanceDao.findByUserIdAndMonth(userId, year, month);
    }

    /**
     * 获取用户本月统计
     * [正常天数, 迟到天数, 早退天数, 缺勤天数]
     */
    public int[] getUserMonthStats(int userId, int year, int month) throws SQLException {
        return attendanceDao.getMonthStats(userId, year, month);
    }

    /**
     * 管理员：获取所有考勤记录（分页）
     */
    public List<AttendanceLog> getAllLogs(int page, int pageSize) throws SQLException {
        return attendanceDao.findAllByPage(page, pageSize);
    }

    /**
     * 管理员：获取考勤记录总数
     */
    public long getAllLogCount() throws SQLException {
        return attendanceDao.countAll();
    }

    /**
     * 管理员：按日期范围查询考勤记录
     */
    public List<AttendanceLog> getLogsByDateRange(Date start, Date end, int page, int pageSize) throws SQLException {
        return attendanceDao.findByDateRange(start, end, page, pageSize);
    }
}

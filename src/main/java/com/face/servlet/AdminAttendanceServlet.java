package com.face.servlet;

import com.face.model.AttendanceLog;
import com.face.service.AttendanceService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * 管理员 - 考勤概览控制器
 */
public class AdminAttendanceServlet extends HttpServlet {

    private final AttendanceService attendanceService = new AttendanceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int page = 1;
            String pageStr = request.getParameter("page");
            if (pageStr != null) page = Integer.parseInt(pageStr);
            int pageSize = 15;

            List<AttendanceLog> logs;
            long totalCount;

            // 日期范围筛选
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");

            if (startDateStr != null && !startDateStr.isEmpty() &&
                    endDateStr != null && !endDateStr.isEmpty()) {
                Date startDate = Date.valueOf(startDateStr);
                Date endDate = Date.valueOf(endDateStr);
                logs = attendanceService.getLogsByDateRange(startDate, endDate, page, pageSize);
                totalCount = logs.size();
                request.setAttribute("startDate", startDateStr);
                request.setAttribute("endDate", endDateStr);
            } else {
                logs = attendanceService.getAllLogs(page, pageSize);
                totalCount = attendanceService.getAllLogCount();
            }

            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            request.setAttribute("logs", logs);
            request.setAttribute("page", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "查询失败: " + e.getMessage());
        }

        request.getRequestDispatcher("/jsp/admin/attendance.jsp").forward(request, response);
    }
}

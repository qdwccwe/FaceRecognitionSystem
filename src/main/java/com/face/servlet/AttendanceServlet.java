package com.face.servlet;

import com.face.model.AttendanceLog;
import com.face.model.User;
import com.face.service.AttendanceService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * 考勤记录查询控制器
 */
public class AttendanceServlet extends HttpServlet {

    private final AttendanceService attendanceService = new AttendanceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        try {
            int page = 1;
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
            int pageSize = 10;

            // 获取筛选参数
            String yearStr = request.getParameter("year");
            String monthStr = request.getParameter("month");

            List<AttendanceLog> logs;
            long totalCount;

            if (yearStr != null && monthStr != null) {
                int year = Integer.parseInt(yearStr);
                int month = Integer.parseInt(monthStr);
                logs = attendanceService.getUserMonthLogs(loginUser.getId(), year, month);
                totalCount = logs.size();
            } else {
                logs = attendanceService.getUserLogs(loginUser.getId(), page, pageSize);
                totalCount = attendanceService.getUserLogCount(loginUser.getId());
            }

            // 获取本月统计
            LocalDate now = LocalDate.now();
            int[] monthStats = attendanceService.getUserMonthStats(loginUser.getId(), now.getYear(), now.getMonthValue());

            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            request.setAttribute("logs", logs);
            request.setAttribute("page", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("monthStats", monthStats);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "查询失败: " + e.getMessage());
        }

        request.getRequestDispatcher("/jsp/records.jsp").forward(request, response);
    }
}

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User, com.face.model.AttendanceLog, java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getRole())) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    request.setAttribute("currentPage", "attendance");

    List<AttendanceLog> logs = (List<AttendanceLog>) request.getAttribute("logs");
    Integer currentPage = (Integer) request.getAttribute("page");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>打卡概览 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .section { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .filter-bar { display: flex; gap: 15px; align-items: center; margin-bottom: 20px; flex-wrap: wrap; }
        .filter-bar input { padding: 8px 15px; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 14px; }
        .filter-bar button { padding: 8px 20px; background: #667eea; color: #fff; border: none; border-radius: 6px; cursor: pointer; font-weight: 500; }
        table { width: 100%; border-collapse: collapse; }
        table th { background: #f8f9fa; padding: 12px 15px; text-align: left; color: #555; font-size: 14px; border-bottom: 2px solid #e8e8e8; }
        table td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #666; }
        table tr:hover td { background: #f8f9ff; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; }
        .badge-success { background: #e8f5e9; color: #27ae60; }
        .badge-warning { background: #fff3e0; color: #ff9800; }
        .badge-danger { background: #ffeaea; color: #e74c3c; }
        .badge-info { background: #e3f2fd; color: #2196f3; }
        .pagination { display: flex; justify-content: center; gap: 10px; margin-top: 20px; }
        .pagination a, .pagination span { display: inline-block; padding: 8px 15px; border-radius: 6px; text-decoration: none; font-size: 14px; }
        .pagination a { background: #f0f0f0; color: #666; }
        .pagination a:hover { background: #667eea; color: #fff; }
        .pagination .current { background: #667eea; color: #fff; font-weight: 600; }
        .stats-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-bottom: 20px; }
        .stat-card { background: #f8f9fa; border-radius: 10px; padding: 20px; text-align: center; }
        .stat-card .num { font-size: 28px; font-weight: 700; color: #333; }
        .stat-card .lbl { font-size: 13px; color: #999; margin-top: 5px; }
    </style>
</head>
<body>
    <%@ include file="../header.jsp" %>

    <div class="main-container">
        <div class="content">
            <h2 style="margin-top:0;">📊 全员打卡概览</h2>

            <div class="section">
                <form action="${pageContext.request.contextPath}/admin/attendance" method="get" class="filter-bar">
                    <label>日期范围：</label>
                    <input type="date" name="startDate" value="<%= startDate != null ? startDate : "" %>">
                    <span>至</span>
                    <input type="date" name="endDate" value="<%= endDate != null ? endDate : "" %>">
                    <button type="submit">🔍 筛选</button>
                    <% if (startDate != null) { %><a href="${pageContext.request.contextPath}/admin/attendance" style="color:#667eea;font-size:14px;">清除筛选</a><% } %>
                </form>

                <table>
                    <thead>
                        <tr><th>#</th><th>姓名</th><th>日期</th><th>打卡时间</th><th>方式</th><th>相似度</th><th>状态</th></tr>
                    </thead>
                    <tbody>
                        <% if (logs != null && !logs.isEmpty()) {
                            int idx = 1;
                            for (AttendanceLog log : logs) { %>
                                <tr>
                                    <td><%= idx++ %></td>
                                    <td><%= log.getRealName() != null ? log.getRealName() : "-" %></td>
                                    <td><%= log.getAttendanceDate() %></td>
                                    <td><%= log.getCheckInTime() != null ? new java.text.SimpleDateFormat("HH:mm:ss").format(log.getCheckInTime()) : "--:--:--" %></td>
                                    <td><span class="badge badge-info"><%= log.getCheckTypeText() %></span></td>
                                    <td><%= log.getMatchScore() > 0 ? String.format("%.1f%%", log.getMatchScore()) : "-" %></td>
                                    <td><span class="badge <%= "normal".equals(log.getStatus()) ? "badge-success" : "late".equals(log.getStatus()) ? "badge-warning" : "badge-danger" %>"><%= log.getStatusText() %></span></td>
                                </tr>
                            <% }
                        } else { %>
                            <tr><td colspan="7" style="text-align:center;padding:40px;color:#ccc;">暂无打卡记录</td></tr>
                        <% } %>
                    </tbody>
                </table>

                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %><a href="?page=<%= currentPage - 1 %><%= startDate != null ? "&startDate="+startDate+"&endDate="+endDate : "" %>">上一页</a><% } %>
                    <% for (int p = 1; p <= totalPages; p++) {
                        if (p == currentPage) { %><span class="current"><%= p %></span><% }
                        else { %><a href="?page=<%= p %><%= startDate != null ? "&startDate="+startDate+"&endDate="+endDate : "" %>"><%= p %></a><% }
                    } %>
                    <% if (currentPage < totalPages) { %><a href="?page=<%= currentPage + 1 %><%= startDate != null ? "&startDate="+startDate+"&endDate="+endDate : "" %>">下一页</a><% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>

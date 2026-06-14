<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User, com.face.model.AttendanceLog, java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    request.setAttribute("currentPage", "records");

    List<AttendanceLog> logs = (List<AttendanceLog>) request.getAttribute("logs");
    Integer currentPage = (Integer) request.getAttribute("page");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Long totalCount = (Long) request.getAttribute("totalCount");
    int[] monthStats = (int[]) request.getAttribute("monthStats");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>考勤记录 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .section { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .section h3 { margin: 0 0 15px; color: #333; }
        .filter-bar { display: flex; gap: 15px; align-items: center; margin-bottom: 20px; flex-wrap: wrap; }
        .filter-bar select, .filter-bar input { padding: 8px 15px; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 14px; }
        .filter-bar button { padding: 8px 20px; background: #667eea; color: #fff; border: none; border-radius: 6px; cursor: pointer; font-weight: 500; }
        .filter-bar button:hover { background: #5a6fd6; }
        table { width: 100%; border-collapse: collapse; }
        table th { background: #f8f9fa; padding: 12px 15px; text-align: left; color: #555; font-weight: 600; font-size: 14px; border-bottom: 2px solid #e8e8e8; }
        table td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #666; }
        table tr:hover td { background: #f8f9ff; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; }
        .badge-success { background: #e8f5e9; color: #27ae60; }
        .badge-warning { background: #fff3e0; color: #ff9800; }
        .badge-danger { background: #ffeaea; color: #e74c3c; }
        .badge-info { background: #e3f2fd; color: #2196f3; }
        .stats-summary { display: flex; gap: 20px; margin-bottom: 20px; }
        .stat-item { flex: 1; text-align: center; padding: 15px; background: #f8f9fa; border-radius: 8px; }
        .stat-item .num { font-size: 24px; font-weight: 700; color: #333; }
        .stat-item .lbl { font-size: 12px; color: #999; }
        .pagination { display: flex; justify-content: center; gap: 10px; margin-top: 20px; }
        .pagination a, .pagination span { display: inline-block; padding: 8px 15px; border-radius: 6px; text-decoration: none; font-size: 14px; }
        .pagination a { background: #f0f0f0; color: #666; }
        .pagination a:hover { background: #667eea; color: #fff; }
        .pagination .current { background: #667eea; color: #fff; font-weight: 600; }
        .empty-state { text-align: center; padding: 60px 0; color: #ccc; }
        .empty-state .icon { font-size: 60px; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="main-container">
        <div class="content">
            <h2 style="margin-top:0;">📋 我的考勤记录</h2>

            <!-- 本月统计 -->
            <div class="stats-summary">
                <div class="stat-item">
                    <div class="num"><%= monthStats != null ? monthStats[0] : 0 %></div>
                    <div class="lbl">✅ 正常</div>
                </div>
                <div class="stat-item">
                    <div class="num"><%= monthStats != null ? monthStats[1] : 0 %></div>
                    <div class="lbl">⚠️ 迟到</div>
                </div>
                <div class="stat-item">
                    <div class="num"><%= monthStats != null ? monthStats[2] : 0 %></div>
                    <div class="lbl">🔶 早退</div>
                </div>
                <div class="stat-item">
                    <div class="num"><%= monthStats != null ? monthStats[3] : 0 %></div>
                    <div class="lbl">❌ 缺勤</div>
                </div>
                <div class="stat-item">
                    <div class="num"><%= monthStats != null ? (monthStats[0] + monthStats[1] + monthStats[2]) : 0 %></div>
                    <div class="lbl">📅 出勤天数</div>
                </div>
            </div>

            <!-- 筛选 -->
            <div class="section">
                <form action="${pageContext.request.contextPath}/attendance" method="get" class="filter-bar">
                    <label>月份筛选：</label>
                    <select name="year">
                        <% int y = java.time.LocalDate.now().getYear();
                           for (int i = y; i >= y - 2; i--) { %>
                            <option value="<%= i %>" <%= i == y ? "selected" : "" %>><%= i %>年</option>
                        <% } %>
                    </select>
                    <select name="month">
                        <% int m = java.time.LocalDate.now().getMonthValue();
                           for (int i = 1; i <= 12; i++) { %>
                            <option value="<%= i %>" <%= i == m ? "selected" : "" %>><%= i %>月</option>
                        <% } %>
                    </select>
                    <button type="submit">🔍 查询</button>
                    <a href="${pageContext.request.contextPath}/attendance" style="color:#667eea;font-size:14px;text-decoration:none;">显示全部</a>
                </form>

                <!-- 记录表格 -->
                <% if (logs != null && !logs.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>#</th><th>日期</th><th>打卡时间</th><th>打卡方式</th><th>相似度</th><th>状态</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int idx = 1;
                           for (AttendanceLog log : logs) { %>
                            <tr>
                                <td><%= idx++ %></td>
                                <td><%= log.getAttendanceDate() %></td>
                                <td><%= log.getCheckInTime() != null ? new java.text.SimpleDateFormat("HH:mm:ss").format(log.getCheckInTime()) : "--:--:--" %></td>
                                <td><span class="badge badge-info"><%= log.getCheckTypeText() %></span></td>
                                <td><%= log.getMatchScore() > 0 ? String.format("%.1f%%", log.getMatchScore()) : "-" %></td>
                                <td><span class="badge <%= "normal".equals(log.getStatus()) ? "badge-success" : "late".equals(log.getStatus()) ? "badge-warning" : "badge-danger" %>"><%= log.getStatusText() %></span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>

                <!-- 分页 -->
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %><a href="?page=<%= currentPage - 1 %>">上一页</a><% } %>
                    <% for (int p = 1; p <= totalPages; p++) {
                        if (p == currentPage) { %><span class="current"><%= p %></span><% }
                        else { %><a href="?page=<%= p %>"><%= p %></a><% }
                    } %>
                    <% if (currentPage < totalPages) { %><a href="?page=<%= currentPage + 1 %>">下一页</a><% } %>
                </div>
                <% } %>

                <% } else { %>
                <div class="empty-state">
                    <div class="icon">📭</div>
                    <p>暂无考勤记录</p>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User" %>
<%@ page import="com.face.service.AttendanceService" %>
<%@ page import="com.face.dao.AttendanceDao" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
    // 获取今日打卡状态
    AttendanceDao attDao = new AttendanceDao();
    com.face.model.AttendanceLog todayLog = attDao.findTodayByUserId(loginUser.getId());
    boolean checkedIn = (todayLog != null);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .stats-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #fff; border-radius: 12px; padding: 25px; text-align: center; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
        .stat-card .icon { font-size: 36px; margin-bottom: 10px; }
        .stat-card .value { font-size: 32px; font-weight: 700; color: #333; }
        .stat-card .label { font-size: 14px; color: #999; margin-top: 5px; }
        .stat-card.today { border-left: 4px solid #27ae60; }
        .stat-card.month { border-left: 4px solid #667eea; }
        .stat-card.anomaly { border-left: 4px solid #e74c3c; }
        .section { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .section h3 { margin: 0 0 15px; color: #333; font-size: 18px; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; }
        .records-table { width: 100%; border-collapse: collapse; }
        .records-table th { background: #f8f9fa; padding: 12px 15px; text-align: left; color: #555; font-weight: 600; font-size: 14px; border-bottom: 2px solid #e8e8e8; }
        .records-table td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #666; }
        .records-table tr:hover td { background: #f8f9ff; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; }
        .badge-success { background: #e8f5e9; color: #27ae60; }
        .badge-warning { background: #fff3e0; color: #ff9800; }
        .badge-danger { background: #ffeaea; color: #e74c3c; }
        .quick-actions { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .quick-action { display: flex; align-items: center; padding: 20px; background: #f8f9fa; border-radius: 10px; text-decoration: none; color: #333; transition: all 0.3s; }
        .quick-action:hover { background: #667eea; color: #fff; transform: translateY(-3px); box-shadow: 0 6px 20px rgba(102,126,234,0.3); }
        .quick-action .qa-icon { font-size: 32px; margin-right: 15px; }
        .quick-action .qa-title { font-size: 16px; font-weight: 600; }
        .quick-action .qa-desc { font-size: 12px; opacity: 0.8; margin-top: 3px; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="main-container">
        <div class="content">
            <!-- 欢迎 -->
            <h2 style="margin-top:0;">📊 欢迎回来，<%= loginUser.getRealName() %>！</h2>

            <!-- 统计卡片 -->
            <div class="stats-cards">
                <div class="stat-card today">
                    <div class="icon"><%= checkedIn ? "✅" : "⏰" %></div>
                    <div class="value"><%= checkedIn ? "已打卡" : "未打卡" %></div>
                    <div class="label">
                        <% if (checkedIn && todayLog.getCheckInTime() != null) { %>
                            今日 <%= new java.text.SimpleDateFormat("HH:mm:ss").format(todayLog.getCheckInTime()) %>
                        <% } else { %>
                            今天还没打卡哦
                        <% } %>
                    </div>
                </div>
                <div class="stat-card month">
                    <div class="icon">📅</div>
                    <%
                        java.time.LocalDate now = java.time.LocalDate.now();
                        int[] stats = attDao.getMonthStats(loginUser.getId(), now.getYear(), now.getMonthValue());
                        int totalDays = stats[0] + stats[1] + stats[2] + stats[3];
                    %>
                    <div class="value"><%= totalDays %> 天</div>
                    <div class="label">本月出勤</div>
                </div>
                <div class="stat-card anomaly">
                    <div class="icon">⚠️</div>
                    <div class="value"><%= stats[1] %> / <%= stats[3] %></div>
                    <div class="label">迟到 / 缺勤</div>
                </div>
            </div>

            <!-- 快捷操作 -->
            <div class="section">
                <h3>🚀 快捷操作</h3>
                <div class="quick-actions">
                    <a href="${pageContext.request.contextPath}/jsp/checkin.jsp" class="quick-action">
                        <span class="qa-icon">📸</span>
                        <div>
                            <div class="qa-title">人脸打卡</div>
                            <div class="qa-desc">通过人脸识别完成考勤签到</div>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/records.jsp" class="quick-action">
                        <span class="qa-icon">📋</span>
                        <div>
                            <div class="qa-title">考勤记录</div>
                            <div class="qa-desc">查看个人考勤历史记录</div>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/face_register.jsp" class="quick-action">
                        <span class="qa-icon">👤</span>
                        <div>
                            <div class="qa-title">人脸注册</div>
                            <div class="qa-desc"><%= loginUser.getFaceStatus() == 1 ? "重新采集人脸数据" : "上传人脸照片完成注册" %></div>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/profile.jsp" class="quick-action">
                        <span class="qa-icon">⚙️</span>
                        <div>
                            <div class="qa-title">个人中心</div>
                            <div class="qa-desc">管理个人信息和密码</div>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

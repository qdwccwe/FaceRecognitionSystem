<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User" %>
<%
    User headerUser = (User) session.getAttribute("loginUser");
    if (headerUser == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
    String navPage = (String) request.getAttribute("currentPage");
    if (navPage == null) {
        // 从URL推断当前页面
        String uri = request.getRequestURI();
        if (uri.contains("index")) navPage = "index";
        else if (uri.contains("checkin")) navPage = "checkin";
        else if (uri.contains("records")) navPage = "records";
        else if (uri.contains("face_register")) navPage = "face_register";
        else if (uri.contains("profile")) navPage = "profile";
        else if (uri.contains("user_manage")) navPage = "user_manage";
        else if (uri.contains("attendance")) navPage = "attendance";
    }
%>
<style>
    /* 头部导航 */
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 0 30px; display: flex; justify-content: space-between; align-items: center; height: 60px; box-shadow: 0 2px 10px rgba(0,0,0,0.15); position: sticky; top: 0; z-index: 100; }
    .header .logo { font-size: 20px; font-weight: 700; display: flex; align-items: center; gap: 10px; }
    .header .logo .icon { font-size: 24px; }
    .header .user-info { display: flex; align-items: center; gap: 15px; }
    .header .user-info span { color: rgba(255,255,255,0.9); font-size: 14px; }
    .header .btn-logout { padding: 6px 16px; background: rgba(255,255,255,0.2); color: #fff; border: 1px solid rgba(255,255,255,0.3); border-radius: 6px; font-size: 13px; cursor: pointer; text-decoration: none; transition: background 0.3s; }
    .header .btn-logout:hover { background: rgba(255,255,255,0.35); }
    /* 导航栏 */
    .navbar { background: #fff; padding: 0 30px; display: flex; border-bottom: 1px solid #e8e8e8; box-shadow: 0 1px 4px rgba(0,0,0,0.04); }
    .navbar a { display: inline-block; padding: 14px 22px; text-decoration: none; color: #666; font-size: 14px; font-weight: 500; border-bottom: 3px solid transparent; transition: all 0.3s; }
    .navbar a:hover { color: #667eea; background: #f8f9ff; }
    .navbar a.active { color: #667eea; border-bottom-color: #667eea; font-weight: 700; }
    /* 主内容区 */
    .main-container { max-width: 1200px; margin: 0 auto; padding: 30px; }
    .content { animation: fadeIn 0.3s; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
</style>

<!-- 头部 -->
<header class="header">
    <div class="logo">
        <span class="icon">🔷</span>
        人脸考勤打卡系统
    </div>
    <div class="user-info">
        <span>👤 <%= headerUser.getRealName() %>
            <% if ("admin".equals(headerUser.getRole())) { %>
                <span style="background:#ff9800;color:#fff;padding:2px 8px;border-radius:10px;font-size:11px;margin-left:5px;">管理员</span>
            <% } %>
        </span>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</header>

<!-- 导航栏 -->
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/jsp/index.jsp" class="<%= "index".equals(navPage) ? "active" : "" %>">🏠 首页</a>
    <a href="${pageContext.request.contextPath}/jsp/checkin.jsp" class="<%= "checkin".equals(navPage) ? "active" : "" %>">📸 人脸打卡</a>
    <a href="${pageContext.request.contextPath}/jsp/records.jsp" class="<%= "records".equals(navPage) ? "active" : "" %>">📋 考勤记录</a>
    <a href="${pageContext.request.contextPath}/jsp/face_register.jsp" class="<%= "face_register".equals(navPage) ? "active" : "" %>">👤 人脸注册</a>
    <a href="${pageContext.request.contextPath}/jsp/profile.jsp" class="<%= "profile".equals(navPage) ? "active" : "" %>">⚙️ 个人中心</a>
    <% if ("admin".equals(headerUser.getRole())) { %>
        <a href="${pageContext.request.contextPath}/admin/userManage" class="<%= "user_manage".equals(navPage) ? "active" : "" %>">👥 用户管理</a>
        <a href="${pageContext.request.contextPath}/admin/attendance" class="<%= "attendance".equals(navPage) ? "active" : "" %>">📊 打卡概览</a>
    <% } %>
</nav>

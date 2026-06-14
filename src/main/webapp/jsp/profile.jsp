<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    request.setAttribute("currentPage", "profile");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>个人中心 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .profile-area { display: flex; gap: 30px; flex-wrap: wrap; }
        .profile-card { flex: 1; min-width: 350px; background: #fff; border-radius: 12px; padding: 30px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
        .profile-card h3 { margin: 0 0 20px; color: #333; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 5px; color: #555; font-size: 14px; font-weight: 500; }
        .form-group input { width: 100%; padding: 10px 14px; border: 2px solid #e8e8e8; border-radius: 8px; font-size: 14px; box-sizing: border-box; transition: border-color 0.3s; }
        .form-group input:focus { outline: none; border-color: #667eea; }
        .form-group input:disabled { background: #f5f5f5; color: #999; }
        .btn { padding: 12px 35px; border: none; border-radius: 8px; font-size: 15px; cursor: pointer; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background: #667eea; color: #fff; }
        .btn-primary:hover { background: #5a6fd6; }
        .msg { padding: 10px 15px; border-radius: 6px; font-size: 14px; margin-bottom: 15px; }
        .msg-success { background: #f0fff4; color: #27ae60; border: 1px solid #d5ffd5; }
        .msg-error { background: #fff0f0; color: #e74c3c; border: 1px solid #ffd5d5; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="main-container">
        <div class="content">
            <h2 style="margin-top:0;">⚙️ 个人中心</h2>

            <% String succ = (String) request.getAttribute("success");
               String err = (String) request.getAttribute("error"); %>

            <div class="profile-area">
                <!-- 基本信息修改 -->
                <div class="profile-card">
                    <h3>👤 基本信息</h3>
                    <% if (succ != null) { %><div class="msg msg-success"><%= succ %></div><% } %>
                    <% if (err != null) { %><div class="msg msg-error"><%= err %></div><% } %>
                    <form action="${pageContext.request.contextPath}/profile" method="post">
                        <input type="hidden" name="action" value="updateInfo">
                        <div class="form-group">
                            <label>用户名</label>
                            <input type="text" value="<%= loginUser.getUsername() %>" disabled>
                        </div>
                        <div class="form-group">
                            <label>真实姓名</label>
                            <input type="text" name="realName" value="<%= loginUser.getRealName() != null ? loginUser.getRealName() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label>手机号</label>
                            <input type="text" name="phone" value="<%= loginUser.getPhone() != null ? loginUser.getPhone() : "" %>">
                        </div>
                        <div class="form-group">
                            <label>邮箱</label>
                            <input type="email" name="email" value="<%= loginUser.getEmail() != null ? loginUser.getEmail() : "" %>">
                        </div>
                        <div class="form-group">
                            <label>角色</label>
                            <input type="text" value="<%= "admin".equals(loginUser.getRole()) ? "管理员" : "普通用户" %>" disabled>
                        </div>
                        <button type="submit" class="btn btn-primary">💾 保存修改</button>
                    </form>
                </div>

                <!-- 修改密码 -->
                <div class="profile-card">
                    <h3>🔒 修改密码</h3>
                    <form action="${pageContext.request.contextPath}/profile" method="post" onsubmit="return checkPassword(this)">
                        <input type="hidden" name="action" value="changePassword">
                        <div class="form-group">
                            <label>旧密码</label>
                            <input type="password" name="oldPassword" placeholder="请输入旧密码" required>
                        </div>
                        <div class="form-group">
                            <label>新密码 (6-16位)</label>
                            <input type="password" name="newPassword" id="newPassword" placeholder="请输入新密码" required minlength="6">
                        </div>
                        <div class="form-group">
                            <label>确认新密码</label>
                            <input type="password" name="confirmPassword" placeholder="请再次输入新密码" required minlength="6">
                        </div>
                        <button type="submit" class="btn btn-primary">🔐 修改密码</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function checkPassword(form) {
            const np = form.newPassword.value;
            const cp = form.confirmPassword.value;
            if (np !== cp) { alert('两次输入的新密码不一致'); return false; }
            if (np.length < 6) { alert('新密码长度不能少于6位'); return false; }
            return true;
        }
    </script>
</body>
</html>

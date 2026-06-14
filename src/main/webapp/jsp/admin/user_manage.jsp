<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User, java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getRole())) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    request.setAttribute("currentPage", "user_manage");

    List<User> users = (List<User>) request.getAttribute("users");
    Integer currentPage = (Integer) request.getAttribute("page");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Long totalCount = (Long) request.getAttribute("totalCount");
    String keyword = (String) request.getAttribute("keyword");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>用户管理 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .section { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
        .search-box { display: flex; gap: 10px; }
        .search-box input { padding: 8px 15px; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 14px; width: 200px; }
        .search-box button { padding: 8px 20px; background: #667eea; color: #fff; border: none; border-radius: 6px; cursor: pointer; }
        .btn-add { padding: 8px 20px; background: #27ae60; color: #fff; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; }
        table { width: 100%; border-collapse: collapse; }
        table th { background: #f8f9fa; padding: 12px 15px; text-align: left; color: #555; font-size: 14px; border-bottom: 2px solid #e8e8e8; }
        table td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #666; }
        table tr:hover td { background: #f8f9ff; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; }
        .badge-success { background: #e8f5e9; color: #27ae60; }
        .badge-danger { background: #ffeaea; color: #e74c3c; }
        .badge-admin { background: #fff3e0; color: #ff9800; }
        .btn-sm { padding: 5px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 12px; }
        .btn-edit { background: #e3f2fd; color: #2196f3; }
        .btn-delete { background: #ffeaea; color: #e74c3c; }
        .pagination { display: flex; justify-content: center; gap: 10px; margin-top: 20px; }
        .pagination a, .pagination span { display: inline-block; padding: 8px 15px; border-radius: 6px; text-decoration: none; font-size: 14px; }
        .pagination a { background: #f0f0f0; color: #666; }
        .pagination a:hover { background: #667eea; color: #fff; }
        .pagination .current { background: #667eea; color: #fff; font-weight: 600; }
        .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; justify-content:center; align-items:center; }
        .modal-overlay.active { display: flex; }
        .modal-box { background: #fff; border-radius: 12px; padding: 30px; width: 420px; }
        .modal-box h3 { margin: 0 0 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-size: 14px; color: #555; }
        .form-group input, .form-group select { width: 100%; padding: 8px 12px; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 14px; box-sizing: border-box; }
        .modal-btns { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
    </style>
</head>
<body>
    <%@ include file="../header.jsp" %>

    <div class="main-container">
        <div class="content">
            <h2 style="margin-top:0;">👥 用户管理</h2>

            <div class="section">
                <div class="toolbar">
                    <form action="${pageContext.request.contextPath}/admin/userManage" method="get" class="search-box">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="keyword" placeholder="🔍 搜索用户名或姓名..." value="<%= keyword != null ? keyword : "" %>">
                        <button type="submit">搜索</button>
                        <% if (keyword != null) { %><a href="${pageContext.request.contextPath}/admin/userManage" style="color:#667eea;font-size:14px;">清除</a><% } %>
                    </form>
                    <button class="btn-add" onclick="openAddModal()">+ 添加用户</button>
                </div>

                <table>
                    <thead>
                        <tr><th>ID</th><th>用户名</th><th>姓名</th><th>角色</th><th>人脸状态</th><th>注册时间</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <% if (users != null && !users.isEmpty()) {
                            for (User u : users) { %>
                                <tr>
                                    <td><%= u.getId() %></td>
                                    <td><%= u.getUsername() %></td>
                                    <td><%= u.getRealName() %></td>
                                    <td><span class="badge <%= "admin".equals(u.getRole()) ? "badge-admin" : "" %>"><%= "admin".equals(u.getRole()) ? "管理员" : "用户" %></span></td>
                                    <td><span class="badge <%= u.getFaceStatus() == 1 ? "badge-success" : "badge-danger" %>"><%= u.getFaceStatus() == 1 ? "✅ 已注册" : "❌ 未注册" %></span></td>
                                    <td><%= u.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(u.getCreatedAt()) : "-" %></td>
                                    <td>
                                        <button class="btn-sm btn-delete" onclick="deleteUser(<%= u.getId() %>, '<%= u.getUsername() %>')">🗑️ 删除</button>
                                    </td>
                                </tr>
                            <% }
                        } else { %>
                            <tr><td colspan="7" style="text-align:center;padding:40px;color:#ccc;">暂无用户数据</td></tr>
                        <% } %>
                    </tbody>
                </table>

                <% if (totalPages > 1 && keyword == null) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %><a href="?page=<%= currentPage - 1 %>">上一页</a><% } %>
                    <% for (int p = 1; p <= totalPages; p++) {
                        if (p == currentPage) { %><span class="current"><%= p %></span><% }
                        else { %><a href="?page=<%= p %>"><%= p %></a><% }
                    } %>
                    <% if (currentPage < totalPages) { %><a href="?page=<%= currentPage + 1 %>">下一页</a><% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- 添加用户弹窗 -->
    <div class="modal-overlay" id="addModal">
        <div class="modal-box">
            <h3>➕ 添加用户</h3>
            <form id="addForm" onsubmit="addUser(event)">
                <div class="form-group"><label>用户名 *</label><input type="text" name="username" required></div>
                <div class="form-group"><label>密码 *</label><input type="password" name="password" required minlength="6"></div>
                <div class="form-group"><label>真实姓名 *</label><input type="text" name="realName" required></div>
                <div class="form-group"><label>角色</label><select name="role"><option value="user">普通用户</option><option value="admin">管理员</option></select></div>
                <div class="modal-btns">
                    <button type="button" class="btn-sm" style="background:#eee;color:#666;" onclick="closeAddModal()">取消</button>
                    <button type="submit" class="btn-sm" style="background:#27ae60;color:#fff;">确认添加</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        const ctx = '${pageContext.request.contextPath}';
        function openAddModal() { document.getElementById('addModal').classList.add('active'); }
        function closeAddModal() { document.getElementById('addModal').classList.remove('active'); }

        function addUser(e) {
            e.preventDefault();
            const form = document.getElementById('addForm');
            const fd = new FormData(form);
            fd.append('action', 'add');
            fetch(ctx + '/admin/userManage', { method: 'POST', body: new URLSearchParams(fd) })
                .then(r => r.json())
                .then(data => { alert(data.message); if (data.success) location.reload(); });
        }

        function deleteUser(id, name) {
            if (!confirm('确定要删除用户 "' + name + '" 吗？\n此操作不可恢复，该用户的考勤记录也将一并删除。')) return;
            const fd = new URLSearchParams();
            fd.append('action', 'delete');
            fd.append('userId', id);
            fetch(ctx + '/admin/userManage', { method: 'POST', body: fd })
                .then(r => r.json())
                .then(data => { alert(data.message); if (data.success) location.reload(); });
        }
    </script>
</body>
</html>

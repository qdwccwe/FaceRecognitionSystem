<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>403 - 禁止访问</title>
    <style>
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .error-box { text-align: center; background: #fff; padding: 60px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
        .error-code { font-size: 80px; font-weight: bold; color: #ff9800; margin: 0; }
        .error-msg { font-size: 20px; color: #666; margin: 20px 0; }
        .back-btn { display: inline-block; padding: 12px 30px; background: #4a90d9; color: #fff; text-decoration: none; border-radius: 6px; font-size: 16px; }
        .back-btn:hover { background: #357abd; }
    </style>
</head>
<body>
    <div class="error-box">
        <p class="error-code">403</p>
        <p class="error-msg">权限不足，禁止访问此页面</p>
        <a href="${pageContext.request.contextPath}/jsp/index.jsp" class="back-btn">返回首页</a>
    </div>
</body>
</html>

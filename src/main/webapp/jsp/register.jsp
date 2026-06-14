<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .register-container {
            display: flex; justify-content: center; align-items: center;
            min-height: 100vh; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 30px 0;
        }
        .register-box {
            background: #fff; border-radius: 16px; padding: 40px;
            width: 480px; box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .register-box h2 { text-align: center; color: #333; margin: 0 0 10px; }
        .register-box .subtitle { text-align: center; color: #999; font-size: 14px; margin-bottom: 25px; }
        .form-row { display: flex; gap: 15px; }
        .form-row .form-group { flex: 1; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 5px; color: #555; font-size: 14px; font-weight: 500; }
        .form-group input, .form-group select { width: 100%; padding: 10px 14px; border: 2px solid #e8e8e8; border-radius: 8px; font-size: 14px; transition: border-color 0.3s; box-sizing: border-box; }
        .form-group input:focus { outline: none; border-color: #667eea; }
        .required { color: #e74c3c; }
        .photo-upload { text-align: center; margin-bottom: 18px; }
        .photo-box { width: 150px; height: 180px; margin: 0 auto 10px; border: 2px dashed #ddd; border-radius: 10px; display: flex; flex-direction: column; justify-content: center; align-items: center; cursor: pointer; transition: border-color 0.3s; overflow: hidden; }
        .photo-box:hover { border-color: #667eea; }
        .photo-box img { width: 100%; height: 100%; object-fit: cover; display: none; }
        .photo-box .placeholder { font-size: 40px; color: #ccc; }
        .photo-box .text { font-size: 12px; color: #999; margin-top: 5px; }
        .photo-box.has-photo .placeholder, .photo-box.has-photo .text { display: none; }
        .photo-box.has-photo img { display: block; }
        .btn { width: 100%; padding: 13px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102,126,234,0.4); }
        .error-msg { background: #fff0f0; color: #e74c3c; padding: 10px 15px; border-radius: 6px; font-size: 14px; margin-bottom: 15px; border: 1px solid #ffd5d5; }
        .back-link { text-align: center; margin-top: 20px; font-size: 14px; }
        .back-link a { color: #667eea; text-decoration: none; }
    </style>
</head>
<body>
<div class="register-container">
    <div class="register-box">
        <h2>📝 用户注册</h2>
        <p class="subtitle">创建账号并上传人脸照片</p>

        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
            <div class="error-msg"><%= error %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/register" method="post" enctype="multipart/form-data" id="registerForm">
            <div class="form-row">
                <div class="form-group">
                    <label><span class="required">*</span> 用户名</label>
                    <input type="text" name="username" placeholder="登录账号" required>
                </div>
                <div class="form-group">
                    <label><span class="required">*</span> 真实姓名</label>
                    <input type="text" name="realName" placeholder="用于打卡显示" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label><span class="required">*</span> 密码 (6-16位)</label>
                    <input type="password" name="password" placeholder="请输入密码" required minlength="6">
                </div>
                <div class="form-group">
                    <label><span class="required">*</span> 确认密码</label>
                    <input type="password" name="confirmPassword" placeholder="请再次输入密码" required minlength="6">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>手机号</label>
                    <input type="text" name="phone" placeholder="选填">
                </div>
                <div class="form-group">
                    <label>邮箱</label>
                    <input type="email" name="email" placeholder="选填">
                </div>
            </div>

            <!-- 人脸照片上传 -->
            <div class="photo-upload">
                <label style="font-weight:500;color:#555;display:block;margin-bottom:8px;">📷 人脸照片 <span style="color:#999;font-weight:400;">(选填，可在登录后补充)</span></label>
                <div class="photo-box" id="photoBox" onclick="document.getElementById('facePhoto').click()">
                    <span class="placeholder">📷</span>
                    <span class="text">点击上传人脸照片</span>
                    <img id="previewImg" src="" alt="预览">
                </div>
                <input type="file" id="facePhoto" name="facePhoto" accept="image/*" style="display:none;" onchange="previewPhoto(this)">
                <p style="font-size:12px;color:#999;margin-top:5px;">请上传正面、光线充足、五官清晰的照片</p>
            </div>

            <button type="submit" class="btn btn-primary">注 册</button>
        </form>

        <div class="back-link">
            已有账号？<a href="${pageContext.request.contextPath}/jsp/login.jsp">返回登录 →</a>
        </div>
    </div>
</div>

<script>
    function previewPhoto(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('previewImg').src = e.target.result;
                document.getElementById('photoBox').classList.add('has-photo');
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .login-container {
            display: flex; justify-content: center; align-items: center;
            min-height: 100vh; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .login-box {
            background: #fff; border-radius: 16px; padding: 50px 40px;
            width: 420px; box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .login-logo { text-align: center; margin-bottom: 30px; }
        .login-logo .icon { font-size: 60px; }
        .login-logo h1 { font-size: 24px; color: #333; margin: 10px 0 0; }
        .login-logo p { color: #999; font-size: 14px; margin-top: 5px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; font-weight: 500; }
        .form-group input { width: 100%; padding: 12px 15px; border: 2px solid #e8e8e8; border-radius: 8px; font-size: 15px; transition: border-color 0.3s; box-sizing: border-box; }
        .form-group input:focus { outline: none; border-color: #667eea; }
        .btn { width: 100%; padding: 13px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102,126,234,0.4); }
        .btn-face { background: #fff; color: #667eea; border: 2px solid #667eea; margin-top: 10px; }
        .btn-face:hover { background: #667eea; color: #fff; }
        .divider { display: flex; align-items: center; margin: 20px 0; color: #ccc; font-size: 14px; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: #e8e8e8; }
        .divider span { padding: 0 15px; }
        .error-msg { background: #fff0f0; color: #e74c3c; padding: 10px 15px; border-radius: 6px; font-size: 14px; margin-bottom: 15px; border: 1px solid #ffd5d5; }
        .success-msg { background: #f0fff4; color: #27ae60; padding: 10px 15px; border-radius: 6px; font-size: 14px; margin-bottom: 15px; border: 1px solid #d5ffd5; }
        .register-link { text-align: center; margin-top: 20px; font-size: 14px; color: #999; }
        .register-link a { color: #667eea; text-decoration: none; font-weight: 500; }
        .register-link a:hover { text-decoration: underline; }
        /* 人脸登录弹窗 */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 1000; justify-content: center; align-items: center; }
        .modal-overlay.active { display: flex; }
        .modal-box { background: #fff; border-radius: 16px; padding: 30px; width: 500px; text-align: center; }
        .modal-box h2 { margin-top: 0; color: #333; }
        .camera-area { width: 100%; height: 300px; background: #f0f0f0; border-radius: 10px; margin: 20px 0; display: flex; flex-direction: column; justify-content: center; align-items: center; overflow: hidden; position: relative; }
        .camera-area video { width: 100%; height: 100%; object-fit: cover; }
        .camera-area canvas { display: none; }
        .modal-btns { display: flex; gap: 15px; justify-content: center; }
        .btn-capture { padding: 12px 40px; background: #667eea; color: #fff; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; }
        .btn-close { padding: 12px 40px; background: #eee; color: #666; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; }
        #faceResult { margin-top: 15px; font-size: 15px; }
    </style>
</head>
<body>
<div class="login-container">
    <div class="login-box">
        <div class="login-logo">
            <div class="icon">🔷</div>
            <h1>人脸考勤打卡系统</h1>
            <p>Face Recognition Attendance</p>
        </div>

        <%-- 错误提示 --%>
        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
            <div class="error-msg"><%= error %></div>
        <% } %>
        <% String success = (String) request.getAttribute("success");
           if (success != null) { %>
            <div class="success-msg"><%= success %></div>
        <% } %>

        <%-- 账密登录表单 --%>
        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-group">
                <label>👤 用户名</label>
                <input type="text" name="username" placeholder="请输入用户名" required>
            </div>
            <div class="form-group">
                <label>🔒 密码</label>
                <input type="password" name="password" placeholder="请输入密码" required>
            </div>
            <button type="submit" class="btn btn-primary">账 密 登 录</button>
        </form>

        <div class="divider"><span>或</span></div>

        <button class="btn btn-face" onclick="openFaceLogin()">📷 人脸识别登录</button>

        <div class="register-link">
            还没有账号？<a href="${pageContext.request.contextPath}/jsp/register.jsp">立即注册 →</a>
        </div>
    </div>
</div>

<%-- 人脸识别登录弹窗 --%>
<div class="modal-overlay" id="faceModal">
    <div class="modal-box">
        <h2>📷 人脸识别登录</h2>
        <p style="color:#888;font-size:14px;">请将面部对准摄像头，确保光线充足</p>
        <div class="camera-area">
            <video id="faceVideo" autoplay playsinline></video>
            <canvas id="faceCanvas"></canvas>
            <div id="cameraPlaceholder" style="color:#999;font-size:40px;">📷</div>
        </div>
        <div class="modal-btns">
            <button class="btn-close" onclick="closeFaceLogin()">取消</button>
            <button class="btn-capture" onclick="captureAndLogin()">📸 拍照登录</button>
        </div>
        <p id="faceResult"></p>
    </div>
</div>

<script>
    let videoStream = null;

    async function openFaceLogin() {
        document.getElementById('faceModal').classList.add('active');
        document.getElementById('faceResult').innerHTML = '';
        try {
            videoStream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480 } });
            document.getElementById('faceVideo').srcObject = videoStream;
            document.getElementById('cameraPlaceholder').style.display = 'none';
        } catch (e) {
            document.getElementById('cameraPlaceholder').innerHTML = '<span style="color:#e74c3c;">⚠️ 无法访问摄像头</span>';
            console.error('摄像头访问失败:', e);
        }
    }

    function closeFaceLogin() {
        document.getElementById('faceModal').classList.remove('active');
        if (videoStream) {
            videoStream.getTracks().forEach(t => t.stop());
            videoStream = null;
        }
    }

    function captureAndLogin() {
        const video = document.getElementById('faceVideo');
        const canvas = document.getElementById('faceCanvas');
        canvas.width = video.videoWidth || 640;
        canvas.height = video.videoHeight || 480;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0);
        canvas.toBlob(function(blob) {
            const formData = new FormData();
            formData.append('faceImage', blob, 'face_login.jpg');
            document.getElementById('faceResult').innerHTML = '<span style="color:#667eea;">识别中...</span>';

            fetch('${pageContext.request.contextPath}/faceLogin', {
                method: 'POST',
                body: formData
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('faceResult').innerHTML = '<span style="color:#27ae60;">✅ ' + data.message + '</span>';
                    setTimeout(() => { window.location.href = '${pageContext.request.contextPath}/jsp/index.jsp'; }, 1000);
                } else {
                    document.getElementById('faceResult').innerHTML = '<span style="color:#e74c3c;">❌ ' + data.message + '</span>';
                }
            })
            .catch(err => {
                document.getElementById('faceResult').innerHTML = '<span style="color:#e74c3c;">请求失败</span>';
            });
        }, 'image/jpeg');
    }
</script>
</body>
</html>

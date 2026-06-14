<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    request.setAttribute("currentPage", "face_register");
    boolean hasFace = loginUser.getFaceStatus() == 1;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>人脸注册 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .section { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .register-area { display: flex; gap: 30px; flex-wrap: wrap; }
        .camera-panel { flex: 1; min-width: 350px; text-align: center; }
        .camera-panel h3 { margin: 0 0 15px; color: #333; }
        .camera-view { width: 100%; height: 300px; background: #1a1a2e; border-radius: 10px; position: relative; overflow: hidden; display: flex; justify-content: center; align-items: center; }
        .camera-view video { width: 100%; height: 100%; object-fit: cover; }
        .camera-view canvas { display: none; }
        .camera-view .overlay-text { position: absolute; color: rgba(255,255,255,0.6); font-size: 16px; }
        .btn { padding: 12px 30px; border: none; border-radius: 8px; font-size: 15px; cursor: pointer; font-weight: 600; transition: all 0.3s; margin: 5px; }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
        .btn-primary:hover { transform: translateY(-2px); }
        .btn-outline { background: #fff; color: #667eea; border: 2px solid #667eea; }
        .info-panel { width: 350px; }
        .status-card { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); text-align: center; }
        .status-icon { font-size: 50px; }
        .status-text { font-size: 18px; font-weight: 600; margin: 10px 0; }
        .face-preview { width: 150px; height: 180px; border-radius: 10px; object-fit: cover; margin: 15px auto; border: 3px solid #e8e8e8; background: #f5f5f5; display: flex; align-items: center; justify-content: center; font-size: 40px; color: #ccc; }
        .tips { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-top: 20px; }
        .tips h4 { margin: 0 0 10px; }
        .tips ul { margin: 0; padding-left: 20px; color: #888; font-size: 13px; line-height: 1.8; }
        .result-msg { margin-top: 15px; font-size: 15px; font-weight: 500; }
        .success-msg { color: #27ae60; }
        .error-msg { color: #e74c3c; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="main-container">
        <div class="content">
            <h2 style="margin-top:0;">👤 人脸数据管理</h2>

            <div class="register-area">
                <!-- 采集区域 -->
                <div class="camera-panel">
                    <div class="section">
                        <h3>📷 <%= hasFace ? "重新采集人脸" : "采集人脸数据" %></h3>
                        <div class="camera-view">
                            <video id="cameraVideo" autoplay playsinline></video>
                            <canvas id="cameraCanvas"></canvas>
                            <div class="overlay-text" id="cameraPlaceholder">📷 正在启动摄像头...</div>
                        </div>
                        <div style="margin-top:15px;">
                            <button class="btn btn-outline" onclick="retryCamera()">🔄 重启摄像头</button>
                            <button class="btn btn-primary" id="btnCapture" onclick="captureAndRegister()">📸 拍照采集</button>
                        </div>
                        <div style="margin-top:15px;">
                            <label for="fileUpload" style="cursor:pointer;color:#667eea;text-decoration:underline;">📁 或从本地上传照片</label>
                            <input type="file" id="fileUpload" accept="image/*" onchange="uploadAndRegister(this)" style="display:none;">
                        </div>
                        <div id="regResult" class="result-msg"></div>
                    </div>
                </div>

                <!-- 状态面板 -->
                <div class="info-panel">
                    <div class="status-card">
                        <h3>📌 当前状态</h3>
                        <div class="status-icon"><%= hasFace ? "✅" : "❌" %></div>
                        <div class="status-text" style="color:<%= hasFace ? "#27ae60" : "#e74c3c" %>;">
                            <%= hasFace ? "已注册人脸" : "未注册人脸" %>
                        </div>
                        <% if (hasFace && loginUser.getFaceImagePath() != null && !loginUser.getFaceImagePath().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/uploads/faces/<%= new java.io.File(loginUser.getFaceImagePath()).getName() %>"
                                 alt="人脸照片" class="face-preview"
                                 onerror="this.style.display='none';">
                        <% } else { %>
                            <div class="face-preview">👤</div>
                        <% } %>
                        <p style="font-size:13px;color:#999;">
                            <% if (hasFace) { %>
                                请确保人脸照片清晰可用<br>如需更新，请重新采集
                            <% } else { %>
                                请尽快注册人脸<br>否则无法使用人脸打卡功能
                            <% } %>
                        </p>
                    </div>

                    <div class="tips">
                        <h4>💡 采集要求</h4>
                        <ul>
                            <li>正面面对摄像头，五官清晰可见</li>
                            <li>光线充足均匀，避免逆光或阴影</li>
                            <li>摘掉帽子、墨镜等遮挡物</li>
                            <li>保持自然表情，不要做夸张动作</li>
                            <li>照片中只出现一个人脸</li>
                            <li>背景简洁，避免复杂背景干扰</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        let stream = null;
        const ctx = '${pageContext.request.contextPath}';

        async function initCamera() {
            try {
                stream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480, facingMode: 'user' } });
                document.getElementById('cameraVideo').srcObject = stream;
                document.getElementById('cameraPlaceholder').style.display = 'none';
            } catch(e) {
                document.getElementById('cameraPlaceholder').textContent = '⚠️ 无法访问摄像头';
                document.getElementById('btnCapture').disabled = true;
            }
        }

        function retryCamera() {
            if (stream) { stream.getTracks().forEach(t => t.stop()); }
            document.getElementById('btnCapture').disabled = false;
            document.getElementById('cameraPlaceholder').style.display = 'flex';
            document.getElementById('cameraPlaceholder').textContent = '📷 正在启动摄像头...';
            initCamera();
        }

        function captureAndRegister() {
            const video = document.getElementById('cameraVideo');
            if (!stream) { alert('摄像头未就绪'); return; }
            const canvas = document.getElementById('cameraCanvas');
            canvas.width = video.videoWidth || 640;
            canvas.height = video.videoHeight || 480;
            canvas.getContext('2d').drawImage(video, 0, 0);
            canvas.toBlob(blob => sendRegisterImage(blob), 'image/jpeg');
        }

        function uploadAndRegister(input) {
            if (input.files && input.files[0]) { sendRegisterImage(input.files[0]); }
        }

        function sendRegisterImage(blob) {
            showResult('⏳ 正在处理...', '');
            const formData = new FormData();
            formData.append('faceImage', blob, 'face_reg.jpg');
            fetch(ctx + '/faceRegister', { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        showResult('✅ ' + data.message, 'success');
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showResult('❌ ' + data.message, 'error');
                    }
                })
                .catch(err => showResult('❌ 请求失败: ' + err.message, 'error'));
        }

        function showResult(msg, type) {
            const el = document.getElementById('regResult');
            el.textContent = msg;
            el.className = 'result-msg ' + (type === 'success' ? 'success-msg' : 'error-msg');
        }

        initCamera();
    </script>
</body>
</html>

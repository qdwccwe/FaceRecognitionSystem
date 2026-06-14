<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.face.model.User" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    request.setAttribute("currentPage", "checkin");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>人脸打卡 - 人脸考勤打卡系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .checkin-area { display: flex; gap: 30px; flex-wrap: wrap; }
        .camera-panel { flex: 1; min-width: 400px; background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); text-align: center; }
        .camera-panel h3 { margin: 0 0 15px; color: #333; }
        .camera-view { width: 100%; height: 350px; background: #1a1a2e; border-radius: 10px; position: relative; overflow: hidden; display: flex; justify-content: center; align-items: center; }
        .camera-view video { width: 100%; height: 100%; object-fit: cover; }
        .camera-view canvas { display: none; }
        .camera-view .overlay-text { position: absolute; color: rgba(255,255,255,0.6); font-size: 18px; }
        .camera-controls { margin-top: 20px; display: flex; gap: 15px; justify-content: center; }
        .btn { padding: 12px 35px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102,126,234,0.4); }
        .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
        .btn-outline { background: #fff; color: #667eea; border: 2px solid #667eea; }
        .btn-outline:hover { background: #f0f0ff; }
        .result-panel { width: 350px; }
        .result-card { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); text-align: center; }
        .result-card h3 { margin: 0 0 15px; }
        .result-icon { font-size: 60px; margin: 20px 0; }
        .result-msg { font-size: 18px; font-weight: 600; margin: 10px 0; }
        .result-detail { font-size: 14px; color: #888; margin: 5px 0; }
        .tips-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-top: 20px; }
        .tips-card h4 { margin: 0 0 10px; color: #333; }
        .tips-card ul { margin: 0; padding-left: 20px; color: #888; font-size: 13px; line-height: 1.8; }
        .file-upload-area { margin-top: 10px; }
        .file-upload-area input { display: none; }
        .file-upload-area label { cursor: pointer; color: #667eea; font-size: 14px; text-decoration: underline; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="main-container">
        <div class="content">
            <h2 style="margin-top:0;">📸 人脸识别打卡</h2>

            <div class="checkin-area">
                <!-- 摄像头区域 -->
                <div class="camera-panel">
                    <h3>📷 摄像头实时画面</h3>
                    <div class="camera-view">
                        <video id="cameraVideo" autoplay playsinline></video>
                        <canvas id="cameraCanvas"></canvas>
                        <div class="overlay-text" id="cameraPlaceholder">📷 正在启动摄像头...</div>
                    </div>
                    <div class="camera-controls">
                        <button class="btn btn-outline" onclick="retryCamera()">🔄 重新启动</button>
                        <button class="btn btn-primary" id="btnCapture" onclick="captureAndCheckin()">📸 拍照打卡</button>
                    </div>
                    <div class="file-upload-area">
                        <label for="fileUpload">📁 或上传照片打卡</label>
                        <input type="file" id="fileUpload" accept="image/*" onchange="uploadAndCheckin(this)">
                    </div>
                </div>

                <!-- 结果面板 -->
                <div class="result-panel">
                    <div class="result-card" id="resultCard">
                        <h3>📋 打卡结果</h3>
                        <div class="result-icon" id="resultIcon">⏳</div>
                        <div class="result-msg" id="resultMsg" style="color:#888;">等待打卡...</div>
                        <div class="result-detail" id="resultDetail"></div>
                    </div>
                    <div class="tips-card">
                        <h4>💡 打卡提示</h4>
                        <ul>
                            <li>请正面对准摄像头</li>
                            <li>确保光线充足、面部无遮挡</li>
                            <li>保持与摄像头适当距离</li>
                            <li>每天只需打卡一次</li>
                            <li>9:00后打卡记为迟到</li>
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
                const video = document.getElementById('cameraVideo');
                video.srcObject = stream;
                document.getElementById('cameraPlaceholder').style.display = 'none';
            } catch (e) {
                document.getElementById('cameraPlaceholder').textContent = '⚠️ 无法访问摄像头，请使用上传照片方式';
                document.getElementById('btnCapture').disabled = true;
                console.error(e);
            }
        }

        function retryCamera() {
            if (stream) { stream.getTracks().forEach(t => t.stop()); }
            document.getElementById('btnCapture').disabled = false;
            document.getElementById('cameraPlaceholder').style.display = 'flex';
            document.getElementById('cameraPlaceholder').textContent = '📷 正在启动摄像头...';
            initCamera();
        }

        function captureAndCheckin() {
            const video = document.getElementById('cameraVideo');
            if (!stream) { alert('摄像头未就绪，请重试或使用上传方式'); return; }
            const canvas = document.getElementById('cameraCanvas');
            canvas.width = video.videoWidth || 640;
            canvas.height = video.videoHeight || 480;
            canvas.getContext('2d').drawImage(video, 0, 0);
            canvas.toBlob(blob => sendCheckinImage(blob), 'image/jpeg');
        }

        function uploadAndCheckin(input) {
            if (input.files && input.files[0]) {
                sendCheckinImage(input.files[0]);
            }
        }

        function sendCheckinImage(blob) {
            updateResult('⏳', '识别中...', '正在比对人脸数据');
            document.getElementById('btnCapture').disabled = true;

            const formData = new FormData();
            formData.append('checkinImage', blob, 'checkin.jpg');

            fetch(ctx + '/checkin', { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    document.getElementById('btnCapture').disabled = false;
                    if (data.success) {
                        updateResult('✅', data.message, '相似度: ' + (data.similarity || '--') + '%');
                    } else if (data.already) {
                        updateResult('⏰', data.message, '');
                    } else {
                        updateResult('❌', data.message, '请重试');
                    }
                })
                .catch(err => {
                    document.getElementById('btnCapture').disabled = false;
                    updateResult('❌', '网络请求失败', err.message);
                });
        }

        function updateResult(icon, msg, detail) {
            document.getElementById('resultIcon').textContent = icon;
            document.getElementById('resultMsg').textContent = msg;
            document.getElementById('resultMsg').style.color = icon === '✅' ? '#27ae60' : icon === '⏳' ? '#888' : '#e74c3c';
            document.getElementById('resultDetail').textContent = detail;
        }

        initCamera();
    </script>
</body>
</html>

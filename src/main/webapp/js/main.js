/**
 * 人脸考勤打卡系统 - 通用JavaScript工具
 */

// ==================== 摄像头工具 ====================

/**
 * 打开摄像头
 * @param {HTMLVideoElement} videoElement - 视频元素
 * @param {Function} onSuccess - 成功回调
 * @param {Function} onError - 失败回调
 */
function openCamera(videoElement, onSuccess, onError) {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        if (onError) onError('浏览器不支持摄像头访问');
        return;
    }
    navigator.mediaDevices.getUserMedia({
        video: { width: 640, height: 480, facingMode: 'user' }
    })
    .then(function(stream) {
        videoElement.srcObject = stream;
        videoElement.play();
        if (onSuccess) onSuccess(stream);
    })
    .catch(function(err) {
        console.error('摄像头错误:', err);
        if (onError) onError('无法访问摄像头: ' + err.message);
    });
}

/**
 * 停止摄像头
 * @param {MediaStream} stream - 摄像头流
 */
function closeCamera(stream) {
    if (stream) {
        stream.getTracks().forEach(function(track) { track.stop(); });
    }
}

/**
 * 从视频元素截取一帧
 * @param {HTMLVideoElement} video - 视频元素
 * @param {number} width - 输出宽度
 * @param {number} height - 输出高度
 * @returns {Blob} JPEG Blob
 */
function captureFrame(video, width, height) {
    return new Promise(function(resolve, reject) {
        var canvas = document.createElement('canvas');
        canvas.width = width || video.videoWidth || 640;
        canvas.height = height || video.videoHeight || 480;
        var ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
        canvas.toBlob(function(blob) {
            if (blob) resolve(blob);
            else reject(new Error('截图失败'));
        }, 'image/jpeg', 0.9);
    });
}

// ==================== 文件上传预览 ====================

/**
 * 图片文件预览
 * @param {HTMLInputElement} fileInput - 文件输入元素
 * @param {HTMLImageElement|string} previewTarget - 预览图片元素或ID
 */
function previewImage(fileInput, previewTarget) {
    var target = typeof previewTarget === 'string'
        ? document.getElementById(previewTarget)
        : previewTarget;

    if (fileInput.files && fileInput.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            target.src = e.target.result;
            target.style.display = 'block';
        };
        reader.readAsDataURL(fileInput.files[0]);
    }
}

// ==================== AJAX 请求封装 ====================

/**
 * 发送POST请求（JSON）
 */
function postJSON(url, data) {
    return fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).then(function(resp) { return resp.json(); });
}

/**
 * 发送POST请求（FormData，用于文件上传）
 */
function postFormData(url, formData) {
    return fetch(url, {
        method: 'POST',
        body: formData
    }).then(function(resp) { return resp.json(); });
}

// ==================== 提示消息 ====================

/**
 * 显示弹窗消息
 */
function showAlert(message, type) {
    type = type || 'info';
    var bgColors = { success: '#27ae60', error: '#e74c3c', info: '#2196f3', warning: '#ff9800' };
    var alertEl = document.createElement('div');
    alertEl.style.cssText =
        'position:fixed;top:20px;left:50%;transform:translateX(-50%);' +
        'padding:14px 30px;border-radius:8px;color:#fff;font-size:15px;font-weight:500;' +
        'z-index:9999;box-shadow:0 8px 30px rgba(0,0,0,0.2);' +
        'background:' + (bgColors[type] || bgColors.info) + ';' +
        'animation: fadeIn 0.3s ease;transition:opacity 0.3s;';
    alertEl.textContent = message;
    document.body.appendChild(alertEl);
    setTimeout(function() {
        alertEl.style.opacity = '0';
        setTimeout(function() { document.body.removeChild(alertEl); }, 300);
    }, 3000);
}

// ==================== 确认对话框 ====================

/**
 * 确认对话框
 */
function confirmAction(message, onConfirm) {
    if (confirm(message)) {
        onConfirm();
    }
}

// ==================== 日期格式化 ====================

/**
 * 格式化日期
 */
function formatDate(date) {
    var d = new Date(date);
    var year = d.getFullYear();
    var month = String(d.getMonth() + 1).padStart(2, '0');
    var day = String(d.getDate()).padStart(2, '0');
    return year + '-' + month + '-' + day;
}

/**
 * 格式化时间
 */
function formatTime(date) {
    var d = new Date(date);
    var h = String(d.getHours()).padStart(2, '0');
    var m = String(d.getMinutes()).padStart(2, '0');
    var s = String(d.getSeconds()).padStart(2, '0');
    return h + ':' + m + ':' + s;
}

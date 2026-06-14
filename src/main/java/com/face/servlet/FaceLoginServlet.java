package com.face.servlet;

import com.face.model.User;
import com.face.service.FaceService;
import com.google.gson.Gson;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 人脸登录控制器
 * 用户通过人脸识别登录（拍照后全库搜索匹配）
 */
public class FaceLoginServlet extends HttpServlet {

    private final FaceService faceService = new FaceService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Map<String, Object> result = new HashMap<>();
        Gson gson = new Gson();

        try {
            // 检查是否为人脸照片上传
            if (!ServletFileUpload.isMultipartContent(request)) {
                result.put("success", false);
                result.put("message", "请上传人脸照片");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            // 解析上传文件
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(10 * 1024 * 1024); // 最大10MB

            List<FileItem> items = upload.parseRequest(request);
            byte[] imageData = null;

            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    imageData = item.get();
                }
            }

            if (imageData == null) {
                result.put("success", false);
                result.put("message", "未接收到图片数据");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            // 保存临时文件
            String tempDir = System.getProperty("java.io.tmpdir");
            String tempPath = tempDir + File.separator + "face_login_" + System.currentTimeMillis() + ".jpg";
            File tempFile = new File(tempPath);
            org.apache.commons.io.FileUtils.writeByteArrayToFile(tempFile, imageData);

            // 人脸识别登录
            User user = faceService.faceLogin(tempPath);

            // 删除临时文件
            tempFile.delete();

            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("loginUser", user);
                result.put("success", true);
                result.put("message", "人脸识别成功，欢迎 " + user.getRealName());
                result.put("realName", user.getRealName());
            } else {
                result.put("success", false);
                result.put("message", "人脸识别失败，请确保已注册人脸且正面面对摄像头");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "系统错误: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(result));
    }
}

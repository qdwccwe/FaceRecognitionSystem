package com.face.servlet;

import com.face.model.User;
import com.face.service.FaceService;
import com.face.util.FaceRecognitionUtil;
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
 * 人脸注册控制器
 * 用户上传/采集人脸照片，提取人脸特征并保存
 */
public class FaceRegisterServlet extends HttpServlet {

    private final FaceService faceService = new FaceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/face_register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        Map<String, Object> result = new HashMap<>();
        Gson gson = new Gson();

        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "请先登录");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            if (!ServletFileUpload.isMultipartContent(request)) {
                result.put("success", false);
                result.put("message", "请上传人脸照片");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(10 * 1024 * 1024);
            List<FileItem> items = upload.parseRequest(request);

            byte[] imageData = null;
            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    imageData = item.get();
                }
            }

            if (imageData == null || imageData.length == 0) {
                result.put("success", false);
                result.put("message", "未接收到图片数据");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            // 保存临时文件
            String tempDir = FaceRecognitionUtil.getUploadBasePath() + File.separator + "temp";
            File dir = new File(tempDir);
            if (!dir.exists()) dir.mkdirs();
            String tempPath = tempDir + File.separator + "face_reg_" + loginUser.getId() + "_" + System.currentTimeMillis() + ".jpg";
            org.apache.commons.io.FileUtils.writeByteArrayToFile(new File(tempPath), imageData);

            // 注册人脸
            String facePath = faceService.registerFace(loginUser.getId(), tempPath);

            // 删除临时文件
            new File(tempPath).delete();

            if (facePath != null) {
                // 更新session中的用户人脸状态
                loginUser.setFaceStatus(1);
                loginUser.setFaceImagePath(facePath);
                session.setAttribute("loginUser", loginUser);

                result.put("success", true);
                result.put("message", "人脸注册成功！");
                result.put("facePath", facePath);
            } else {
                String detectorStatus = FaceRecognitionUtil.getInitStatus();
                result.put("success", false);
                result.put("message", "未检测到人脸 [" + detectorStatus + "]，请上传清晰的正面人脸照片（光线充足、五官清晰、无遮挡）");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "注册失败: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(result));
    }
}

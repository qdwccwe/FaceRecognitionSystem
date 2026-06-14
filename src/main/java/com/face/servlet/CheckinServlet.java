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
 * 人脸打卡控制器
 * 用户通过人脸识别进行考勤打卡
 */
public class CheckinServlet extends HttpServlet {

    private final FaceService faceService = new FaceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/checkin.jsp").forward(request, response);
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
                result.put("message", "请拍照或上传人脸照片");
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

            // 保存打卡照片
            String basePath = FaceRecognitionUtil.getUploadBasePath();
            String checkinDir = basePath + File.separator + "checkin";
            String photoPath = FaceRecognitionUtil.saveCheckinPhoto(imageData, basePath, loginUser.getId());

            if (photoPath == null) {
                result.put("success", false);
                result.put("message", "照片保存失败");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            // 执行人脸打卡
            String[] checkinResult = faceService.checkin(loginUser.getId(), photoPath);
            String code = checkinResult[0];
            String similarity = checkinResult[1];
            String msg = checkinResult[2];

            switch (code) {
                case "success":
                    result.put("success", true);
                    result.put("message", "✅ 打卡成功！" + loginUser.getRealName() + "，"
                            + ("late".equals(msg) ? "迟到打卡" : "正常打卡"));
                    result.put("similarity", similarity);
                    result.put("status", msg);
                    result.put("realName", loginUser.getRealName());
                    break;
                case "already":
                    result.put("success", false);
                    result.put("message", "今日已打卡，无需重复打卡");
                    result.put("already", true);
                    break;
                case "no_face":
                    result.put("success", false);
                    result.put("message", "未检测到人脸，请正面面对摄像头，确保光线充足");
                    break;
                case "not_match":
                    result.put("success", false);
                    result.put("message", "人脸与当前用户不匹配，请确认是本人操作");
                    result.put("similarity", similarity);
                    break;
                default:
                    result.put("success", false);
                    result.put("message", msg);
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "打卡失败: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(result));
    }
}

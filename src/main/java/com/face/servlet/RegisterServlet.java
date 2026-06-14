package com.face.servlet;

import com.face.model.User;
import com.face.service.UserService;
import com.face.util.FaceRecognitionUtil;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.util.List;

/**
 * 用户注册控制器
 */
public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // 解析multipart表单（包含文本+文件）
            if (!ServletFileUpload.isMultipartContent(request)) {
                request.setAttribute("error", "表单类型错误");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                return;
            }

            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(10 * 1024 * 1024);
            List<FileItem> items = upload.parseRequest(request);

            String username = null, password = null, confirmPassword = null;
            String realName = null, phone = "", email = "";
            byte[] faceImageData = null;

            for (FileItem item : items) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String value = item.getString("UTF-8");
                    switch (fieldName) {
                        case "username": username = value.trim(); break;
                        case "password": password = value.trim(); break;
                        case "confirmPassword": confirmPassword = value.trim(); break;
                        case "realName": realName = value.trim(); break;
                        case "phone": phone = value.trim(); break;
                        case "email": email = value.trim(); break;
                    }
                } else if (item.getSize() > 0) {
                    faceImageData = item.get();
                }
            }

            // 参数校验
            if (username == null || username.isEmpty() ||
                    password == null || password.isEmpty() ||
                    realName == null || realName.isEmpty()) {
                request.setAttribute("error", "用户名、密码、真实姓名为必填项");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                return;
            }

            if (password.length() < 6) {
                request.setAttribute("error", "密码长度不能少于6位");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "两次输入的密码不一致");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                return;
            }

            // 创建用户
            User user = new User();
            user.setUsername(username);
            user.setPassword(password);
            user.setRealName(realName);
            user.setPhone(phone);
            user.setEmail(email);

            int regResult = userService.register(user);

            if (regResult == -1) {
                request.setAttribute("error", "用户名已存在，请更换");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                return;
            }

            if (regResult == 0) {
                request.setAttribute("error", "注册失败，请重试");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                return;
            }

            // 如果上传了人脸照片，则处理
            if (faceImageData != null && faceImageData.length > 0) {
                // 先获取刚注册的用户ID
                com.face.dao.UserDao userDao = new com.face.dao.UserDao();
                User registeredUser = userDao.findByUsername(username);
                if (registeredUser != null) {
                    // 保存原始照片到临时目录
                    String basePath = FaceRecognitionUtil.getUploadBasePath();
                    String tempDir = basePath + File.separator + "temp";
                    File dir = new File(tempDir);
                    if (!dir.exists()) dir.mkdirs();
                    String tempPath = tempDir + File.separator + "reg_" + username + ".jpg";
                    org.apache.commons.io.FileUtils.writeByteArrayToFile(new File(tempPath), faceImageData);

                    // 提取人脸并保存
                    String faceOutputDir = basePath + File.separator + "faces";
                    String facePath = FaceRecognitionUtil.extractAndSaveFace(tempPath, faceOutputDir,
                            registeredUser.getId());

                    // 删除临时文件
                    new File(tempPath).delete();

                    // 更新用户人脸信息
                    if (facePath != null) {
                        userDao.updateFaceInfo(registeredUser.getId(), 1, facePath, "");
                        // 重新训练模型
                        new com.face.service.FaceService().retrainModel();
                    }
                }
            }

            request.setAttribute("success", "注册成功！请登录");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "注册失败: " + e.getMessage());
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
        }
    }
}

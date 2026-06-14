package com.face.service;

import com.face.dao.AttendanceDao;
import com.face.dao.UserDao;
import com.face.model.AttendanceLog;
import com.face.model.User;
import com.face.util.FaceRecognitionUtil;

import java.io.File;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 人脸识别业务逻辑层
 * 负责人脸注册、人脸打卡、模型训练等核心业务
 */
public class FaceService {

    private final UserDao userDao = new UserDao();
    private final AttendanceDao attendanceDao = new AttendanceDao();

    /**
     * 注册人脸
     * @param userId 用户ID
     * @param imagePath 上传的人脸照片路径
     * @return 成功返回保存的人脸照片路径，失败返回null
     */
    public String registerFace(int userId, String imagePath) throws SQLException {
        // 从照片中提取人脸
        String basePath = FaceRecognitionUtil.getUploadBasePath();
        String faceDir = basePath + File.separator + "faces";
        String facePath = FaceRecognitionUtil.extractAndSaveFace(imagePath, faceDir, userId);

        if (facePath == null) {
            return null; // 未检测到人脸
        }

        // 更新数据库
        userDao.updateFaceInfo(userId, 1, facePath, "");

        // 重新训练模型
        retrainModel();

        return facePath;
    }

    /**
     * 人脸打卡
     * @param userId 用户ID
     * @param imagePath 现场人脸照片路径
     * @return 打卡结果: [识别用户ID, 相似度百分比, 状态]
     *          状态: "success" / "already" / "no_face" / "not_match"
     */
    public String[] checkin(int userId, String imagePath) throws SQLException {
        // 1. 先检查今天是否已打卡
        AttendanceLog todayLog = attendanceDao.findTodayByUserId(userId);
        if (todayLog != null) {
            return new String[]{"already", "0", "今日已打卡，无需重复打卡"};
        }

        // 2. 人脸识别
        int[] result = FaceRecognitionUtil.recognize(imagePath);
        if (result == null) {
            return new String[]{"no_face", "0", "未检测到人脸或识别失败"};
        }

        int recognizedUserId = result[0];
        int similarity = result[1]; // 相似度百分比

        // 3. 判断是否匹配当前用户
        if (recognizedUserId != userId) {
            return new String[]{"not_match", String.valueOf(similarity), "人脸与当前用户不匹配"};
        }

        // 4. 保存打卡照片
        String checkinPhotoPath = null;
        File imageFile = new File(imagePath);
        if (imageFile.exists()) {
            checkinPhotoPath = imagePath;
        }

        // 5. 判断考勤状态（正常/迟到）
        LocalTime now = LocalTime.now();
        LocalTime workStart = LocalTime.of(9, 0); // 默认9:00上班
        String status = now.isAfter(workStart) ? "late" : "normal";

        // 6. 记录打卡
        AttendanceLog log = new AttendanceLog();
        log.setUserId(userId);
        log.setCheckInTime(new Timestamp(System.currentTimeMillis()));
        log.setCheckType("face");
        log.setStatus(status);
        log.setMatchScore(similarity);
        log.setPhotoPath(checkinPhotoPath);

        attendanceDao.insert(log);

        return new String[]{"success", String.valueOf(similarity), status};
    }

    /**
     * 通过人脸识别登录（不指定用户，全库搜索）
     * @param imagePath 人脸照片路径
     * @return 匹配到的用户，失败返回null
     */
    public User faceLogin(String imagePath) throws SQLException {
        int[] result = FaceRecognitionUtil.recognize(imagePath);
        if (result == null) {
            return null;
        }

        int userId = result[0];
        User user = userDao.findById(userId);
        if (user != null) {
            user.setPassword(null);
        }
        return user;
    }

    /**
     * 重新训练人脸识别模型
     * 从数据库读取所有已注册的人脸图片，重新训练LBPH模型
     */
    public void retrainModel() {
        try {
            List<User> users = userDao.findUsersWithFace();
            List<String> imagePaths = new ArrayList<>();
            List<Integer> userIds = new ArrayList<>();

            for (User user : users) {
                String path = user.getFaceImagePath();
                if (path != null && !path.isEmpty()) {
                    File file = new File(path);
                    if (file.exists()) {
                        imagePaths.add(path);
                        userIds.add(user.getId());
                    }
                }
            }

            FaceRecognitionUtil.trainModel(imagePaths, userIds);
        } catch (SQLException e) {
            System.err.println("!!! 模型重训失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 初始化模型（应用启动时调用）
     */
    public void initModel() {
        retrainModel();
    }
}

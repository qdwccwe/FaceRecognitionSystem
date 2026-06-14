package com.face.util;

import org.bytedeco.javacpp.DoublePointer;
import org.bytedeco.javacpp.IntPointer;
import org.bytedeco.javacpp.Loader;
import org.bytedeco.opencv.global.opencv_core;
import org.bytedeco.opencv.global.opencv_imgcodecs;
import org.bytedeco.opencv.global.opencv_imgproc;
import org.bytedeco.opencv.global.opencv_objdetect;
import org.bytedeco.opencv.opencv_core.*;
import org.bytedeco.opencv.opencv_objdetect.CascadeClassifier;
import org.bytedeco.opencv.opencv_face.LBPHFaceRecognizer;

import java.io.*;
import java.nio.IntBuffer;
import java.util.*;

/**
 * 人脸识别工具类
 * 功能：人脸检测 + 人脸特征提取 + 人脸比对
 * 使用 OpenCV 的 Haar Cascade 进行人脸检测
 * 使用 LBPH (Local Binary Patterns Histogram) 算法进行人脸识别
 */
public class FaceRecognitionUtil {

    // 级联分类器文件路径
    private static String cascadePath;
    // 人脸照片存储目录
    private static String uploadBasePath;
    // 识别置信度阈值（低于此值认为识别成功，LBPH中距离越小越相似）
    private static double confidenceThreshold;
    // 标准人脸图片尺寸
    private static int faceWidth;
    private static int faceHeight;

    // LBPH人脸识别器（单例）
    private static volatile LBPHFaceRecognizer recognizer;
    // 是否已训练
    private static volatile boolean trained = false;
    // 标签到用户ID的映射
    private static Map<Integer, Integer> labelToUserId = new HashMap<>();
    private static Map<Integer, Integer> userIdToLabel = new HashMap<>();
    private static int nextLabel = 1;

    // 级联分类器（单例）
    private static volatile CascadeClassifier faceDetector;

    static {
        try {
            // 加载OpenCV原生库
            Loader.load(org.bytedeco.opencv.opencv_core.Mat.class);

            // 从配置文件读取参数
            Properties props = new Properties();
            InputStream is = FaceRecognitionUtil.class.getClassLoader().getResourceAsStream("db.properties");
            if (is != null) {
                props.load(is);
                cascadePath = props.getProperty("face.cascadePath");
                uploadBasePath = props.getProperty("upload.basePath");
                confidenceThreshold = Double.parseDouble(props.getProperty("face.confidenceThreshold", "70.0"));
                faceWidth = Integer.parseInt(props.getProperty("face.imageWidth", "200"));
                faceHeight = Integer.parseInt(props.getProperty("face.imageHeight", "200"));
            }

            // 初始化级联分类器
            if (cascadePath != null) {
                File cascadeFile = new File(cascadePath);
                if (cascadeFile.exists()) {
                    faceDetector = new CascadeClassifier(cascadePath);
                    System.out.println(">>> 人脸检测器加载成功: " + cascadePath);
                } else {
                    System.err.println("!!! 级联分类器文件不存在: " + cascadePath);
                    // 尝试从OpenCV内部加载
                    faceDetector = new CascadeClassifier();
                    System.err.println("!!! 请在 resources 目录放置 haarcascade_frontalface_alt.xml 文件");
                }
            }
        } catch (Exception e) {
            System.err.println("!!! 人脸识别工具初始化失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 检测图片中是否有人脸
     * @param imagePath 图片路径
     * @return 检测到的人脸区域列表
     */
    public static List<Rect> detectFaces(String imagePath) {
        List<Rect> faceRects = new ArrayList<>();
        if (faceDetector == null || faceDetector.isNull()) {
            System.err.println("!!! 人脸检测器未初始化");
            return faceRects;
        }
        try {
            Mat image = opencv_imgcodecs.imread(imagePath);
            if (image.empty()) {
                System.err.println("!!! 无法读取图片: " + imagePath);
                return faceRects;
            }
            Mat gray = new Mat();
            opencv_imgproc.cvtColor(image, gray, opencv_imgproc.COLOR_BGR2GRAY);
            opencv_imgproc.equalizeHist(gray, gray);

            RectVector faces = new RectVector();
            // 放宽检测参数：scaleFactor更小（更细致），minNeighbors更低（更容易检测到）
            faceDetector.detectMultiScale(gray, faces, 1.05, 2,
                    0, new Size(60, 60), new Size());

            for (int i = 0; i < faces.size(); i++) {
                faceRects.add(faces.get(i));
            }

            image.release();
            gray.release();
        } catch (Exception e) {
            System.err.println("!!! 人脸检测失败: " + e.getMessage());
            e.printStackTrace();
        }
        return faceRects;
    }

    /**
     * 从图片中提取人脸区域并保存
     * @param imagePath 原始图片路径
     * @param outputDir 输出目录
     * @param userId 用户ID（用于命名）
     * @return 保存的人脸图片路径，失败返回null
     */
    public static String extractAndSaveFace(String imagePath, String outputDir, int userId) {
        List<Rect> faces = detectFaces(imagePath);
        if (faces.isEmpty()) {
            System.err.println("!!! 未检测到人脸: " + imagePath);
            return null;
        }

        try {
            Mat image = opencv_imgcodecs.imread(imagePath);
            // 取最大的人脸区域
            Rect largestFace = faces.get(0);
            int maxArea = largestFace.width() * largestFace.height();
            for (int i = 1; i < faces.size(); i++) {
                Rect r = faces.get(i);
                int area = r.width() * r.height();
                if (area > maxArea) {
                    largestFace = r;
                    maxArea = area;
                }
            }

            // 扩展人脸区域20%（包含更多面部信息）
            int expandW = (int)(largestFace.width() * 0.2);
            int expandH = (int)(largestFace.height() * 0.2);
            int x = Math.max(0, largestFace.x() - expandW);
            int y = Math.max(0, largestFace.y() - expandH);
            int w = Math.min(image.cols() - x, largestFace.width() + 2 * expandW);
            int h = Math.min(image.rows() - y, largestFace.height() + 2 * expandH);

            Mat faceROI = image.apply(new Rect(x, y, w, h));
            Mat resized = new Mat();
            opencv_imgproc.resize(faceROI, resized, new Size(faceWidth, faceHeight));

            // 确保输出目录存在
            File dir = new File(outputDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            String outputPath = outputDir + File.separator + "face_" + userId + "_" + System.currentTimeMillis() + ".jpg";
            opencv_imgcodecs.imwrite(outputPath, resized);

            image.release();
            faceROI.release();
            resized.release();

            System.out.println(">>> 人脸提取成功: " + outputPath);
            return outputPath;

        } catch (Exception e) {
            System.err.println("!!! 人脸提取失败: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 初始化/重新训练LBPH人脸识别模型
     * @param faceImagePaths 人脸图片路径列表
     * @param userIds 对应的用户ID列表（与faceImagePaths一一对应）
     */
    public static synchronized void trainModel(List<String> faceImagePaths, List<Integer> userIds) {
        if (faceImagePaths == null || faceImagePaths.isEmpty()) {
            System.out.println(">>> 没有人脸数据，跳过模型训练");
            return;
        }
        if (faceImagePaths.size() != userIds.size()) {
            System.err.println("!!! 训练数据不一致");
            return;
        }

        try {
            // 重新构建标签映射
            labelToUserId.clear();
            userIdToLabel.clear();
            nextLabel = 1;

            MatVector images = new MatVector(faceImagePaths.size());
            Mat labels = new Mat(faceImagePaths.size(), 1, opencv_core.CV_32SC1);
            IntBuffer labelsBuf = labels.createBuffer();

            for (int i = 0; i < faceImagePaths.size(); i++) {
                String path = faceImagePaths.get(i);
                int userId = userIds.get(i);

                Mat img = opencv_imgcodecs.imread(path, opencv_imgcodecs.IMREAD_GRAYSCALE);
                if (img.empty()) {
                    System.err.println("!!! 无法读取人脸图片: " + path);
                    continue;
                }

                // 分配标签
                Integer label = userIdToLabel.get(userId);
                if (label == null) {
                    label = nextLabel++;
                    userIdToLabel.put(userId, label);
                    labelToUserId.put(label, userId);
                }

                images.put(i, img);
                labelsBuf.put(i, label);
            }

            // 创建并训练LBPH识别器
            if (recognizer != null) {
                recognizer.close();
            }
            recognizer = LBPHFaceRecognizer.create(1, 8, 8, 8, 100.0);
            recognizer.train(images, labels);
            trained = true;

            System.out.println(">>> LBPH模型训练完成，共 " + faceImagePaths.size() + " 张人脸图片，"
                    + userIdToLabel.size() + " 个用户");

            // 释放资源
            for (int i = 0; i < images.size(); i++) {
                images.get(i).release();
            }
            labels.release();

        } catch (Exception e) {
            System.err.println("!!! 模型训练失败: " + e.getMessage());
            e.printStackTrace();
            trained = false;
        }
    }

    /**
     * 识别图片中的人脸，返回匹配的用户ID
     * @param imagePath 待识别的人脸图片路径
     * @return 识别结果: [userId, confidence]，识别失败返回null
     */
    public static int[] recognize(String imagePath) {
        if (!trained || recognizer == null || recognizer.isNull()) {
            System.err.println("!!! 识别模型未训练");
            return null;
        }

        // 先检测人脸
        List<Rect> faces = detectFaces(imagePath);
        if (faces.isEmpty()) {
            System.err.println("!!! 未检测到人脸");
            return null;
        }

        try {
            Mat image = opencv_imgcodecs.imread(imagePath, opencv_imgcodecs.IMREAD_GRAYSCALE);
            if (image.empty()) {
                return null;
            }

            // 取最大的人脸区域
            Rect face = faces.get(0);
            int maxArea = face.width() * face.height();
            for (int i = 1; i < faces.size(); i++) {
                Rect r = faces.get(i);
                int area = r.width() * r.height();
                if (area > maxArea) {
                    face = r;
                    maxArea = area;
                }
            }

            // 裁剪并调整大小
            int expandW = (int)(face.width() * 0.2);
            int expandH = (int)(face.height() * 0.2);
            int x = Math.max(0, face.x() - expandW);
            int y = Math.max(0, face.y() - expandH);
            int w = Math.min(image.cols() - x, face.width() + 2 * expandW);
            int h = Math.min(image.rows() - y, face.height() + 2 * expandH);

            Mat faceROI = image.apply(new Rect(x, y, w, h));
            Mat resized = new Mat();
            opencv_imgproc.resize(faceROI, resized, new Size(faceWidth, faceHeight));

            // 预测
            IntPointer label = new IntPointer(1);
            DoublePointer confidence = new DoublePointer(1);
            recognizer.predict(resized, label, confidence);

            int predictedLabel = label.get(0);
            double conf = confidence.get(0);
            Integer userId = labelToUserId.get(predictedLabel);

            image.release();
            faceROI.release();
            resized.release();

            System.out.println(">>> 识别结果: label=" + predictedLabel + ", userId=" + userId
                    + ", confidence=" + String.format("%.2f", conf));

            // LBPH中距离越小越相似，需要根据阈值判断
            if (userId != null && conf < confidenceThreshold) {
                return new int[]{userId, (int) (100 - conf)}; // 转换为相似度百分比
            }

            return null;

        } catch (Exception e) {
            System.err.println("!!! 人脸识别失败: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 保存考勤打卡的现场照片
     */
    public static String saveCheckinPhoto(byte[] imageData, String outputDir, int userId) {
        try {
            File dir = new File(outputDir, "checkin");
            if (!dir.exists()) {
                dir.mkdirs();
            }
            String filename = "checkin_" + userId + "_" + System.currentTimeMillis() + ".jpg";
            String path = dir.getAbsolutePath() + File.separator + filename;
            try (FileOutputStream fos = new FileOutputStream(path)) {
                fos.write(imageData);
            }
            return path;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 检测人脸检测器是否可用
     */
    public static boolean isDetectorReady() {
        return faceDetector != null && !faceDetector.isNull();
    }

    /**
     * 获取初始化状态描述
     */
    public static String getInitStatus() {
        if (faceDetector == null) {
            return "人脸检测器未初始化";
        }
        if (faceDetector.isNull()) {
            return "级联分类器加载失败，请检查: " + cascadePath;
        }
        File f = new File(cascadePath);
        if (!f.exists()) {
            return "级联分类器文件不存在: " + cascadePath;
        }
        return "人脸检测器就绪";
    }

    /**
     * 判断识别器是否已训练
     */
    public static boolean isTrained() {
        return trained;
    }

    /**
     * 获取上传目录
     */
    public static String getUploadBasePath() {
        return uploadBasePath;
    }

    /**
     * 获取标准人脸图片宽度
     */
    public static int getFaceWidth() {
        return faceWidth;
    }

    /**
     * 获取标准人脸图片高度
     */
    public static int getFaceHeight() {
        return faceHeight;
    }

    /**
     * 重新设置级联分类器路径
     */
    public static void setCascadePath(String path) {
        cascadePath = path;
        if (faceDetector != null) {
            faceDetector.close();
        }
        faceDetector = new CascadeClassifier(path);
    }
}

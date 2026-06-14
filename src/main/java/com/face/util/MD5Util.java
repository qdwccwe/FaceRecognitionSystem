package com.face.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * MD5 密码加密工具类
 */
public class MD5Util {

    /**
     * 对字符串进行MD5加密
     * @param input 原始字符串
     * @return 32位小写MD5密文
     */
    public static String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(input.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5加密失败", e);
        }
    }

    /**
     * 验证密码是否正确
     * @param inputPassword 用户输入的密码（明文）
     * @param storedPassword 数据库中存储的密码（密文）
     * @return 是否匹配
     */
    public static boolean verify(String inputPassword, String storedPassword) {
        if (inputPassword == null || storedPassword == null) {
            return false;
        }
        return md5(inputPassword).equals(storedPassword);
    }
}

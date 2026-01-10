package com.example.backend.utils;

import cn.hutool.crypto.digest.BCrypt;

/**
 * 密码哈希生成工具
 * 用于生成BCrypt密码哈希
 */
public class PasswordHashGenerator {

    public static void main(String[] args) {
        String password = "admin123#";
        String hash = BCrypt.hashpw(password);
        System.out.println("密码: " + password);
        System.out.println("BCrypt哈希: " + hash);

        // 验证哈希
        boolean isMatch = BCrypt.checkpw(password, hash);
        System.out.println("验证结果: " + isMatch);
    }
}

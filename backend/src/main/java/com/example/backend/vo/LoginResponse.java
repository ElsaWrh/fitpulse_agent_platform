package com.example.backend.vo;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * 登录响应
 */
@Data
@AllArgsConstructor
public class LoginResponse {

    private String token;

    private Long expiresIn;

    private UserVO user;
}

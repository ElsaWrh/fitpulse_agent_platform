package com.example.backend.dto;

import lombok.Data;

/**
 * 用户更新请求
 */
@Data
public class UpdateUserRequest {

    private String nickname;

    private String gender;

    private String birthday;

    private String phone;

    private String avatarUrl;
}

package com.example.backend.vo;

import lombok.Data;

/**
 * 用户视图对象
 */
@Data
public class UserVO {

    private Long id;

    private String email;

    private String nickname;

    private String avatarUrl;

    private String gender;

    private String birthday;

    private String phone;

    private String role;

    private String status;
}

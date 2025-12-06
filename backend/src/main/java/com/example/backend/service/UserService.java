package com.example.backend.service;

import com.example.backend.dto.UpdateUserRequest;
import com.example.backend.entity.User;
import com.example.backend.vo.UserVO;

/**
 * 用户服务接口
 */
public interface UserService {

    /**
     * 根据ID获取用户
     */
    User getUserById(Long id);

    /**
     * 根据邮箱获取用户
     */
    User getUserByEmail(String email);

    /**
     * 获取当前用户信息
     */
    UserVO getCurrentUser();

    /**
     * 更新用户信息
     */
    UserVO updateUser(UpdateUserRequest request);

    /**
     * 将User转换为UserVO
     */
    UserVO convertToVO(User user);
}

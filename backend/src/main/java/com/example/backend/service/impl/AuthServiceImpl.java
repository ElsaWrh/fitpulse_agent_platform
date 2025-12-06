package com.example.backend.service.impl;

import cn.hutool.crypto.digest.BCrypt;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.dto.LoginRequest;
import com.example.backend.dto.RegisterRequest;
import com.example.backend.entity.User;
import com.example.backend.exception.BusinessException;
import com.example.backend.mapper.UserMapper;
import com.example.backend.service.AuthService;
import com.example.backend.service.UserService;
import com.example.backend.utils.JwtUtil;
import com.example.backend.vo.LoginResponse;
import com.example.backend.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 认证服务实现
 */
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserMapper userMapper;
    private final UserService userService;
    private final JwtUtil jwtUtil;

    @Override
    public void register(RegisterRequest request) {
        // 检查邮箱是否已存在
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getEmail, request.getEmail());
        if (userMapper.selectCount(wrapper) > 0) {
            throw new BusinessException(4090, "邮箱已被注册");
        }

        // 创建用户
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(BCrypt.hashpw(request.getPassword()));
        user.setNickname(request.getNickname());
        user.setRole("USER");
        user.setStatus("ACTIVE");

        userMapper.insert(user);
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        // 查找用户
        User user = userService.getUserByEmail(request.getEmail());
        if (user == null) {
            throw new BusinessException(4001, "用户不存在");
        }

        // 验证密码
        if (!BCrypt.checkpw(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(4001, "密码错误");
        }

        // 检查账号状态
        if (!"ACTIVE".equals(user.getStatus())) {
            throw new BusinessException(4030, "账号已被禁用");
        }

        // 生成Token
        String token = jwtUtil.generateToken(user.getId(), user.getEmail());

        // 转换用户信息
        UserVO userVO = userService.convertToVO(user);

        return new LoginResponse(token, 86400L, userVO);
    }
}

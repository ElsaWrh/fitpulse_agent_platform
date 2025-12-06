package com.example.backend.controller;

import com.example.backend.common.Result;
import com.example.backend.dto.UpdateUserRequest;
import com.example.backend.service.UserService;
import com.example.backend.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * 获取我的资料
     */
    @GetMapping("/me")
    public Result<UserVO> getProfile() {
        UserVO user = userService.getCurrentUser();
        return Result.success(user);
    }

    /**
     * 更新我的资料
     */
    @PutMapping("/me")
    public Result<UserVO> updateProfile(@RequestBody UpdateUserRequest request) {
        UserVO user = userService.updateUser(request);
        return Result.success(user);
    }
}

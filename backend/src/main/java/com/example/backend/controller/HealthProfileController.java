package com.example.backend.controller;

import com.example.backend.common.Result;
import com.example.backend.dto.HealthProfileRequest;
import com.example.backend.entity.HealthProfile;
import com.example.backend.service.HealthProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

/**
 * 健康档案控制器
 */
@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
public class HealthProfileController {

    private final HealthProfileService healthProfileService;

    /**
     * 获取健康档案
     */
    @GetMapping("/profile")
    public Result<HealthProfile> getProfile() {
        HealthProfile profile = healthProfileService.getProfile();
        return Result.success(profile);
    }

    /**
     * 创建或更新健康档案
     */
    @PostMapping("/profile")
    public Result<HealthProfile> createProfile(@Valid @RequestBody HealthProfileRequest request) {
        HealthProfile profile = healthProfileService.saveProfile(request);
        return Result.success(profile);
    }

    /**
     * 更新健康档案
     */
    @PutMapping("/profile")
    public Result<HealthProfile> updateProfile(@Valid @RequestBody HealthProfileRequest request) {
        HealthProfile profile = healthProfileService.saveProfile(request);
        return Result.success(profile);
    }
}

package com.example.backend.service;

import com.example.backend.dto.HealthProfileRequest;
import com.example.backend.entity.HealthProfile;

/**
 * 健康档案服务接口
 */
public interface HealthProfileService {

    /**
     * 获取当前用户健康档案
     */
    HealthProfile getProfile();

    /**
     * 创建或更新健康档案
     */
    HealthProfile saveProfile(HealthProfileRequest request);
}

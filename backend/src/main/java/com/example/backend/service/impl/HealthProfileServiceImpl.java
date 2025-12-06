package com.example.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.dto.HealthProfileRequest;
import com.example.backend.entity.HealthProfile;
import com.example.backend.mapper.HealthProfileMapper;
import com.example.backend.service.HealthProfileService;
import com.example.backend.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 健康档案服务实现
 */
@Service
@RequiredArgsConstructor
public class HealthProfileServiceImpl implements HealthProfileService {

    private final HealthProfileMapper healthProfileMapper;

    @Override
    public HealthProfile getProfile() {
        Long userId = UserContext.getUserId();
        LambdaQueryWrapper<HealthProfile> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthProfile::getUserId, userId);
        return healthProfileMapper.selectOne(wrapper);
    }

    @Override
    public HealthProfile saveProfile(HealthProfileRequest request) {
        Long userId = UserContext.getUserId();

        // 查找现有档案
        LambdaQueryWrapper<HealthProfile> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthProfile::getUserId, userId);
        HealthProfile profile = healthProfileMapper.selectOne(wrapper);

        if (profile == null) {
            // 创建新档案
            profile = new HealthProfile();
            profile.setUserId(userId);
            BeanUtils.copyProperties(request, profile);

            // 计算BMI
            if (request.getHeight() != null && request.getCurrentWeight() != null) {
                BigDecimal bmi = calculateBMI(request.getHeight(), request.getCurrentWeight());
                profile.setBmi(bmi);
            }

            healthProfileMapper.insert(profile);
        } else {
            // 更新档案
            BeanUtils.copyProperties(request, profile);

            // 重新计算BMI
            if (request.getHeight() != null && request.getCurrentWeight() != null) {
                BigDecimal bmi = calculateBMI(request.getHeight(), request.getCurrentWeight());
                profile.setBmi(bmi);
            }

            healthProfileMapper.updateById(profile);
        }

        return profile;
    }

    /**
     * 计算BMI = 体重(kg) / 身高(m)²
     */
    private BigDecimal calculateBMI(BigDecimal height, BigDecimal weight) {
        BigDecimal heightInMeters = height.divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        return weight.divide(heightInMeters.multiply(heightInMeters), 2, RoundingMode.HALF_UP);
    }
}

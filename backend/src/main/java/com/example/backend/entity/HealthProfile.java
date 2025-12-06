package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 健康档案实体类
 */
@Data
@TableName("health_profile")
public class HealthProfile {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private BigDecimal height;

    private BigDecimal currentWeight;

    private BigDecimal targetWeight;

    private BigDecimal bmi;

    private String fitnessLevel;

    private Integer weeklyWorkoutDays;

    private String preferredTime;

    private String medicalConditions;

    private String familyHistory;

    private String exerciseRestrictions;

    private Boolean hasCardiovascularRisk;

    private Boolean hasDiabetesRisk;

    private String healthGoal;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

package com.example.backend.dto;

import lombok.Data;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 健康档案请求
 */
@Data
public class HealthProfileRequest {

    @NotNull(message = "身高不能为空")
    private BigDecimal height;

    @NotNull(message = "当前体重不能为空")
    private BigDecimal currentWeight;

    private BigDecimal targetWeight;

    private String fitnessLevel;

    private Integer weeklyWorkoutDays;

    private String preferredTime;

    private String medicalConditions;

    private String familyHistory;

    private String exerciseRestrictions;

    private Boolean hasCardiovascularRisk;

    private Boolean hasDiabetesRisk;

    private String healthGoal;
}

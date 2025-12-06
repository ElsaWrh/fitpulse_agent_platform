package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 健康计划实体类
 */
@Data
@TableName("health_plan")
public class HealthPlan {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long agentId;

    private String planType;

    private LocalDate startDate;

    private LocalDate endDate;

    private Integer durationDays;

    private String planConfig;

    private String status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

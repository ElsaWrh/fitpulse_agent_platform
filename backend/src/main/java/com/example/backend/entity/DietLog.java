package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 饮食记录实体类
 */
@Data
@TableName("diet_log")
public class DietLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private LocalDate mealDate;

    private String mealType;

    private Integer calories;

    private Integer protein;

    private Integer carbs;

    private Integer fat;

    private String aiAnalysis;

    private String riskLevel;

    private String notes;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

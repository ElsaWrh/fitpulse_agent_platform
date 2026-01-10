package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 体重记录实体类
 */
@Data
@TableName("weight_log")
public class WeightLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private LocalDateTime measuredAt;

    private BigDecimal weight;

    private BigDecimal bmi;

    private BigDecimal bodyFatPercentage;

    private BigDecimal muscleMass;

    private String notes;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

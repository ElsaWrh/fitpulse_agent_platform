package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
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

    private LocalDate recordDate;

    private BigDecimal weight;

    private BigDecimal bmi;

    private BigDecimal bodyFat;

    private String notes;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

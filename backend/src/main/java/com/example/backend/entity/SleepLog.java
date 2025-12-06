package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 睡眠记录实体类
 */
@Data
@TableName("sleep_log")
public class SleepLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private LocalDate sleepDate;

    private Integer durationMinutes;

    private Integer sleepQuality;

    private Integer deepSleepMinutes;

    private String notes;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

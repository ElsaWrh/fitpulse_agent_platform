package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 训练记录实体类
 */
@Data
@TableName("workout_log")
public class WorkoutLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private LocalDate workoutDate;

    private String workoutType;

    private Integer durationMinutes;

    private Integer caloriesBurned;

    private String intensity;

    private String status;

    private String notes;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

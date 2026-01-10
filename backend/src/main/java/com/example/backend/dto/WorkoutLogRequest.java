package com.example.backend.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 运动记录请求DTO
 */
@Data
public class WorkoutLogRequest {

    private String workoutType;

    private String workoutName;

    private Integer durationMinutes;

    private Integer caloriesBurned;

    private String intensity;

    private BigDecimal distance;

    private Integer heartRateAvg;

    private LocalDate workoutDate;

    private String notes;
}

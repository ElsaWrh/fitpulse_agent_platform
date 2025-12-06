package com.example.backend.dto;

import lombok.Data;

import java.time.LocalDate;

/**
 * 运动记录请求DTO
 */
@Data
public class WorkoutLogRequest {

    private String workoutType;

    private Integer duration;

    private Integer calories;

    private LocalDate workoutDate;

    private String note;
}

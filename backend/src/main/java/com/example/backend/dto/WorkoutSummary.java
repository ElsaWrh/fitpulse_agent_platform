package com.example.backend.dto;

import lombok.Data;

/**
 * 运动统计汇总DTO
 */
@Data
public class WorkoutSummary {

    private Integer totalWorkouts;

    private Integer totalMinutes;

    private Integer totalCalories;

    private Integer weeklyGoal = 3; // 每周目标运动次数

    public WorkoutSummary() {
    }

    public WorkoutSummary(Integer totalWorkouts, Integer totalMinutes, Integer totalCalories) {
        this.totalWorkouts = totalWorkouts;
        this.totalMinutes = totalMinutes;
        this.totalCalories = totalCalories;
    }
}

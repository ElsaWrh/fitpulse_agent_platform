package com.example.backend.controller;

import com.example.backend.common.Result;
import com.example.backend.dto.WorkoutLogRequest;
import com.example.backend.dto.WorkoutSummary;
import com.example.backend.entity.WorkoutLog;
import com.example.backend.service.WorkoutLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;

/**
 * 运动记录控制器
 */
@RestController
@RequestMapping("/health/workout")
@RequiredArgsConstructor
public class WorkoutLogController {

    private final WorkoutLogService workoutLogService;

    /**
     * 添加运动记录
     */
    @PostMapping
    public Result<WorkoutLog> addWorkoutLog(@Valid @RequestBody WorkoutLogRequest request) {
        WorkoutLog workoutLog = workoutLogService.addWorkoutLog(request);
        return Result.success(workoutLog);
    }

    /**
     * 获取运动记录列表
     */
    @GetMapping
    public Result<List<WorkoutLog>> getWorkoutLogs(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<WorkoutLog> logs = workoutLogService.getWorkoutLogs(startDate, endDate);
        return Result.success(logs);
    }

    /**
     * 获取本周运动统计
     */
    @GetMapping("/weekly-summary")
    public Result<WorkoutSummary> getWeeklySummary() {
        WorkoutSummary summary = workoutLogService.getWeeklySummary();
        return Result.success(summary);
    }

    /**
     * 删除运动记录
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteWorkoutLog(@PathVariable Long id) {
        workoutLogService.deleteWorkoutLog(id);
        return Result.success(null);
    }
}

package com.example.backend.service;

import com.example.backend.dto.WorkoutLogRequest;
import com.example.backend.dto.WorkoutSummary;
import com.example.backend.entity.WorkoutLog;

import java.time.LocalDate;
import java.util.List;

/**
 * 运动记录服务接口
 */
public interface WorkoutLogService {

    /**
     * 添加运动记录
     */
    WorkoutLog addWorkoutLog(WorkoutLogRequest request);

    /**
     * 获取用户运动记录列表
     */
    List<WorkoutLog> getWorkoutLogs(LocalDate startDate, LocalDate endDate);

    /**
     * 获取本周运动统计
     */
    WorkoutSummary getWeeklySummary();

    /**
     * 删除运动记录
     */
    void deleteWorkoutLog(Long id);
}

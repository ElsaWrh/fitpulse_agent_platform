package com.example.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.dto.WorkoutLogRequest;
import com.example.backend.dto.WorkoutSummary;
import com.example.backend.entity.WorkoutLog;
import com.example.backend.mapper.WorkoutLogMapper;
import com.example.backend.service.WorkoutLogService;
import com.example.backend.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

/**
 * 运动记录服务实现
 */
@Service
@RequiredArgsConstructor
public class WorkoutLogServiceImpl implements WorkoutLogService {

    private final WorkoutLogMapper workoutLogMapper;

    @Override
    public WorkoutLog addWorkoutLog(WorkoutLogRequest request) {
        Long userId = UserContext.getUserId();

        WorkoutLog workoutLog = new WorkoutLog();
        BeanUtils.copyProperties(request, workoutLog);
        workoutLog.setUserId(userId);

        // 如果没有指定日期，使用当前日期
        if (workoutLog.getWorkoutDate() == null) {
            workoutLog.setWorkoutDate(LocalDate.now());
        }

        workoutLogMapper.insert(workoutLog);
        return workoutLog;
    }

    @Override
    public List<WorkoutLog> getWorkoutLogs(LocalDate startDate, LocalDate endDate) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<WorkoutLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WorkoutLog::getUserId, userId);

        if (startDate != null) {
            wrapper.ge(WorkoutLog::getWorkoutDate, startDate);
        }
        if (endDate != null) {
            wrapper.le(WorkoutLog::getWorkoutDate, endDate);
        }

        wrapper.orderByDesc(WorkoutLog::getWorkoutDate);

        return workoutLogMapper.selectList(wrapper);
    }

    @Override
    public WorkoutSummary getWeeklySummary() {
        Long userId = UserContext.getUserId();

        // 获取本周一和周日
        LocalDate now = LocalDate.now();
        LocalDate startOfWeek = now.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = now.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));

        // 查询本周运动记录
        List<WorkoutLog> weeklyLogs = getWorkoutLogs(startOfWeek, endOfWeek);

        // 计算统计
        int totalWorkouts = weeklyLogs.size();
        int totalMinutes = weeklyLogs.stream()
                .mapToInt(log -> log.getDurationMinutes() != null ? log.getDurationMinutes() : 0)
                .sum();
        int totalCalories = weeklyLogs.stream()
                .mapToInt(log -> log.getCaloriesBurned() != null ? log.getCaloriesBurned() : 0)
                .sum();

        return new WorkoutSummary(totalWorkouts, totalMinutes, totalCalories);
    }

    @Override
    public void deleteWorkoutLog(Long id) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<WorkoutLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WorkoutLog::getId, id);
        wrapper.eq(WorkoutLog::getUserId, userId);

        workoutLogMapper.delete(wrapper);
    }
}

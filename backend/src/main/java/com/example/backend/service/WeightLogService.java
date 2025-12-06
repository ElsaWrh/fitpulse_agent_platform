package com.example.backend.service;

import com.example.backend.dto.WeightLogRequest;
import com.example.backend.entity.WeightLog;

import java.time.LocalDate;
import java.util.List;

/**
 * 体重记录服务接口
 */
public interface WeightLogService {

    /**
     * 添加体重记录
     */
    WeightLog addWeightLog(WeightLogRequest request);

    /**
     * 获取用户体重记录列表
     */
    List<WeightLog> getWeightLogs(LocalDate startDate, LocalDate endDate);

    /**
     * 获取最近的体重记录
     */
    WeightLog getLatestWeight();

    /**
     * 删除体重记录
     */
    void deleteWeightLog(Long id);
}

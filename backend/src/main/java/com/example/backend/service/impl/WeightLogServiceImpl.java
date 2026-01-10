package com.example.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.dto.WeightLogRequest;
import com.example.backend.entity.WeightLog;
import com.example.backend.mapper.WeightLogMapper;
import com.example.backend.service.WeightLogService;
import com.example.backend.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

/**
 * 体重记录服务实现
 */
@Service
@RequiredArgsConstructor
public class WeightLogServiceImpl implements WeightLogService {

    private final WeightLogMapper weightLogMapper;

    @Override
    public WeightLog addWeightLog(WeightLogRequest request) {
        Long userId = UserContext.getUserId();

        WeightLog weightLog = new WeightLog();
        BeanUtils.copyProperties(request, weightLog);
        weightLog.setUserId(userId);

        // 如果没有指定日期，使用当前时间
        if (weightLog.getMeasuredAt() == null) {
            weightLog.setMeasuredAt(java.time.LocalDateTime.now());
        }

        weightLogMapper.insert(weightLog);
        return weightLog;
    }

    @Override
    public List<WeightLog> getWeightLogs(LocalDate startDate, LocalDate endDate) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<WeightLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WeightLog::getUserId, userId);

        if (startDate != null) {
            wrapper.ge(WeightLog::getMeasuredAt, startDate.atStartOfDay());
        }
        if (endDate != null) {
            wrapper.le(WeightLog::getMeasuredAt, endDate.atTime(23, 59, 59));
        }

        wrapper.orderByDesc(WeightLog::getMeasuredAt);

        return weightLogMapper.selectList(wrapper);
    }

    @Override
    public WeightLog getLatestWeight() {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<WeightLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WeightLog::getUserId, userId);
        wrapper.orderByDesc(WeightLog::getMeasuredAt);
        wrapper.last("LIMIT 1");

        return weightLogMapper.selectOne(wrapper);
    }

    @Override
    public void deleteWeightLog(Long id) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<WeightLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(WeightLog::getId, id);
        wrapper.eq(WeightLog::getUserId, userId);

        weightLogMapper.delete(wrapper);
    }
}

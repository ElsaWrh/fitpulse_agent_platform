package com.example.backend.controller;

import com.example.backend.common.Result;
import com.example.backend.dto.WeightLogRequest;
import com.example.backend.entity.WeightLog;
import com.example.backend.service.WeightLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;

/**
 * 体重记录控制器
 */
@RestController
@RequestMapping("/health/weight")
@RequiredArgsConstructor
public class WeightLogController {

    private final WeightLogService weightLogService;

    /**
     * 添加体重记录
     */
    @PostMapping
    public Result<WeightLog> addWeightLog(@Valid @RequestBody WeightLogRequest request) {
        WeightLog weightLog = weightLogService.addWeightLog(request);
        return Result.success(weightLog);
    }

    /**
     * 获取体重记录列表
     */
    @GetMapping
    public Result<List<WeightLog>> getWeightLogs(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<WeightLog> logs = weightLogService.getWeightLogs(startDate, endDate);
        return Result.success(logs);
    }

    /**
     * 获取最近的体重记录
     */
    @GetMapping("/latest")
    public Result<WeightLog> getLatestWeight() {
        WeightLog weightLog = weightLogService.getLatestWeight();
        return Result.success(weightLog);
    }

    /**
     * 删除体重记录
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteWeightLog(@PathVariable Long id) {
        weightLogService.deleteWeightLog(id);
        return Result.success(null);
    }
}

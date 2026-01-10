package com.example.backend.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 体重记录请求DTO
 */
@Data
public class WeightLogRequest {

    private BigDecimal weight;

    private LocalDateTime measuredAt;

    private BigDecimal bodyFatPercentage;

    private BigDecimal muscleMass;

    private String notes;
}

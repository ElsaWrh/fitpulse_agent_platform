package com.example.backend.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 体重记录请求DTO
 */
@Data
public class WeightLogRequest {

    private BigDecimal weight;

    private LocalDate recordDate;

    private String note;
}

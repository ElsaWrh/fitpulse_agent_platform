package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * LLM 模型实体类
 */
@Data
@TableName("llm_model")
public class LlmModel {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long providerId;

    private String modelName;

    private String modelCode;

    private String description;

    private Integer maxTokens;

    private Boolean supportsFunctionCalling;

    private Boolean supportsVision;

    @TableField("input_price_per_1k_tokens")
    private BigDecimal inputPricePer1kTokens;

    @TableField("output_price_per_1k_tokens")
    private BigDecimal outputPricePer1kTokens;

    private Boolean isEnabled;

    private Integer sortOrder;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

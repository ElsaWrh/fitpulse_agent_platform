package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * LLM 提供商实体类
 */
@Data
@TableName("llm_provider")
public class LlmProvider {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String apiBaseUrl;

    private String apiKey;

    private String providerType;

    private String status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

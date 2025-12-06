package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

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

    private String modelType;

    private String displayName;

    private String description;

    private Boolean isDefault;

    private String status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

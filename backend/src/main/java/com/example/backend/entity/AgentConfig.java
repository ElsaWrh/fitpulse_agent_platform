package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 智能体配置实体类
 */
@Data
@TableName("agent_config")
public class AgentConfig {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long agentId;

    @TableField("config_key")
    private String configKey;

    @TableField("config_value")
    private String configValue;

    private String description;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

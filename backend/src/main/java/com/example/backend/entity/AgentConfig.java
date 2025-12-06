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

    private String systemPrompt;

    private String languageStyle;

    private Boolean canReadProfile;

    private Boolean canReadWorkouts;

    private Boolean canReadDietLogs;

    private String kbScope;

    private Long llmModelId;

    private String llmParams;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

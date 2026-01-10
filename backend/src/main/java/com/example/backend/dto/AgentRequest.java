package com.example.backend.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 智能体创建/更新请求DTO
 */
@Data
public class AgentRequest {
    private String name;
    private String avatarUrl;
    private String description;
    private String systemPrompt;
    private String greetingMessage;
    private Long llmProviderId;
    private Long llmModelId;
    private BigDecimal temperature;
    private Integer maxTokens;
    private Boolean isPublic;
}

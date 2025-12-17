package com.example.backend.dto;

import lombok.Data;

import java.util.List;

/**
 * 智能体配置请求DTO
 */
@Data
public class AgentConfigRequest {
    private String systemPrompt;
    private String languageStyle;
    private Boolean canReadProfile;
    private Boolean canReadWorkouts;
    private Boolean canReadDietLogs;
    private Long llmModelId;
    private List<Long> kbScope;
    private String customSafetyPrompt;
}

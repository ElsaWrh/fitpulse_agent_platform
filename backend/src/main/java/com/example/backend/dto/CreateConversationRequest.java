package com.example.backend.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 创建会话请求
 */
@Data
public class CreateConversationRequest {

    @NotNull(message = "智能体ID不能为空")
    private Long agentId;

    @NotBlank(message = "会话标题不能为空")
    private String title;
}

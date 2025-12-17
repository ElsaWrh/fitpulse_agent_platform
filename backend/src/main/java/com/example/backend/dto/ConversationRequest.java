package com.example.backend.dto;

import lombok.Data;

/**
 * 创建会话请求
 */
@Data
public class ConversationRequest {
    private Long agentId;
    private String title;
}

package com.example.backend.dto;

import lombok.Data;
import java.util.List;

/**
 * 发送消息请求
 */
@Data
public class ChatRequest {
    /**
     * 智能体ID (可选，使用字符串兼容 health_assistant 等预置ID)
     */
    private String agentId;

    /**
     * 会话ID (可选，如果没有则创建新会话)
     */
    private Long conversationId;

    /**
     * 用户消息内容
     */
    private String message;

    /**
     * 历史消息 (可选)
     */
    private List<ChatMessage> history;

    @Data
    public static class ChatMessage {
        private String role; // user, assistant, system
        private String content;
    }
}

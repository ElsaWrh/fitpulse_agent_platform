package com.example.backend.dto;

import lombok.Data;

import java.util.List;

/**
 * 智能体创建/更新请求DTO
 */
@Data
public class AgentRequest {
    private String name;
    private String avatarUrl;
    private String description;
    private String category;
    private String visibility;
}

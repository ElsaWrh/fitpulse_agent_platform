package com.example.backend.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;

/**
 * 发送消息请求
 */
@Data
public class SendMessageRequest {

    @NotBlank(message = "消息内容不能为空")
    private String content;

    private Boolean useHealthData;
}

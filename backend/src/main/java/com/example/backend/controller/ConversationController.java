package com.example.backend.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.backend.common.Result;
import com.example.backend.dto.ChatRequest;
import com.example.backend.dto.ChatResponse;
import com.example.backend.dto.ConversationRequest;
import com.example.backend.entity.Conversation;
import com.example.backend.entity.Message;
import com.example.backend.service.ChatService;
import com.example.backend.service.ConversationService;
import com.example.backend.utils.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * 会话控制器
 * 参照 CodeHubot 的 chat.py 实现
 */
@Slf4j
@RestController
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationService conversationService;
    private final ChatService chatService;
    private final JwtUtil jwtUtil;

    /**
     * 创建会话
     */
    @PostMapping("/conversation/create")
    public Result<Conversation> createConversation(
            @RequestBody ConversationRequest request,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Conversation conversation = conversationService.createConversation(
                userId,
                request.getAgentId(),
                request.getTitle());
        return Result.success(conversation);
    }

    /**
     * 获取会话列表
     */
    @GetMapping("/conversation/list")
    public Result<Page<Conversation>> getConversations(
            @RequestParam(defaultValue = "1") int current,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long agentId,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<Conversation> page = conversationService.getConversations(userId, agentId, current, size);
        return Result.success(page);
    }

    /**
     * 获取会话详情
     */
    @GetMapping("/conversation/{id}")
    public Result<Conversation> getConversation(
            @PathVariable Long id,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Conversation conversation = conversationService.getConversationById(id);

        if (conversation == null) {
            return Result.error("会话不存在");
        }
        if (!conversation.getUserId().equals(userId)) {
            return Result.error("无权访问此会话");
        }

        return Result.success(conversation);
    }

    /**
     * 删除会话
     */
    @DeleteMapping("/conversation/{id}")
    public Result<Void> deleteConversation(
            @PathVariable Long id,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        conversationService.deleteConversation(id, userId);
        return Result.success(null);
    }

    /**
     * 获取会话消息历史
     */
    @GetMapping("/message/history")
    public Result<List<Message>> getMessageHistory(
            @RequestParam Long conversationId,
            @RequestParam(defaultValue = "50") int limit,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);

        // 验证会话归属
        Conversation conversation = conversationService.getConversationById(conversationId);
        if (conversation == null || !conversation.getUserId().equals(userId)) {
            return Result.error("无权访问此会话");
        }

        List<Message> messages = conversationService.getMessages(conversationId, limit);
        return Result.success(messages);
    }

    /**
     * 发送消息 (与智能体对话)
     */
    @PostMapping("/message/send")
    public Result<ChatResponse> sendMessage(
            @RequestBody ChatRequest request,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);

        try {
            ChatResponse response = chatService.chat(userId, request);
            return Result.success(response);
        } catch (Exception e) {
            log.error("发送消息失败: {}", e.getMessage(), e);
            return Result.error("发送消息失败: " + e.getMessage());
        }
    }

    /**
     * 与智能体对话 (简化接口，自动创建会话)
     */
    @PostMapping("/chat")
    public Result<ChatResponse> chat(
            @RequestBody ChatRequest request,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);

        try {
            ChatResponse response = chatService.chat(userId, request);
            return Result.success(response);
        } catch (Exception e) {
            log.error("对话失败: {}", e.getMessage(), e);
            return Result.error("对话失败: " + e.getMessage());
        }
    }

    /**
     * 从请求中获取用户ID
     */
    private Long getUserIdFromRequest(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        return jwtUtil.getUserIdFromToken(token);
    }
}

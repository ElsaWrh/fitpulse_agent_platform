package com.example.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.backend.entity.Conversation;
import com.example.backend.entity.Message;
import com.example.backend.mapper.ConversationMapper;
import com.example.backend.mapper.MessageMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 会话服务
 */
@Service
@RequiredArgsConstructor
public class ConversationService {

    private final ConversationMapper conversationMapper;
    private final MessageMapper messageMapper;

    /**
     * 创建会话
     */
    @Transactional
    public Conversation createConversation(Long userId, Long agentId, String title) {
        Conversation conversation = new Conversation();
        conversation.setUserId(userId);
        conversation.setAgentId(agentId);
        conversation.setTitle(title != null ? title : "新对话");
        conversation.setStatus("ACTIVE");
        conversation.setMessageCount(0);
        conversationMapper.insert(conversation);
        return conversation;
    }

    /**
     * 获取用户的会话列表
     */
    public Page<Conversation> getConversations(Long userId, Long agentId, int current, int size) {
        Page<Conversation> page = new Page<>(current, size);
        LambdaQueryWrapper<Conversation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Conversation::getUserId, userId)
                .eq(Conversation::getDeleted, 0)
                .orderByDesc(Conversation::getUpdatedAt);

        if (agentId != null) {
            wrapper.eq(Conversation::getAgentId, agentId);
        }

        return conversationMapper.selectPage(page, wrapper);
    }

    /**
     * 获取会话详情
     */
    public Conversation getConversationById(Long id) {
        return conversationMapper.selectById(id);
    }

    /**
     * 删除会话
     */
    @Transactional
    public void deleteConversation(Long id, Long userId) {
        LambdaQueryWrapper<Conversation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Conversation::getId, id)
                .eq(Conversation::getUserId, userId);
        conversationMapper.delete(wrapper);
    }

    /**
     * 更新会话消息数和最后消息时间
     */
    public void updateConversationStats(Long conversationId) {
        Conversation conversation = conversationMapper.selectById(conversationId);
        if (conversation != null) {
            conversation.setMessageCount(conversation.getMessageCount() + 1);
            conversation.setLastMessageAt(LocalDateTime.now());
            conversationMapper.updateById(conversation);
        }
    }

    /**
     * 添加消息到会话
     */
    @Transactional
    public Message addMessage(Long conversationId, String role, String content, String modelName) {
        Message message = new Message();
        message.setConversationId(conversationId);
        message.setRole(role);
        message.setContent(content);
        message.setModelName(modelName);
        messageMapper.insert(message);

        // 更新会话统计
        updateConversationStats(conversationId);

        return message;
    }

    /**
     * 获取会话的消息历史
     */
    public List<Message> getMessages(Long conversationId, int limit) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getConversationId, conversationId)
                .orderByAsc(Message::getCreatedAt)
                .last("LIMIT " + limit);
        return messageMapper.selectList(wrapper);
    }

    /**
     * 获取会话的所有消息
     */
    public List<Message> getAllMessages(Long conversationId) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getConversationId, conversationId)
                .orderByAsc(Message::getCreatedAt);
        return messageMapper.selectList(wrapper);
    }
}

package com.example.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.entity.Agent;
import com.example.backend.entity.AgentConfig;
import com.example.backend.mapper.AgentConfigMapper;
import com.example.backend.mapper.AgentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 智能体服务类
 */
@Service
@RequiredArgsConstructor
public class AgentService {

    private final AgentMapper agentMapper;
    private final AgentConfigMapper agentConfigMapper;

    /**
     * 获取智能体列表
     */
    public List<Agent> getAgents(String category, String visibility, Long userId) {
        LambdaQueryWrapper<Agent> wrapper = new LambdaQueryWrapper<>();

        // 按可见性过滤
        if (visibility != null && !visibility.isEmpty()) {
            if ("PUBLIC".equals(visibility)) {
                wrapper.eq(Agent::getIsPublic, true);
            } else if ("PRIVATE".equals(visibility)) {
                wrapper.eq(Agent::getIsPublic, false);
                wrapper.eq(Agent::getUserId, userId);
            }
        } else {
            // 默认显示公开的和当前用户创建的
            wrapper.and(w -> w.eq(Agent::getIsPublic, true)
                    .or()
                    .eq(Agent::getUserId, userId));
        }

        // 只显示激活状态
        wrapper.eq(Agent::getStatus, "ACTIVE");
        wrapper.orderByDesc(Agent::getCreatedAt);

        return agentMapper.selectList(wrapper);
    }

    /**
     * 根据ID获取智能体
     */
    public Agent getAgentById(Long id) {
        return agentMapper.selectById(id);
    }

    /**
     * 创建智能体
     */
    @Transactional
    public Agent createAgent(Agent agent) {
        // 设置默认值
        if (agent.getStatus() == null) {
            agent.setStatus("ACTIVE");
        }
        if (agent.getIsPublic() == null) {
            agent.setIsPublic(false);
        }
        if (agent.getSystemPrompt() == null || agent.getSystemPrompt().isEmpty()) {
            agent.setSystemPrompt("你是一个智能助手，可以帮助用户解答问题。");
        }
        if (agent.getGreetingMessage() == null || agent.getGreetingMessage().isEmpty()) {
            agent.setGreetingMessage("你好！我是你的智能助手，有什么可以帮助你的吗？");
        }
        if (agent.getTemperature() == null) {
            agent.setTemperature(new java.math.BigDecimal("0.7"));
        }
        if (agent.getMaxTokens() == null) {
            agent.setMaxTokens(2000);
        }
        // 设置默认 LLM 模型为 Qwen-Turbo
        if (agent.getLlmModelId() == null) {
            agent.setLlmModelId(8L); // Qwen-Turbo
        }

        agentMapper.insert(agent);

        // 创建默认配置（键值对形式）
        createAgentConfig(agent.getId(), "language_style", "ENCOURAGING", "语言风格");
        createAgentConfig(agent.getId(), "can_read_profile", "false", "是否可读取健康档案");
        createAgentConfig(agent.getId(), "can_read_workouts", "false", "是否可读取运动记录");
        createAgentConfig(agent.getId(), "can_read_diet_logs", "false", "是否可读取饮食记录");

        return agent;
    }

    /**
     * 创建智能体配置项
     */
    private void createAgentConfig(Long agentId, String key, String value, String description) {
        AgentConfig config = new AgentConfig();
        config.setAgentId(agentId);
        config.setConfigKey(key);
        config.setConfigValue(value);
        config.setDescription(description);
        agentConfigMapper.insert(config);
    }

    /**
     * 更新智能体
     */
    public Agent updateAgent(Long id, Agent agent) {
        agent.setId(id);
        agentMapper.updateById(agent);
        return agentMapper.selectById(id);
    }

    /**
     * 删除智能体
     */
    @Transactional
    public void deleteAgent(Long id) {
        // 删除智能体
        agentMapper.deleteById(id);

        // 删除配置
        LambdaQueryWrapper<AgentConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AgentConfig::getAgentId, id);
        agentConfigMapper.delete(wrapper);
    }

    /**
     * 获取智能体配置列表
     */
    public List<AgentConfig> getAgentConfig(Long agentId) {
        LambdaQueryWrapper<AgentConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AgentConfig::getAgentId, agentId);
        return agentConfigMapper.selectList(wrapper);
    }

    /**
     * 更新智能体配置
     */
    public AgentConfig updateAgentConfig(Long agentId, AgentConfig config) {
        LambdaQueryWrapper<AgentConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AgentConfig::getAgentId, agentId)
                .eq(AgentConfig::getConfigKey, config.getConfigKey());
        AgentConfig existing = agentConfigMapper.selectOne(wrapper);

        if (existing != null) {
            config.setId(existing.getId());
            config.setAgentId(agentId);
            agentConfigMapper.updateById(config);
            return config;
        } else {
            config.setAgentId(agentId);
            agentConfigMapper.insert(config);
            return config;
        }
    }

    /**
     * 批量更新智能体配置（将配置对象转换为 key-value 对）
     */
    @Transactional
    public void updateAgentConfigBatch(Long agentId, java.util.Map<String, Object> configMap) {
        // 将配置 Map 转换为 key-value 配置项
        configMap.forEach((key, value) -> {
            String configValue = value == null ? null : value.toString();

            LambdaQueryWrapper<AgentConfig> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(AgentConfig::getAgentId, agentId)
                    .eq(AgentConfig::getConfigKey, key);
            AgentConfig existing = agentConfigMapper.selectOne(wrapper);

            if (existing != null) {
                // 更新现有配置
                existing.setConfigValue(configValue);
                agentConfigMapper.updateById(existing);
            } else {
                // 创建新配置
                AgentConfig config = new AgentConfig();
                config.setAgentId(agentId);
                config.setConfigKey(key);
                config.setConfigValue(configValue);
                agentConfigMapper.insert(config);
            }
        });
    }
}

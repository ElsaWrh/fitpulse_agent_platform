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

        // 按分类过滤
        if (category != null && !category.isEmpty()) {
            wrapper.eq(Agent::getCategory, category);
        }

        // 按可见性过滤
        if (visibility != null && !visibility.isEmpty()) {
            wrapper.eq(Agent::getVisibility, visibility);
        } else {
            // 默认显示公开的和当前用户创建的
            wrapper.and(w -> w.eq(Agent::getVisibility, "PUBLIC")
                    .or()
                    .eq(Agent::getCreatedBy, userId));
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
        if (agent.getVisibility() == null) {
            agent.setVisibility("PRIVATE");
        }

        agentMapper.insert(agent);

        // 创建默认配置
        AgentConfig config = new AgentConfig();
        config.setAgentId(agent.getId());
        config.setLanguageStyle("ENCOURAGING");
        config.setCanReadProfile(false);
        config.setCanReadWorkouts(false);
        config.setCanReadDietLogs(false);
        agentConfigMapper.insert(config);

        return agent;
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
     * 获取智能体配置
     */
    public AgentConfig getAgentConfig(Long agentId) {
        LambdaQueryWrapper<AgentConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AgentConfig::getAgentId, agentId);
        return agentConfigMapper.selectOne(wrapper);
    }

    /**
     * 更新智能体配置
     */
    public AgentConfig updateAgentConfig(Long agentId, AgentConfig config) {
        LambdaQueryWrapper<AgentConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AgentConfig::getAgentId, agentId);
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
}

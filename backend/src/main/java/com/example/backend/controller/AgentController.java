package com.example.backend.controller;

import com.example.backend.common.Result;
import com.example.backend.dto.AgentConfigRequest;
import com.example.backend.dto.AgentRequest;
import com.example.backend.entity.Agent;
import com.example.backend.entity.AgentConfig;
import com.example.backend.service.AgentService;
import com.example.backend.service.LLMModelService;
import com.example.backend.utils.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 智能体控制器
 */
@RestController
@RequestMapping("/agents")
@RequiredArgsConstructor
public class AgentController {

    private final AgentService agentService;
    private final LLMModelService llmModelService;
    private final JwtUtil jwtUtil;

    /**
     * 获取智能体列表
     */
    @GetMapping
    public Result<List<Agent>> getAgents(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String visibility,
            HttpServletRequest request) {

        Long userId = getUserIdFromRequest(request);
        List<Agent> agents = agentService.getAgents(category, visibility, userId);
        return Result.success(agents);
    }

    /**
     * 获取智能体详情
     */
    @GetMapping("/{id}")
    public Result<Agent> getAgent(@PathVariable Long id) {
        Agent agent = agentService.getAgentById(id);
        if (agent == null) {
            return Result.error("智能体不存在");
        }
        return Result.success(agent);
    }

    /**
     * 创建智能体
     */
    @PostMapping
    public Result<Agent> createAgent(@RequestBody AgentRequest request, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);

        Agent agent = new Agent();
        BeanUtils.copyProperties(request, agent);
        agent.setUserId(userId);

        Agent created = agentService.createAgent(agent);
        return Result.success(created);
    }

    /**
     * 更新智能体
     */
    @PutMapping("/{id}")
    public Result<Agent> updateAgent(@PathVariable Long id, @RequestBody AgentRequest request) {
        Agent agent = new Agent();
        BeanUtils.copyProperties(request, agent);

        Agent updated = agentService.updateAgent(id, agent);
        return Result.success(updated);
    }

    /**
     * 删除智能体
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteAgent(@PathVariable Long id) {
        agentService.deleteAgent(id);
        return Result.success(null);
    }

    /**
     * 获取智能体配置
     */
    @GetMapping("/{id}/config")
    public Result<List<AgentConfig>> getAgentConfig(@PathVariable Long id) {
        List<AgentConfig> config = agentService.getAgentConfig(id);
        return Result.success(config);
    }

    /**
     * 更新智能体配置
     */
    @PutMapping("/{id}/config")
    public Result<String> updateAgentConfig(
            @PathVariable Long id,
            @RequestBody Map<String, Object> configMap) {

        // 1. 更新 Agent 表中的核心字段
        Agent agent = agentService.getAgentById(id);
        if (agent == null) {
            return Result.error("智能体不存在");
        }

        // 提取核心配置字段更新到 agent 表
        if (configMap.containsKey("systemPrompt")) {
            agent.setSystemPrompt((String) configMap.get("systemPrompt"));
        }
        if (configMap.containsKey("llmModelId")) {
            Object modelId = configMap.get("llmModelId");
            if (modelId != null) {
                agent.setLlmModelId(modelId instanceof Number ? ((Number) modelId).longValue()
                        : Long.parseLong(modelId.toString()));
            }
        }
        agentService.updateAgent(id, agent);

        // 2. 更新扩展配置到 agent_config 表（key-value 结构）
        Map<String, Object> extConfigMap = new HashMap<>();

        // 移除核心字段，只保留扩展配置
        configMap.remove("systemPrompt");
        configMap.remove("llmModelId");

        // 转换布尔值为字符串，转换数组为 JSON
        configMap.forEach((key, value) -> {
            if (value instanceof Boolean) {
                extConfigMap.put(key, value.toString());
            } else if (value instanceof List) {
                try {
                    extConfigMap.put(key, new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(value));
                } catch (Exception e) {
                    extConfigMap.put(key, value.toString());
                }
            } else {
                extConfigMap.put(key, value);
            }
        });

        agentService.updateAgentConfigBatch(id, extConfigMap);

        return Result.success("配置更新成功");
    }

    /**
     * 从请求中获取用户ID
     */
    private Long getUserIdFromRequest(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            return jwtUtil.getUserIdFromToken(token);
        }
        return null;
    }
}

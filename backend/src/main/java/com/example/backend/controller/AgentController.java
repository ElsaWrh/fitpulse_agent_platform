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
import java.util.List;

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
        agent.setCreatedBy(userId);

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
    public Result<AgentConfig> getAgentConfig(@PathVariable Long id) {
        AgentConfig config = agentService.getAgentConfig(id);
        if (config == null) {
            return Result.error("配置不存在");
        }
        return Result.success(config);
    }

    /**
     * 更新智能体配置
     */
    @PutMapping("/{id}/config")
    public Result<AgentConfig> updateAgentConfig(
            @PathVariable Long id,
            @RequestBody AgentConfigRequest request) {

        AgentConfig config = new AgentConfig();
        BeanUtils.copyProperties(request, config);

        AgentConfig updated = agentService.updateAgentConfig(id, config);
        return Result.success(updated);
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

package com.example.backend.controller;

import com.example.backend.common.Result;
import com.example.backend.entity.LlmModel;
import com.example.backend.entity.LlmProvider;
import com.example.backend.service.LLMModelService;
import com.example.backend.service.LlmService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * LLM模型控制器
 */
@Slf4j
@RestController
@RequestMapping("/llm")
@RequiredArgsConstructor
public class LLMController {

    private final LLMModelService llmModelService;
    private final LlmService llmService;

    /**
     * 获取所有启用的模型
     */
    @GetMapping("/models")
    public Result<List<LlmModel>> getModels() {
        List<LlmModel> models = llmModelService.getEnabledModels();
        return Result.success(models);
    }

    /**
     * 获取模型详情
     */
    @GetMapping("/models/{id}")
    public Result<LlmModel> getModel(@PathVariable Long id) {
        LlmModel model = llmModelService.getModelById(id);
        if (model == null) {
            return Result.error("模型不存在");
        }
        return Result.success(model);
    }

    /**
     * 获取所有 LLM 提供商
     */
    @GetMapping("/providers")
    public Result<List<LlmProvider>> getProviders() {
        List<LlmProvider> providers = llmService.getAllProviders();
        // 隐藏 API Key 详细信息，只显示是否已配置
        providers.forEach(p -> {
            if (p.getApiKey() != null && !p.getApiKey().isEmpty()) {
                p.setApiKey("sk-****已配置****");
            } else {
                p.setApiKey("");
            }
        });
        return Result.success(providers);
    }

    /**
     * 更新提供商 API Key
     */
    @PostMapping("/providers/{providerId}/api-key")
    public Result<Void> updateApiKey(
            @PathVariable Long providerId,
            @RequestBody Map<String, String> body) {
        String apiKey = body.get("apiKey");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return Result.error("API Key 不能为空");
        }

        boolean success = llmService.updateProviderApiKey(providerId, apiKey.trim());
        if (success) {
            log.info("更新提供商 {} 的 API Key 成功", providerId);
            return Result.success(null);
        } else {
            return Result.error("更新失败，提供商不存在");
        }
    }

    /**
     * 测试 LLM 连接
     */
    @PostMapping("/test-connection")
    public Result<String> testConnection() {
        try {
            LlmService.LlmModelWithProvider modelWithProvider = llmService.getModelWithProvider(null);
            if (modelWithProvider == null) {
                return Result.error("未配置 LLM 模型");
            }

            String apiKey = modelWithProvider.provider().getApiKey();
            if (apiKey == null || apiKey.isEmpty()) {
                return Result.error("API Key 未配置");
            }

            return Result.success("LLM 配置有效：" + modelWithProvider.provider().getName()
                    + " / " + modelWithProvider.model().getModelName());
        } catch (Exception e) {
            log.error("测试 LLM 连接失败", e);
            return Result.error("连接测试失败：" + e.getMessage());
        }
    }
}

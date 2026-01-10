package com.example.backend.service;

import com.example.backend.dto.ChatRequest;
import com.example.backend.dto.ChatResponse;
import com.example.backend.entity.Agent;
import com.example.backend.entity.AgentConfig;
import com.example.backend.entity.Conversation;
import com.example.backend.entity.LlmModel;
import com.example.backend.entity.Message;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatCompletionResult;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.service.OpenAiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 智能体聊天服务
 * 参照 CodeHubot 的 chat.py 实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatService {

    private final AgentService agentService;
    private final ConversationService conversationService;
    private final LLMModelService llmModelService;
    private final LlmService llmService;

    @Value("${openai.api-key:}")
    private String configApiKey;

    @Value("${openai.base-url:https://api.openai.com/v1/}")
    private String baseUrl;

    @Value("${openai.max-tokens:2048}")
    private Integer maxTokens;

    @Value("${openai.temperature:0.7}")
    private Double temperature;

    // 预置智能体配置
    private static final Map<String, PresetAgentConfig> PRESET_AGENTS = new HashMap<>();

    static {
        PRESET_AGENTS.put("health_assistant", new PresetAgentConfig(
                "AI 健康助手",
                "你是一位专业的AI健康助手,擅长为用户提供综合健康咨询。你需要根据用户的问题,给出科学、实用的健康建议。请用友好和专业的语气与用户交流,帮助他们建立健康的生活方式。"));
        PRESET_AGENTS.put("diet_assistant", new PresetAgentConfig(
                "饮食营养顾问",
                "你是一位专业的营养顾问,专注于饮食分析和营养建议。你需要根据用户的饮食问题,提供科学的饮食建议。请用专业但易懂的语言,帮助用户建立健康的饮食习惯。"));
        PRESET_AGENTS.put("sleep_assistant", new PresetAgentConfig(
                "睡眠改善顾问",
                "你是一位专业的睡眠顾问,专注于睡眠质量改善和作息优化。你需要根据用户的作息问题,提供科学的睡眠建议。请用温和、耐心的语气,帮助用户改善睡眠质量。"));
    }

    /**
     * 与智能体对话
     */
    @Transactional
    public ChatResponse chat(Long userId, ChatRequest request) {
        log.info("开始处理聊天请求: userId={}, agentId={}", userId, request.getAgentId());

        // 1. 获取或创建会话
        Conversation conversation;
        if (request.getConversationId() != null) {
            conversation = conversationService.getConversationById(request.getConversationId());
            if (conversation == null || !conversation.getUserId().equals(userId)) {
                throw new RuntimeException("会话不存在或无权访问");
            }
        } else {
            // 创建新会话
            Long agentId = parseAgentId(request.getAgentId());
            String title = request.getMessage().length() > 20
                    ? request.getMessage().substring(0, 20) + "..."
                    : request.getMessage();
            conversation = conversationService.createConversation(userId, agentId, title);
        }

        // 2. 获取智能体配置
        String systemPrompt = getSystemPrompt(request.getAgentId());
        Long modelId = getLlmModelId(request.getAgentId());

        // 3. 构建消息列表
        List<ChatMessage> messages = new ArrayList<>();

        // 添加系统提示词
        messages.add(new ChatMessage("system", systemPrompt));

        // 添加历史消息
        if (request.getHistory() != null && !request.getHistory().isEmpty()) {
            for (ChatRequest.ChatMessage historyMsg : request.getHistory()) {
                messages.add(new ChatMessage(historyMsg.getRole(), historyMsg.getContent()));
            }
        } else {
            // 从数据库加载历史消息
            List<Message> dbMessages = conversationService.getMessages(conversation.getId(), 20);
            for (Message dbMsg : dbMessages) {
                messages.add(new ChatMessage(dbMsg.getRole(), dbMsg.getContent()));
            }
        }

        // 添加当前用户消息
        messages.add(new ChatMessage("user", request.getMessage()));

        // 4. 保存用户消息
        conversationService.addMessage(conversation.getId(), "user", request.getMessage(), null);

        // 5. 调用 LLM
        String aiResponse;
        ChatResponse.TokenUsage tokenUsage = null;

        try {
            ChatCompletionResult result = callOpenAI(messages, modelId);
            aiResponse = result.getChoices().get(0).getMessage().getContent();

            if (result.getUsage() != null) {
                tokenUsage = ChatResponse.TokenUsage.builder()
                        .promptTokens((int) result.getUsage().getPromptTokens())
                        .completionTokens((int) result.getUsage().getCompletionTokens())
                        .totalTokens((int) result.getUsage().getTotalTokens())
                        .build();
            }
        } catch (Exception e) {
            log.error("调用 LLM 失败: {}", e.getMessage(), e);
            aiResponse = "抱歉,我暂时无法回答您的问题。请稍后再试。";
        }

        // 6. 保存 AI 回复
        conversationService.addMessage(conversation.getId(), "assistant", aiResponse, null);

        // 7. 返回响应
        return ChatResponse.builder()
                .response(aiResponse)
                .conversationId(conversation.getId())
                .tokenUsage(tokenUsage)
                .build();
    }

    /**
     * 解析智能体ID (支持字符串预置ID和数字ID)
     */
    private Long parseAgentId(String agentId) {
        if (agentId == null) {
            return 1L; // 默认使用第一个智能体
        }

        // 预置智能体映射到数据库ID
        switch (agentId) {
            case "health_assistant":
                return 1L;
            case "diet_assistant":
                return 2L;
            case "sleep_assistant":
                return 3L;
            default:
                try {
                    return Long.parseLong(agentId);
                } catch (NumberFormatException e) {
                    return 1L;
                }
        }
    }

    /**
     * 获取系统提示词
     */
    private String getSystemPrompt(String agentId) {
        // 先检查预置智能体
        PresetAgentConfig presetConfig = PRESET_AGENTS.get(agentId);
        if (presetConfig != null) {
            return presetConfig.systemPrompt;
        }

        // 从数据库获取 Agent 的 systemPrompt
        try {
            Long id = Long.parseLong(agentId);
            Agent agent = agentService.getAgentById(id);
            if (agent != null && agent.getSystemPrompt() != null) {
                return agent.getSystemPrompt();
            }
        } catch (Exception e) {
            log.warn("获取智能体配置失败: {}", e.getMessage());
        }

        // 默认提示词
        return "你是一位专业的健康助手,请友好地回答用户的健康相关问题。";
    }

    /**
     * 获取智能体配置的LLM模型ID
     */
    private Long getLlmModelId(String agentId) {
        // 预置智能体使用默认模型
        PresetAgentConfig presetConfig = PRESET_AGENTS.get(agentId);
        if (presetConfig != null) {
            return null; // 使用默认模型
        }

        // 从数据库获取
        try {
            Long id = Long.parseLong(agentId);
            Agent agent = agentService.getAgentById(id);
            if (agent != null && agent.getLlmModelId() != null) {
                return agent.getLlmModelId();
            }
        } catch (Exception e) {
            log.warn("获取智能体LLM模型失败: {}", e.getMessage());
        }

        return null; // 使用默认模型
    }

    /**
     * 调用 OpenAI API
     */
    private ChatCompletionResult callOpenAI(List<ChatMessage> messages, Long agentModelId) {
        // 优先使用智能体配置的模型
        String effectiveApiKey = null;
        String effectiveModel = null;
        String effectiveBaseUrl = baseUrl;

        try {
            LlmService.LlmModelWithProvider modelWithProvider = llmService.getModelWithProvider(agentModelId);
            if (modelWithProvider != null) {
                effectiveApiKey = modelWithProvider.provider().getApiKey();
                effectiveModel = modelWithProvider.model().getModelCode();
                if (modelWithProvider.provider().getApiBaseUrl() != null) {
                    effectiveBaseUrl = modelWithProvider.provider().getApiBaseUrl();
                }
                log.info("使用配置 - Provider: {}, Model: {}, BaseURL: {}",
                        modelWithProvider.provider().getName(), effectiveModel, effectiveBaseUrl);
            }
        } catch (Exception e) {
            log.warn("从数据库获取 LLM 配置失败: {}", e.getMessage());
        }

        // 如果数据库没有配置，尝试环境变量
        if (effectiveApiKey == null || effectiveApiKey.isEmpty()) {
            effectiveApiKey = System.getenv("OPENAI_API_KEY");
        }

        // 最后尝试配置文件
        if (effectiveApiKey == null || effectiveApiKey.isEmpty()) {
            effectiveApiKey = configApiKey;
        }

        if (effectiveApiKey == null || effectiveApiKey.isEmpty()) {
            throw new RuntimeException("LLM API Key 未配置，请在个人中心配置 API 密钥");
        }

        if (effectiveModel == null || effectiveModel.isEmpty()) {
            throw new RuntimeException("LLM 模型未配置，请为智能体选择一个模型");
        }

        // 判断是否使用自定义 Base URL（阿里云百炼等）
        if (effectiveBaseUrl != null && !effectiveBaseUrl.isEmpty() && !effectiveBaseUrl.contains("api.openai.com")) {
            // 使用 RestTemplate 直接调用兼容 API
            return callCompatibleApi(effectiveApiKey, effectiveBaseUrl, effectiveModel, messages);
        }

        // 使用 OpenAI 官方库
        OpenAiService service = new OpenAiService(effectiveApiKey, Duration.ofSeconds(60));

        ChatCompletionRequest request = ChatCompletionRequest.builder()
                .model(effectiveModel)
                .messages(messages)
                .maxTokens(maxTokens)
                .temperature(temperature)
                .build();

        return service.createChatCompletion(request);
    }

    /**
     * 使用 RestTemplate 调用兼容 OpenAI 的 API（阿里云百炼、智谱等）
     * 参照 CodeHubot 的 llm_service.py 实现
     */
    private ChatCompletionResult callCompatibleApi(String apiKey, String baseUrl, String model,
            List<ChatMessage> messages) {
        // 构建完整的 API URL（参照 _call_qwen_api）
        String url = baseUrl;
        // 自动修正旧的 API Base URL
        if (url.contains("dashscope.aliyuncs.com/api/")) {
            url = url.replace("/api/v1", "/compatible-mode/v1");
            log.warn("自动修正 API Base URL: {} -> {}", baseUrl, url);
        }
        if (!url.endsWith("/")) {
            url += "/";
        }
        url += "chat/completions";

        log.info("🔍 调用 LLM API:");
        log.info("  URL: {}", url);
        log.info("  Model: {}", model);
        log.info("  Messages Count: {}", messages.size());

        // 构建请求体（参照 CodeHubot 的请求格式）
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", model);
        requestBody.put("max_tokens", maxTokens != null ? maxTokens : 2000);
        requestBody.put("temperature", temperature != null ? temperature : 0.7);
        requestBody.put("top_p", 0.9);

        List<Map<String, String>> messageList = new ArrayList<>();
        for (ChatMessage msg : messages) {
            Map<String, String> msgMap = new HashMap<>();
            msgMap.put("role", msg.getRole());
            msgMap.put("content", msg.getContent());
            messageList.add(msgMap);
        }
        requestBody.put("messages", messageList);

        // 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Accept-Charset", "UTF-8");
        headers.setBearerAuth(apiKey);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        // 发送请求（带超时配置）
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response;
        try {
            response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
        } catch (Exception e) {
            log.error("❌ API 请求失败: {}", e.getMessage());
            throw new RuntimeException("调用 LLM API 失败: " + e.getMessage());
        }

        // 检查响应状态
        if (!response.getStatusCode().is2xxSuccessful()) {
            log.error("❌ API 返回错误状态: {}", response.getStatusCode());
            log.error("  响应内容: {}", response.getBody());
            throw new RuntimeException("LLM API 返回错误: " + response.getStatusCode());
        }

        // 解析响应
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode root = objectMapper.readTree(response.getBody());

            // 检查是否有错误响应
            if (root.has("error")) {
                JsonNode error = root.get("error");
                String errorMsg = error.has("message") ? error.get("message").asText() : "Unknown error";
                log.error("❌ LLM API 返回错误: {}", errorMsg);
                throw new RuntimeException("LLM API 错误: " + errorMsg);
            }

            ChatCompletionResult result = new ChatCompletionResult();

            // 解析 choices
            JsonNode choices = root.get("choices");
            if (choices != null && choices.isArray() && choices.size() > 0) {
                JsonNode firstChoice = choices.get(0);
                JsonNode messageNode = firstChoice.get("message");

                if (messageNode != null) {
                    String content = messageNode.has("content") ? messageNode.get("content").asText() : "";
                    String role = messageNode.has("role") ? messageNode.get("role").asText() : "assistant";

                    com.theokanning.openai.completion.chat.ChatCompletionChoice choice = new com.theokanning.openai.completion.chat.ChatCompletionChoice();
                    ChatMessage chatMessage = new ChatMessage(role, content);
                    choice.setMessage(chatMessage);
                    choice.setIndex(0);

                    result.setChoices(List.of(choice));
                    log.info("✅ LLM 响应成功，内容长度: {} 字符", content.length());
                }
            }

            // 解析 usage（Token 使用量）
            JsonNode usage = root.get("usage");
            if (usage != null) {
                com.theokanning.openai.Usage usageObj = new com.theokanning.openai.Usage();
                usageObj.setPromptTokens(usage.has("prompt_tokens") ? usage.get("prompt_tokens").asLong() : 0);
                usageObj.setCompletionTokens(
                        usage.has("completion_tokens") ? usage.get("completion_tokens").asLong() : 0);
                usageObj.setTotalTokens(usage.has("total_tokens") ? usage.get("total_tokens").asLong() : 0);
                result.setUsage(usageObj);
                log.info("📊 Token 使用: prompt={}, completion={}, total={}",
                        usageObj.getPromptTokens(), usageObj.getCompletionTokens(), usageObj.getTotalTokens());
            }

            return result;

        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            log.error("❌ 解析 API 响应失败: {}", e.getMessage(), e);
            throw new RuntimeException("解析 API 响应失败: " + e.getMessage());
        }
    }

    /**
     * 预置智能体配置
     */
    private static class PresetAgentConfig {
        String name;
        String systemPrompt;

        PresetAgentConfig(String name, String systemPrompt) {
            this.name = name;
            this.systemPrompt = systemPrompt;
        }
    }
}

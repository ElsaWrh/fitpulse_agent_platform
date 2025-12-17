package com.example.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.entity.LlmModel;
import com.example.backend.entity.LlmProvider;
import com.example.backend.mapper.LlmModelMapper;
import com.example.backend.mapper.LlmProviderMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * LLM 服务
 * 管理 LLM 提供商和模型配置
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LlmService {

    private final LlmProviderMapper providerMapper;
    private final LlmModelMapper modelMapper;

    /**
     * 获取所有启用的提供商
     */
    public List<LlmProvider> getEnabledProviders() {
        return providerMapper.selectList(
                new LambdaQueryWrapper<LlmProvider>()
                        .eq(LlmProvider::getStatus, "ENABLED"));
    }

    /**
     * 根据ID获取提供商
     */
    public LlmProvider getProviderById(Long id) {
        return providerMapper.selectById(id);
    }

    /**
     * 获取默认模型
     */
    public LlmModel getDefaultModel() {
        return modelMapper.selectOne(
                new LambdaQueryWrapper<LlmModel>()
                        .eq(LlmModel::getIsDefault, true)
                        .eq(LlmModel::getStatus, "ENABLED")
                        .last("LIMIT 1"));
    }

    /**
     * 根据ID获取模型
     */
    public LlmModel getModelById(Long id) {
        return modelMapper.selectOne(
                new LambdaQueryWrapper<LlmModel>()
                        .eq(LlmModel::getId, id)
                        .eq(LlmModel::getStatus, "ENABLED"));
    }

    /**
     * 获取模型及其提供商信息
     */
    public LlmModelWithProvider getModelWithProvider(Long modelId) {
        LlmModel model;
        if (modelId != null) {
            model = getModelById(modelId);
        } else {
            model = getDefaultModel();
        }

        if (model == null) {
            log.warn("未找到可用的 LLM 模型");
            return null;
        }

        LlmProvider provider = getProviderById(model.getProviderId());
        if (provider == null) {
            log.warn("未找到模型 {} 的提供商", model.getId());
            return null;
        }

        return new LlmModelWithProvider(model, provider);
    }

    /**
     * 更新提供商 API Key
     */
    public boolean updateProviderApiKey(Long providerId, String apiKey) {
        LlmProvider provider = providerMapper.selectById(providerId);
        if (provider == null) {
            return false;
        }
        provider.setApiKey(apiKey);
        return providerMapper.updateById(provider) > 0;
    }

    /**
     * 获取提供商列表（用于前端设置页面）
     */
    public List<LlmProvider> getAllProviders() {
        return providerMapper.selectList(null);
    }

    /**
     * 获取指定提供商的所有模型
     */
    public List<LlmModel> getModelsByProvider(Long providerId) {
        return modelMapper.selectList(
                new LambdaQueryWrapper<LlmModel>()
                        .eq(LlmModel::getProviderId, providerId)
                        .eq(LlmModel::getStatus, "ENABLED"));
    }

    /**
     * 模型和提供商的组合类
     */
    public record LlmModelWithProvider(LlmModel model, LlmProvider provider) {
    }
}

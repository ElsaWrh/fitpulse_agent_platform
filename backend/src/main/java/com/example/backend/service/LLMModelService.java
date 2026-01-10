package com.example.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.backend.entity.LlmModel;
import com.example.backend.mapper.LlmModelMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * LLM模型服务类
 */
@Service
@RequiredArgsConstructor
public class LLMModelService {

    private final LlmModelMapper llmModelMapper;

    /**
     * 获取所有启用的模型
     */
    public List<LlmModel> getEnabledModels() {
        LambdaQueryWrapper<LlmModel> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LlmModel::getIsEnabled, true);
        wrapper.orderByAsc(LlmModel::getSortOrder);
        return llmModelMapper.selectList(wrapper);
    }

    /**
     * 根据ID获取模型
     */
    public LlmModel getModelById(Long id) {
        return llmModelMapper.selectById(id);
    }
}

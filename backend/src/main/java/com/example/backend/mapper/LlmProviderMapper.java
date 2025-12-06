package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.LlmProvider;
import org.apache.ibatis.annotations.Mapper;

/**
 * LLM 提供商 Mapper
 */
@Mapper
public interface LlmProviderMapper extends BaseMapper<LlmProvider> {
}

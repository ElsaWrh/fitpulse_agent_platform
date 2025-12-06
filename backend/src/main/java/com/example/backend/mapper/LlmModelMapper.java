package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.LlmModel;
import org.apache.ibatis.annotations.Mapper;

/**
 * LLM 模型 Mapper
 */
@Mapper
public interface LlmModelMapper extends BaseMapper<LlmModel> {
}

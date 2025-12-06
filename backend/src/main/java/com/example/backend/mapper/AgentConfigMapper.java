package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.AgentConfig;
import org.apache.ibatis.annotations.Mapper;

/**
 * 智能体配置 Mapper
 */
@Mapper
public interface AgentConfigMapper extends BaseMapper<AgentConfig> {
}

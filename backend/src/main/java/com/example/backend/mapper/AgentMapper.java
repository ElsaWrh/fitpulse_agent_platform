package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.Agent;
import org.apache.ibatis.annotations.Mapper;

/**
 * 智能体 Mapper
 */
@Mapper
public interface AgentMapper extends BaseMapper<Agent> {
}

package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.HealthPlan;
import org.apache.ibatis.annotations.Mapper;

/**
 * 健康计划 Mapper
 */
@Mapper
public interface HealthPlanMapper extends BaseMapper<HealthPlan> {
}

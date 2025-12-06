package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.HealthProfile;
import org.apache.ibatis.annotations.Mapper;

/**
 * 健康档案 Mapper
 */
@Mapper
public interface HealthProfileMapper extends BaseMapper<HealthProfile> {
}

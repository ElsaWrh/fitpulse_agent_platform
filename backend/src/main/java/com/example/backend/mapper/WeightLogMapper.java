package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.WeightLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 体重记录 Mapper
 */
@Mapper
public interface WeightLogMapper extends BaseMapper<WeightLog> {
}

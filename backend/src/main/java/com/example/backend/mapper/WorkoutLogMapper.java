package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.WorkoutLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 训练记录 Mapper
 */
@Mapper
public interface WorkoutLogMapper extends BaseMapper<WorkoutLog> {
}

package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.DietLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 饮食记录 Mapper
 */
@Mapper
public interface DietLogMapper extends BaseMapper<DietLog> {
}

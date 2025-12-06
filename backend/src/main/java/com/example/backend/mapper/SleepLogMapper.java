package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.SleepLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 睡眠记录 Mapper
 */
@Mapper
public interface SleepLogMapper extends BaseMapper<SleepLog> {
}

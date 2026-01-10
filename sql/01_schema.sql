-- 设置会话字符集（必须在最开头）
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                    FitPulse 健康平台 - 完整数据库结构                        ║
-- ║                    Complete Database Schema (DDL)                          ║
-- ╠════════════════════════════════════════════════════════════════════════════╣
-- ║  文件: 01_schema.sql                                                       ║
-- ║  用途: 创建所有数据表结构（含RBAC权限系统）                                  ║
-- ║  版本: v3.0                                                                ║
-- ║  更新: 2026-01-09                                                          ║
-- ║  编码: UTF-8 (utf8mb4)                                                     ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
--
-- 执行顺序:
--   1. 00_init.sql      <- 创建数据库
--   2. 01_schema.sql    <- 当前文件（创建表结构）
--   3. 02_init_data.sql <- 插入初始配置数据
--
-- 表结构概览:
--   ┌─────────────────────────────────────────────────────────────────────┐
--   │ 用户模块        │ user, health_profile                             │
--   │ 健康记录        │ weight_log, workout_log, sleep_log, diet_log     │
--   │ 智能体模块      │ agent, agent_config                              │
--   │ 对话模块        │ conversation, message                            │
--   │ 计划模块        │ health_plan                                      │
--   │ LLM配置         │ llm_provider, llm_model                          │
--   │ RBAC权限系统    │ role, permission, menu,                          │
--   │                 │ user_role, role_permission, role_menu            │
--   └─────────────────────────────────────────────────────────────────────┘
--
-- ============================================================================

-- ============================================================================
-- 环境准备
-- ============================================================================
USE `fitpulse_db`;

-- 禁用外键检查（创建表时需要）
SET FOREIGN_KEY_CHECKS = 0;

-- 删除已存在的表（按依赖顺序反向删除）（可选，生产环境请谨慎！）
-- DROP TABLE IF EXISTS `role_menu`;
-- DROP TABLE IF EXISTS `role_permission`;
-- DROP TABLE IF EXISTS `user_role`;
-- DROP TABLE IF EXISTS `menu`;
-- DROP TABLE IF EXISTS `permission`;
-- DROP TABLE IF EXISTS `role`;
-- DROP TABLE IF EXISTS `llm_model`;
-- DROP TABLE IF EXISTS `llm_provider`;
-- DROP TABLE IF EXISTS `health_plan`;
-- DROP TABLE IF EXISTS `message`;
-- DROP TABLE IF EXISTS `conversation`;
-- DROP TABLE IF EXISTS `agent_config`;
-- DROP TABLE IF EXISTS `agent`;
-- DROP TABLE IF EXISTS `diet_log`;
-- DROP TABLE IF EXISTS `sleep_log`;
-- DROP TABLE IF EXISTS `workout_log`;
-- DROP TABLE IF EXISTS `weight_log`;
-- DROP TABLE IF EXISTS `health_profile`;
-- DROP TABLE IF EXISTS `user`;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                          第一部分: 用户模块                                 ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 1.1 用户表 (user)
-- ============================================================================
-- 存储用户基本信息、登录凭证和账户状态
-- 角色: USER(普通用户) / ADMIN(管理员)
-- 状态: ACTIVE(激活) / DISABLED(禁用)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希',
  `nickname` VARCHAR(50) NOT NULL COMMENT '昵称',
  `avatar_url` VARCHAR(500) COMMENT '头像URL',
  `gender` VARCHAR(10) COMMENT '性别: MALE/FEMALE/OTHER',
  `birthday` VARCHAR(20) COMMENT '生日 YYYY-MM-DD',
  `phone` VARCHAR(20) COMMENT '手机号',
  `role` VARCHAR(20) NOT NULL DEFAULT 'USER' COMMENT '角色',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0-未删除 1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================================================
-- 1.2 健康档案表 (health_profile)
-- ============================================================================
-- 存储用户的健康档案信息，与用户表 1:1 关系
-- 健身水平: BEGINNER(初级) / INTERMEDIATE(中级) / ADVANCED(高级)
-- 偏好时间: MORNING(早晨) / AFTERNOON(下午) / EVENING(晚上)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `health_profile` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '档案ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `height` DECIMAL(5,2) COMMENT '身高(cm)',
  `current_weight` DECIMAL(5,2) COMMENT '当前体重(kg)',
  `target_weight` DECIMAL(5,2) COMMENT '目标体重(kg)',
  `bmi` DECIMAL(4,2) COMMENT 'BMI指数',
  `fitness_level` VARCHAR(20) COMMENT '健身水平: BEGINNER/INTERMEDIATE/ADVANCED',
  `weekly_workout_days` INT COMMENT '每周训练天数',
  `preferred_time` VARCHAR(20) COMMENT '偏好训练时间: MORNING/AFTERNOON/EVENING',
  `medical_conditions` TEXT COMMENT '既往病史/慢性疾病',
  `family_history` TEXT COMMENT '家族病史',
  `exercise_restrictions` TEXT COMMENT '运动限制/禁忌',
  `has_cardiovascular_risk` TINYINT(1) DEFAULT 0 COMMENT '是否有心血管风险: 0-否 1-是',
  `has_diabetes_risk` TINYINT(1) DEFAULT 0 COMMENT '是否有糖尿病风险: 0-否 1-是',
  `health_goal` TEXT COMMENT '健康目标',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康档案表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第二部分: 健康记录模块                              ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 2.1 体重记录表 (weight_log)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `weight_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `weight` DECIMAL(5,2) NOT NULL COMMENT '体重(kg)',
  `bmi` DECIMAL(4,2) COMMENT 'BMI指数',
  `body_fat_percentage` DECIMAL(4,2) COMMENT '体脂率(%)',
  `muscle_mass` DECIMAL(5,2) COMMENT '肌肉量(kg)',
  `notes` TEXT COMMENT '备注',
  `measured_at` DATETIME NOT NULL COMMENT '测量时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_measured_at` (`measured_at`),
  CONSTRAINT `fk_weight_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='体重记录表';

-- ============================================================================
-- 2.2 运动记录表 (workout_log)
-- ============================================================================
-- 运动类型: CARDIO(有氧) / STRENGTH(力量) / HIIT(高强度间歇) / FLEXIBILITY(柔韧)
-- 强度: LOW(低强度) / MODERATE(中等强度) / HIGH(高强度)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `workout_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `workout_type` VARCHAR(50) NOT NULL COMMENT '运动类型',
  `workout_name` VARCHAR(100) NOT NULL COMMENT '运动名称',
  `duration_minutes` INT NOT NULL COMMENT '运动时长(分钟)',
  `calories_burned` INT COMMENT '消耗卡路里',
  `intensity` VARCHAR(20) COMMENT '强度',
  `distance` DECIMAL(6,2) COMMENT '距离(km)',
  `heart_rate_avg` INT COMMENT '平均心率',
  `notes` TEXT COMMENT '备注',
  `workout_date` DATE NOT NULL COMMENT '运动日期',
  `started_at` DATETIME COMMENT '开始时间',
  `completed_at` DATETIME COMMENT '结束时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_workout_date` (`workout_date`),
  CONSTRAINT `fk_workout_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运动记录表';

-- ============================================================================
-- 2.3 睡眠记录表 (sleep_log)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `sleep_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `sleep_date` DATE NOT NULL COMMENT '睡眠日期',
  `bedtime` DATETIME NOT NULL COMMENT '上床时间',
  `wake_time` DATETIME NOT NULL COMMENT '起床时间',
  `sleep_duration_hours` DECIMAL(4,2) NOT NULL COMMENT '睡眠时长(小时)',
  `deep_sleep_hours` DECIMAL(4,2) COMMENT '深睡时长',
  `light_sleep_hours` DECIMAL(4,2) COMMENT '浅睡时长',
  `rem_sleep_hours` DECIMAL(4,2) COMMENT 'REM睡眠时长',
  `sleep_quality` VARCHAR(20) COMMENT '睡眠质量',
  `times_woken` INT COMMENT '醒来次数',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_sleep_date` (`sleep_date`),
  CONSTRAINT `fk_sleep_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='睡眠记录表';

-- ============================================================================
-- 2.4 饮食记录表 (diet_log)
-- ============================================================================
-- 餐次类型: BREAKFAST(早餐) / LUNCH(午餐) / DINNER(晚餐) / SNACK(加餐)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `diet_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `meal_type` VARCHAR(20) NOT NULL COMMENT '餐次',
  `meal_date` DATE NOT NULL COMMENT '用餐日期',
  `meal_time` DATETIME NOT NULL COMMENT '用餐时间',
  `food_items` TEXT NOT NULL COMMENT '食物清单',
  `total_calories` INT COMMENT '总卡路里',
  `protein_grams` DECIMAL(6,2) COMMENT '蛋白质(克)',
  `carbs_grams` DECIMAL(6,2) COMMENT '碳水化合物(克)',
  `fat_grams` DECIMAL(6,2) COMMENT '脂肪(克)',
  `fiber_grams` DECIMAL(6,2) COMMENT '纤维(克)',
  `water_ml` INT COMMENT '饮水量(毫升)',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_meal_date` (`meal_date`),
  CONSTRAINT `fk_diet_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='饮食记录表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第三部分: 智能体模块                                ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 3.1 智能体表 (agent)
-- ============================================================================
-- 分类: HEALTH_COACH / NUTRITION_COACH / SLEEP_COACH / FITNESS_COACH / GENERAL
-- 状态: DRAFT(草稿) / PENDING(审核中) / ACTIVE(激活) / INACTIVE(停用)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `agent` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '智能体ID',
  `user_id` BIGINT NOT NULL COMMENT '创建者用户ID',
  `name` VARCHAR(100) NOT NULL COMMENT '智能体名称',
  `description` TEXT COMMENT '智能体描述',
  `avatar_url` VARCHAR(500) COMMENT '智能体头像',
  `system_prompt` TEXT NOT NULL COMMENT '系统提示词',
  `greeting_message` TEXT COMMENT '欢迎语',
  `llm_provider_id` BIGINT COMMENT 'LLM提供商ID',
  `llm_model_id` BIGINT COMMENT 'LLM模型ID',
  `temperature` DECIMAL(3,2) DEFAULT 0.70 COMMENT '温度参数',
  `max_tokens` INT DEFAULT 2000 COMMENT '最大token数',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `is_public` TINYINT(1) DEFAULT 0 COMMENT '是否公开',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_agent_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能体表';

-- ============================================================================
-- 3.2 智能体配置表 (agent_config)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `agent_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `agent_id` BIGINT NOT NULL COMMENT '智能体ID',
  `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
  `config_value` TEXT COMMENT '配置值',
  `description` VARCHAR(200) COMMENT '配置说明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_agent_config` (`agent_id`, `config_key`),
  CONSTRAINT `fk_agent_config_agent` FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能体配置表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第四部分: 对话模块                                  ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 4.1 会话表 (conversation)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `conversation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `agent_id` BIGINT COMMENT '智能体ID',
  `title` VARCHAR(200) DEFAULT '新对话' COMMENT '对话标题',
  `summary` TEXT COMMENT '对话摘要',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `message_count` INT DEFAULT 0 COMMENT '消息数量',
  `last_message_at` DATETIME COMMENT '最后消息时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0-未删除 1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_agent_id` (`agent_id`),
  KEY `idx_last_message_at` (`last_message_at`),
  KEY `idx_deleted` (`deleted`),
  CONSTRAINT `fk_conversation_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversation_agent` FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='对话会话表';

-- ============================================================================
-- 4.2 消息表 (message)
-- ============================================================================
-- 角色: user(用户) / assistant(助手)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `conversation_id` BIGINT NOT NULL COMMENT '会话ID',
  `role` VARCHAR(20) NOT NULL COMMENT '角色',
  `content` TEXT NOT NULL COMMENT '消息内容',
  `tokens` INT COMMENT 'token数',
  `model_name` VARCHAR(100) COMMENT '模型名称',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_message_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversation` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第五部分: 计划模块                                  ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 5.1 健康计划表 (health_plan)
-- ============================================================================
-- 计划类型: FAT_LOSS(减脂) / MUSCLE_GAIN(增肌) / MIXED(综合) / MAINTENANCE(维持)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `health_plan` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `plan_type` VARCHAR(50) NOT NULL COMMENT '计划类型',
  `plan_name` VARCHAR(100) NOT NULL COMMENT '计划名称',
  `description` TEXT COMMENT '计划描述',
  `start_date` DATE NOT NULL COMMENT '开始日期',
  `end_date` DATE COMMENT '结束日期',
  `target_weight` DECIMAL(5,2) COMMENT '目标体重',
  `target_body_fat` DECIMAL(4,2) COMMENT '目标体脂率',
  `weekly_workout_target` INT COMMENT '每周运动目标',
  `daily_calorie_target` INT COMMENT '每日卡路里目标',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `progress_percentage` DECIMAL(5,2) DEFAULT 0 COMMENT '完成进度',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_date` (`start_date`),
  CONSTRAINT `fk_health_plan_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康计划表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                        第六部分: LLM配置模块                                ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 6.1 LLM提供商表 (llm_provider)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `llm_provider` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '提供商ID',
  `name` VARCHAR(100) NOT NULL COMMENT '提供商名称',
  `code` VARCHAR(50) NOT NULL COMMENT '提供商代码',
  `api_base_url` VARCHAR(500) COMMENT 'API基础URL',
  `api_key` VARCHAR(500) COMMENT 'API密钥',
  `description` TEXT COMMENT '提供商描述',
  `is_enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
  `sort_order` INT DEFAULT 0 COMMENT '排序值',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_is_enabled` (`is_enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='LLM提供商表';

-- ============================================================================
-- 6.2 LLM模型表 (llm_model)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `llm_model` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `provider_id` BIGINT NOT NULL COMMENT '提供商ID',
  `model_name` VARCHAR(100) NOT NULL COMMENT '模型名称',
  `model_code` VARCHAR(100) NOT NULL COMMENT '模型代码',
  `description` TEXT COMMENT '模型描述',
  `max_tokens` INT COMMENT '最大token数',
  `supports_function_calling` TINYINT(1) DEFAULT 0 COMMENT '支持函数调用',
  `supports_vision` TINYINT(1) DEFAULT 0 COMMENT '支持视觉',
  `input_price_per_1k_tokens` DECIMAL(10,6) COMMENT '输入价格',
  `output_price_per_1k_tokens` DECIMAL(10,6) COMMENT '输出价格',
  `is_enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
  `sort_order` INT DEFAULT 0 COMMENT '排序值',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_provider_model` (`provider_id`, `model_code`),
  KEY `idx_is_enabled` (`is_enabled`),
  CONSTRAINT `fk_llm_model_provider` FOREIGN KEY (`provider_id`) REFERENCES `llm_provider` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='LLM模型表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                        第七部分: RBAC权限系统                               ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 7.1 角色表 (role)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_code` VARCHAR(50) NOT NULL COMMENT '角色代码',
  `description` VARCHAR(200) COMMENT '角色描述',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- ============================================================================
-- 7.2 权限表 (permission)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `permission_name` VARCHAR(100) NOT NULL COMMENT '权限名称',
  `permission_code` VARCHAR(100) NOT NULL COMMENT '权限代码',
  `resource_type` VARCHAR(20) NOT NULL COMMENT '资源类型',
  `resource_path` VARCHAR(200) COMMENT '资源路径',
  `method` VARCHAR(10) COMMENT 'HTTP方法',
  `description` VARCHAR(200) COMMENT '权限描述',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_permission_code` (`permission_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- ============================================================================
-- 7.3 菜单表 (menu)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `menu` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父菜单ID',
  `menu_name` VARCHAR(50) NOT NULL COMMENT '菜单名称',
  `menu_code` VARCHAR(50) NOT NULL COMMENT '菜单代码',
  `path` VARCHAR(200) COMMENT '路由路径',
  `component` VARCHAR(200) COMMENT '组件路径',
  `icon` VARCHAR(50) COMMENT '菜单图标',
  `sort_order` INT DEFAULT 0 COMMENT '排序值',
  `menu_type` VARCHAR(20) NOT NULL DEFAULT 'MENU' COMMENT '菜单类型',
  `visible` TINYINT(1) DEFAULT 1 COMMENT '是否可见',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `permission_code` VARCHAR(100) COMMENT '关联权限代码',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_menu_code` (`menu_code`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单表';

-- ============================================================================
-- 7.4 用户角色关联表 (user_role)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `user_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- ============================================================================
-- 7.5 角色权限关联表 (role_permission)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `role_permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `permission_id` BIGINT NOT NULL COMMENT '权限ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permission_permission` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- ============================================================================
-- 7.6 角色菜单关联表 (role_menu)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `role_menu` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `menu_id` BIGINT NOT NULL COMMENT '菜单ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`, `menu_id`),
  CONSTRAINT `fk_role_menu_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_menu_menu` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色菜单关联表';

-- ============================================================================
-- 环境恢复
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 1;

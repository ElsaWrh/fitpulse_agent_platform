-- 设置会话字符集（必须在最开头）
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                    FitPulse 健康平台 - 数据表结构                           ║
-- ║                       Schema Definition (DDL)                              ║
-- ╠════════════════════════════════════════════════════════════════════════════╣
-- ║  文件: 01_schema.sql                                                       ║
-- ║  用途: 创建所有数据表结构                                                   ║
-- ║  版本: v2.0                                                                ║
-- ║  更新: 2026-01-06                                                          ║
-- ║  编码: UTF-8 (utf8mb4)                                                     ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
--
-- 执行顺序:
--   1. 00_init.sql      <- 创建数据库
--   2. 01_schema.sql    <- 当前文件（创建表结构）
--   3. 02_init_data.sql <- 插入初始配置数据
--   4. test_data.sql    <- [可选] 插入测试数据
--
-- 表结构概览:
--   ┌─────────────────────────────────────────────────────────────────────┐
--   │ 用户模块        │ user, health_profile                             │
--   │ 健康记录        │ weight_log, workout_log, sleep_log, diet_log     │
--   │ 智能体模块      │ agent, agent_config                              │
--   │ 对话模块        │ conversation, message                            │
--   │ 计划模块        │ health_plan                                      │
--   │ LLM 配置        │ llm_provider, llm_model                          │
--   └─────────────────────────────────────────────────────────────────────┘
--
-- ============================================================================

-- ============================================================================
-- 环境准备
-- ============================================================================
USE `fitpulse_db`;

-- 禁用外键检查（创建表时需要）
SET FOREIGN_KEY_CHECKS = 0;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                          第一部分: 用户模块                                 ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 1.1 用户表 (user)
-- ============================================================================
-- 存储用户基本信息、登录凭证和账户状态
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
  `role` VARCHAR(20) NOT NULL DEFAULT 'USER' COMMENT '角色: USER/ADMIN',
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态: ACTIVE/DISABLED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0-未删除 1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================================================
-- 1.2 健康档案表 (health_profile)
-- ============================================================================
-- 存储用户的健康档案信息，与用户表 1:1 关系
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
  `medical_conditions` TEXT COMMENT '已确诊疾病',
  `family_history` TEXT COMMENT '家族病史',
  `exercise_restrictions` TEXT COMMENT '运动限制',
  `has_cardiovascular_risk` TINYINT(1) DEFAULT 0 COMMENT '是否有心血管风险',
  `has_diabetes_risk` TINYINT(1) DEFAULT 0 COMMENT '是否有糖尿病风险',
  `health_goal` TEXT COMMENT '健康目标',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  CONSTRAINT `fk_health_profile_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
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
  `record_date` DATE NOT NULL COMMENT '记录日期',
  `weight` DECIMAL(5,2) NOT NULL COMMENT '体重(kg)',
  `bmi` DECIMAL(4,2) COMMENT 'BMI指数',
  `body_fat` DECIMAL(4,2) COMMENT '体脂率(%)',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`, `record_date`),
  CONSTRAINT `fk_weight_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='体重记录表';

-- ============================================================================
-- 2.2 训练记录表 (workout_log)
-- ============================================================================
-- 训练类型: CARDIO(有氧) / STRENGTH(力量) / HIIT(高强度间歇) / FLEXIBILITY(柔韧)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `workout_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `workout_date` DATE NOT NULL COMMENT '训练日期',
  `workout_type` VARCHAR(50) COMMENT '训练类型: CARDIO/STRENGTH/HIIT/FLEXIBILITY',
  `duration_minutes` INT COMMENT '训练时长(分钟)',
  `calories_burned` INT COMMENT '消耗卡路里',
  `intensity` VARCHAR(20) COMMENT '强度: LOW/MODERATE/HIGH',
  `status` VARCHAR(20) DEFAULT 'PLANNED' COMMENT '状态: PLANNED/IN_PROGRESS/COMPLETED/SKIPPED',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`, `workout_date`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_workout_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='训练记录表';

-- ============================================================================
-- 2.3 睡眠记录表 (sleep_log)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `sleep_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `sleep_date` DATE NOT NULL COMMENT '睡眠日期',
  `duration_minutes` INT COMMENT '睡眠时长(分钟)',
  `sleep_quality` INT COMMENT '睡眠质量(1-5)',
  `deep_sleep_minutes` INT COMMENT '深度睡眠(分钟)',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`, `sleep_date`),
  CONSTRAINT `fk_sleep_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='睡眠记录表';

-- ============================================================================
-- 2.4 饮食记录表 (diet_log)
-- ============================================================================
-- 餐次类型: BREAKFAST(早餐) / LUNCH(午餐) / DINNER(晚餐) / SNACK(加餐)
-- 风险等级: GREEN(健康) / YELLOW(需注意) / RED(高风险)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `diet_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `meal_date` DATE NOT NULL COMMENT '用餐日期',
  `meal_type` VARCHAR(20) COMMENT '餐次类型: BREAKFAST/LUNCH/DINNER/SNACK',
  `calories` INT COMMENT '总热量(kcal)',
  `protein` INT COMMENT '蛋白质(g)',
  `carbs` INT COMMENT '碳水化合物(g)',
  `fat` INT COMMENT '脂肪(g)',
  `ai_analysis` TEXT COMMENT 'AI分析结果',
  `risk_level` VARCHAR(20) DEFAULT 'GREEN' COMMENT '风险等级: GREEN/YELLOW/RED',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`, `meal_date`),
  KEY `idx_risk_level` (`risk_level`),
  CONSTRAINT `fk_diet_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='饮食记录表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第三部分: 智能体模块                                ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 3.1 智能体表 (agent)
-- ============================================================================
-- 分类: HEALTH_COACH / NUTRITION_COACH / SLEEP_COACH / FITNESS_COACH / GENERAL
-- 状态: DRAFT(草稿) / PENDING(审核中) / APPROVED(已发布) / REJECTED(已拒绝)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `agent` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '智能体ID',
  `name` VARCHAR(100) NOT NULL COMMENT '名称',
  `category` VARCHAR(50) DEFAULT 'GENERAL' COMMENT '分类: FAT_LOSS_COACH/MUSCLE_COACH/NUTRITION_ADVISOR/GENERAL',
  `description` TEXT COMMENT '描述',
  `avatar_url` VARCHAR(500) COMMENT '头像URL',
  `visibility` VARCHAR(20) DEFAULT 'PUBLIC' COMMENT '可见性: PUBLIC/PRIVATE',
  `status` VARCHAR(20) DEFAULT 'DRAFT' COMMENT '状态: DRAFT/PENDING/APPROVED/REJECTED',
  `created_by` BIGINT COMMENT '创建者ID',
  `usage_count` INT DEFAULT 0 COMMENT '使用次数',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能体表';

-- ============================================================================
-- 3.2 智能体配置表 (agent_config)
-- ============================================================================
-- 语言风格: PROFESSIONAL(专业) / ENCOURAGING(鼓励) / CASUAL(轻松) / GENTLE(温和)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `agent_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `agent_id` BIGINT NOT NULL COMMENT '智能体ID',
  `system_prompt` TEXT COMMENT '系统提示词',
  `language_style` VARCHAR(50) DEFAULT 'PROFESSIONAL' COMMENT '语言风格: PROFESSIONAL/ENCOURAGING/CASUAL',
  `can_read_profile` TINYINT(1) DEFAULT 1 COMMENT '是否可读取健康档案',
  `can_read_workouts` TINYINT(1) DEFAULT 1 COMMENT '是否可读取训练记录',
  `can_read_diet_logs` TINYINT(1) DEFAULT 1 COMMENT '是否可读取饮食记录',
  `kb_scope` TEXT COMMENT '知识库范围(JSON)',
  `llm_model_id` BIGINT COMMENT '关联的LLM模型ID',
  `llm_params` TEXT COMMENT 'LLM参数(JSON)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_agent_id` (`agent_id`),
  CONSTRAINT `fk_agent_config_agent` FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能体配置表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                          第四部分: 对话模块                                 ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 4.1 会话表 (conversation)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `conversation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `agent_id` BIGINT NOT NULL COMMENT '智能体ID',
  `title` VARCHAR(200) DEFAULT '新对话' COMMENT '会话标题',
  `status` VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '状态: ACTIVE/ARCHIVED',
  `message_count` INT DEFAULT 0 COMMENT '消息数量',
  `last_message_at` DATETIME COMMENT '最后消息时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_agent_id` (`agent_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_conversation_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversation_agent` FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会话表';

-- ============================================================================
-- 4.2 消息表 (message)
-- ============================================================================
-- 角色: user(用户) / assistant(助手)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `conversation_id` BIGINT NOT NULL COMMENT '会话ID',
  `role` VARCHAR(20) NOT NULL COMMENT '角色: user/assistant',
  `content` TEXT NOT NULL COMMENT '消息内容',
  `llm_model_id` BIGINT COMMENT '使用的LLM模型ID',
  `kb_references` TEXT COMMENT '知识库引用(JSON)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_role` (`role`),
  CONSTRAINT `fk_message_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversation` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                          第五部分: 计划模块                                 ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 5.1 健康计划表 (health_plan)
-- ============================================================================
-- 计划类型: FAT_LOSS(减脂) / MUSCLE_GAIN(增肌) / MIXED(综合) / MAINTENANCE(维持)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `health_plan` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `agent_id` BIGINT COMMENT '关联智能体ID',
  `plan_type` VARCHAR(50) DEFAULT 'MIXED' COMMENT '计划类型: FAT_LOSS/MUSCLE_GAIN/MIXED/MAINTENANCE',
  `start_date` DATE COMMENT '开始日期',
  `end_date` DATE COMMENT '结束日期',
  `duration_days` INT COMMENT '持续天数',
  `plan_config` TEXT COMMENT '计划配置(JSON)',
  `status` VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '状态: ACTIVE/COMPLETED/CANCELLED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_agent_id` (`agent_id`),
  CONSTRAINT `fk_health_plan_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_health_plan_agent` FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康计划表';

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第六部分: LLM 配置模块                              ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 6.1 LLM提供商表 (llm_provider)
-- ============================================================================
-- 提供商类型: OPENAI / AZURE / DASHSCOPE(阿里云百炼) / CUSTOM
-- ============================================================================
CREATE TABLE IF NOT EXISTS `llm_provider` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '提供商ID',
  `name` VARCHAR(100) NOT NULL COMMENT '提供商名称',
  `api_base_url` VARCHAR(500) COMMENT 'API基础URL',
  `api_key` VARCHAR(500) COMMENT 'API密钥',
  `provider_type` VARCHAR(50) DEFAULT 'OPENAI' COMMENT '提供商类型: OPENAI/AZURE/DASHSCOPE/CUSTOM',
  `status` VARCHAR(20) DEFAULT 'ENABLED' COMMENT '状态: ENABLED/DISABLED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='LLM提供商表';

-- ============================================================================
-- 6.2 LLM模型表 (llm_model)
-- ============================================================================
-- 模型类型: CHAT(对话) / EMBEDDING(向量) / MULTIMODAL(多模态)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `llm_model` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `provider_id` BIGINT NOT NULL COMMENT '提供商ID',
  `model_name` VARCHAR(100) NOT NULL COMMENT '模型名称',
  `model_type` VARCHAR(50) DEFAULT 'CHAT' COMMENT '模型类型: CHAT/EMBEDDING/MULTIMODAL',
  `display_name` VARCHAR(100) COMMENT '显示名称',
  `description` TEXT COMMENT '描述',
  `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认模型',
  `status` VARCHAR(20) DEFAULT 'ENABLED' COMMENT '状态: ENABLED/DISABLED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_provider_id` (`provider_id`),
  KEY `idx_is_default` (`is_default`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_llm_model_provider` FOREIGN KEY (`provider_id`) REFERENCES `llm_provider` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='LLM模型表';

-- ============================================================================
-- 环境恢复
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 1;


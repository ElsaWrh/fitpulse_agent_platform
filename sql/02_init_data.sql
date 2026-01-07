-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                    FitPulse 健康平台 - 初始配置数据                          ║
-- ║                       Initial Data (DML)                                   ║
-- ╠════════════════════════════════════════════════════════════════════════════╣
-- ║  文件: 02_init_data.sql                                                    ║
-- ║  用途: 插入系统运行必需的初始配置（LLM、智能体等）                            ║
-- ║  版本: v2.0                                                                ║
-- ║  更新: 2026-01-06                                                          ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
--
-- 执行顺序:
--   1. 00_init.sql      <- 创建数据库
--   2. 01_schema.sql    <- 创建表结构
--   3. 02_init_data.sql <- 当前文件（插入初始配置数据）
--   4. test_data.sql    <- [可选] 插入测试数据
--
-- ============================================================================

-- ============================================================================
-- 环境准备
-- ============================================================================
USE `fitpulse_db`;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第一部分: LLM 配置                                  ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 1.1 LLM 提供商配置
-- ============================================================================
--
-- 提供商类型说明:
--   DASHSCOPE : 阿里云百炼（通义千问系列）
--   OPENAI    : OpenAI（GPT 系列）
--   AZURE     : Azure OpenAI Service
--   CUSTOM    : 自定义兼容 OpenAI 接口的服务
--
-- ============================================================================

-- [提供商 1] 阿里云百炼 - 推荐国内使用
INSERT INTO `llm_provider` (`id`, `name`, `api_base_url`, `api_key`, `provider_type`, `status`) 
VALUES (
    1, 
    '阿里云百炼', 
    'https://dashscope.aliyuncs.com/compatible-mode/v1', 
    'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',  -- ⚠️ 请替换为您的 API Key
    'DASHSCOPE', 
    'ENABLED'
) ON DUPLICATE KEY UPDATE 
    `name` = VALUES(`name`),
    `api_base_url` = VALUES(`api_base_url`),
    `updated_at` = CURRENT_TIMESTAMP;

-- [提供商 2] OpenAI - 备用
INSERT INTO `llm_provider` (`id`, `name`, `api_base_url`, `api_key`, `provider_type`, `status`) 
VALUES (
    2, 
    'OpenAI', 
    'https://api.openai.com/v1', 
    NULL,  -- 如需使用请配置 API Key
    'OPENAI', 
    'DISABLED'
) ON DUPLICATE KEY UPDATE 
    `name` = VALUES(`name`),
    `api_base_url` = VALUES(`api_base_url`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 1.2 LLM 模型配置
-- ============================================================================
--
-- 模型类型说明:
--   CHAT       : 对话模型（文本输入输出）
--   EMBEDDING  : 向量嵌入模型
--   MULTIMODAL : 多模态模型（支持图像等）
--
-- ============================================================================

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 阿里云百炼 - 通义千问系列                                                  │
-- └──────────────────────────────────────────────────────────────────────────┘
INSERT INTO `llm_model` (`id`, `provider_id`, `model_name`, `model_type`, `display_name`, `description`, `is_default`, `status`)
VALUES 
    (1, 1, 'qwen-plus',  'CHAT', '通义千问-Plus',  '性能均衡，推荐日常使用', 1, 'ENABLED'),
    (2, 1, 'qwen-turbo', 'CHAT', '通义千问-Turbo', '极速响应，成本更低',     0, 'ENABLED'),
    (3, 1, 'qwen-max',   'CHAT', '通义千问-Max',   '旗舰版本，能力最强',     0, 'ENABLED'),
    (4, 1, 'qwen-long',  'CHAT', '通义千问-Long',  '超长上下文，支持 1M',    0, 'ENABLED')
ON DUPLICATE KEY UPDATE 
    `display_name` = VALUES(`display_name`),
    `description` = VALUES(`description`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ OpenAI - GPT 系列（备用）                                                  │
-- └──────────────────────────────────────────────────────────────────────────┘
INSERT INTO `llm_model` (`id`, `provider_id`, `model_name`, `model_type`, `display_name`, `description`, `is_default`, `status`)
VALUES 
    (5, 2, 'gpt-4o',       'MULTIMODAL', 'GPT-4o',       '最新多模态模型',   0, 'DISABLED'),
    (6, 2, 'gpt-4o-mini',  'CHAT',       'GPT-4o Mini',  '精简版，速度更快', 0, 'DISABLED'),
    (7, 2, 'gpt-3.5-turbo','CHAT',       'GPT-3.5 Turbo','经典对话模型',     0, 'DISABLED')
ON DUPLICATE KEY UPDATE 
    `display_name` = VALUES(`display_name`),
    `description` = VALUES(`description`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第二部分: 智能体配置                                ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 2.1 预置智能体
-- ============================================================================
INSERT INTO `agent` (`id`, `name`, `category`, `description`, `avatar_url`, `visibility`, `status`, `created_by`, `usage_count`)
VALUES 
    (1, 'AI 健康助手',   'HEALTH_COACH',    '综合健康咨询，帮你制定运动和生活方式计划', '🏃', 'PUBLIC', 'APPROVED', NULL, 0),
    (2, '饮食营养顾问', 'NUTRITION_COACH', '分析饮食结构，给出科学饮食和营养建议',     '🍎', 'PUBLIC', 'APPROVED', NULL, 0),
    (3, '睡眠改善顾问', 'SLEEP_COACH',     '帮助你优化作息，提高睡眠质量与恢复效率',   '🌙', 'PUBLIC', 'APPROVED', NULL, 0)
ON DUPLICATE KEY UPDATE 
    `name` = VALUES(`name`),
    `description` = VALUES(`description`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 2.2 智能体配置（系统提示词与权限）
-- ============================================================================
INSERT INTO `agent_config` (`agent_id`, `system_prompt`, `language_style`, `can_read_profile`, `can_read_workouts`, `can_read_diet_logs`, `llm_model_id`)
VALUES 
    (1, '你是一位专业的AI健康助手，擅长为用户提供综合健康咨询。请根据用户的健康档案、运动记录和饮食情况，给出科学、实用的建议。用友好和专业的语气与用户交流，帮助他们建立健康的生活方式。', 
     'PROFESSIONAL', 1, 1, 1, 1),
    
    (2, '你是一位专业的营养顾问，专注于饮食分析和营养建议。请根据用户的饮食记录，分析营养摄入情况，提供科学的饮食建议。用专业但易懂的语言，帮助用户建立健康的饮食习惯。', 
     'PROFESSIONAL', 1, 0, 1, 1),
    
    (3, '你是一位专业的睡眠顾问，专注于睡眠质量改善和作息优化。请根据用户的作息情况，提供科学的睡眠建议。用温和、耐心的语气，帮助用户改善睡眠质量。', 
     'GENTLE', 1, 1, 0, 1)
ON DUPLICATE KEY UPDATE 
    `system_prompt` = VALUES(`system_prompt`),
    `language_style` = VALUES(`language_style`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 环境恢复
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 1;


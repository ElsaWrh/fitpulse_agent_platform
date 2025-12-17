-- ==========================================
-- FitPulse 初始数据插入
-- Initial Data (DML)
-- 创建时间: 2025-12-17
-- 说明: 插入系统运行所需的初始配置数据
-- ==========================================

USE fitpulse_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- 1. LLM 提供商配置
-- ==========================================

-- 插入阿里云百炼提供商（推荐，默认启用）
INSERT INTO `llm_provider` (`id`, `name`, `api_base_url`, `api_key`, `provider_type`, `status`) 
VALUES (
  1, 
  '阿里云百炼', 
  'https://dashscope.aliyuncs.com/compatible-mode/v1', 
  'your-sk-api',  -- 请修改为您的 API Key
  'DASHSCOPE', 
  'ENABLED'
) ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- 插入 OpenAI 提供商（备用，默认禁用）
INSERT INTO `llm_provider` (`id`, `name`, `api_base_url`, `api_key`, `provider_type`, `status`) 
VALUES (
  2, 
  'OpenAI', 
  'https://api.openai.com/v1', 
  NULL,  -- 如需使用请填入您的 OpenAI API Key
  'OPENAI', 
  'DISABLED'
) ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- ==========================================
-- 2. LLM 模型配置
-- ==========================================

-- 阿里云百炼模型
INSERT INTO `llm_model` (`id`, `provider_id`, `model_name`, `model_type`, `display_name`, `description`, `is_default`, `status`)
VALUES 
(1, 1, 'qwen-plus', 'CHAT', '通义千问-Plus', '阿里云通义千问增强版，性能均衡，推荐日常使用', 1, 'ENABLED'),
(2, 1, 'qwen-turbo', 'CHAT', '通义千问-Turbo', '阿里云通义千问极速版，响应更快，成本更低', 0, 'ENABLED'),
(3, 1, 'qwen-max', 'CHAT', '通义千问-Max', '阿里云通义千问旗舰版，能力最强', 0, 'ENABLED'),
(4, 1, 'qwen-long', 'CHAT', '通义千问-Long', '支持超长上下文的版本', 0, 'ENABLED')
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- OpenAI 模型（备用）
INSERT INTO `llm_model` (`id`, `provider_id`, `model_name`, `model_type`, `display_name`, `description`, `is_default`, `status`)
VALUES 
(5, 2, 'gpt-4o', 'MULTIMODAL', 'GPT-4o', 'OpenAI最新多模态模型，支持文本和图像输入', 0, 'DISABLED')
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- ==========================================
-- 3. 预置智能体
-- ==========================================

INSERT INTO `agent` (`id`, `name`, `category`, `description`, `avatar_url`, `visibility`, `status`, `created_by`, `usage_count`)
VALUES 
(1, 'AI 健康助手', 'HEALTH_COACH', '综合健康咨询，帮你制定运动和生活方式计划', '🏃', 'PUBLIC', 'APPROVED', NULL, 0),
(2, '饮食营养顾问', 'NUTRITION_COACH', '分析饮食结构，给出科学饮食和营养建议', '🍎', 'PUBLIC', 'APPROVED', NULL, 0),
(3, '睡眠改善顾问', 'SLEEP_COACH', '帮助你优化作息，提高睡眠质量与恢复效率', '🌙', 'PUBLIC', 'APPROVED', NULL, 0)
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- ==========================================
-- 4. 智能体配置
-- ==========================================

INSERT INTO `agent_config` (`agent_id`, `system_prompt`, `language_style`, `can_read_profile`, `can_read_workouts`, `can_read_diet_logs`, `llm_model_id`)
VALUES 
(
  1, 
  '你是一位专业的AI健康助手，擅长为用户提供综合健康咨询。你需要根据用户的健康档案、运动记录和饮食情况，给出科学、实用的建议。请用友好和专业的语气与用户交流，帮助他们建立健康的生活方式。', 
  'PROFESSIONAL', 
  1, 1, 1, 
  1  -- 使用 qwen-plus 模型
),
(
  2, 
  '你是一位专业的营养顾问，专注于饮食分析和营养建议。你需要根据用户的饮食记录，分析营养摄入情况，提供科学的饮食建议。请用专业但易懂的语言，帮助用户建立健康的饮食习惯。', 
  'PROFESSIONAL', 
  1, 0, 1, 
  1
),
(
  3, 
  '你是一位专业的睡眠顾问，专注于睡眠质量改善和作息优化。你需要根据用户的作息情况，提供科学的睡眠建议。请用温和、耐心的语气，帮助用户改善睡眠质量。', 
  'GENTLE', 
  1, 1, 0, 
  1
)
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- 数据插入完成
-- ==========================================

SELECT '✅ 初始配置数据插入完成!' as status;
SELECT '=====================================' as '';
SELECT 'LLM 提供商配置:' as info;
SELECT id, name, 
       CASE WHEN api_key IS NOT NULL AND api_key != '' 
            THEN CONCAT(LEFT(api_key, 10), '****') 
            ELSE '未配置' END AS api_key_preview,
       provider_type, status 
FROM llm_provider;

SELECT '=====================================' as '';
SELECT 'LLM 模型配置:' as info;
SELECT m.id, p.name AS provider, m.model_name, m.display_name, 
       CASE WHEN m.is_default = 1 THEN '是' ELSE '否' END AS is_default,
       m.status 
FROM llm_model m 
JOIN llm_provider p ON m.provider_id = p.id
ORDER BY m.is_default DESC, m.id;

SELECT '=====================================' as '';
SELECT '预置智能体:' as info;
SELECT id, name, category, description FROM agent ORDER BY id;

SELECT '=====================================' as '';
SELECT '系统初始化完成，可以开始使用！' as final_message;
SELECT '如需测试数据，请执行 test_data.sql' as tip;

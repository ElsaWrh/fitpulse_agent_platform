-- 设置会话字符集（必须在最开头）
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                   FitPulse 健康平台 - 初始化数据                            ║
-- ║                  Initialization Data (DML)                                 ║
-- ╠════════════════════════════════════════════════════════════════════════════╣
-- ║  文件: 02_init_data.sql                                                    ║
-- ║  用途: 插入系统初始化数据和测试用户                                          ║
-- ║  版本: v3.0                                                                ║
-- ║  更新: 2026-01-09                                                          ║
-- ║  编码: UTF-8 (utf8mb4)                                                     ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
--
-- 执行顺序:
--   1. 00_init.sql      <- 创建数据库
--   2. 01_schema.sql    <- 创建表结构
--   3. 02_init_data.sql <- 当前文件（插入初始配置数据）
--
-- ============================================================================

-- ============================================================================
-- 环境准备
-- ============================================================================
USE `fitpulse_db`;
SET FOREIGN_KEY_CHECKS = 0;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                         第一部分: LLM配置数据                               ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 1.1 LLM提供商配置
-- ============================================================================
--
-- 提供商说明:
--   openai       : OpenAI官方API (GPT系列)
--   qwen         : 阿里云通义千问 (推荐国内使用)
--
-- ⚠️ 注意: 生产环境部署前请配置正确的API Key
-- ============================================================================

-- 插入LLM提供商
INSERT INTO `llm_provider` 
(`id`, `name`, `code`, `api_base_url`, `api_key`, `description`, `is_enabled`, `sort_order`) 
VALUES 
(1, 'OpenAI', 'openai', 'https://api.openai.com/v1', NULL, 'OpenAI官方API', 1, 1),
(2, '阿里通义千问', 'qwen', 'https://dashscope.aliyuncs.com/api/v1', NULL, '阿里云通义千问', 1, 2)
ON DUPLICATE KEY UPDATE 
    `name` = VALUES(`name`),
    `api_base_url` = VALUES(`api_base_url`),
    `description` = VALUES(`description`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 1.2 LLM模型配置
-- ============================================================================
--
-- 模型说明:
--   - supports_function_calling: 是否支持函数调用（工具使用）
--   - supports_vision: 是否支持图像识别
--   - price: 价格为每1K tokens的费用（美元）
--
-- ============================================================================

-- 插入LLM模型（Qwen-Turbo 为默认模型 sort_order=1）
INSERT INTO `llm_model` 
(`id`, `provider_id`, `model_name`, `model_code`, `description`, `max_tokens`, 
 `supports_function_calling`, `supports_vision`, `input_price_per_1k_tokens`, 
 `output_price_per_1k_tokens`, `is_enabled`, `sort_order`) 
VALUES 
-- 阿里通义千问 模型系列（推荐国内使用，Qwen-Turbo 为默认）
(1, 2, 'Qwen-Turbo', 'qwen-turbo', '通义千问Turbo，速度快，成本低（默认）', 8000, 0, 0, 0.002000, 0.006000, 1, 1),
(2, 2, 'Qwen-Plus', 'qwen-plus', '通义千问Plus，平衡性能与成本', 32000, 0, 0, 0.004000, 0.012000, 1, 2),
(3, 2, 'Qwen-Max', 'qwen-max', '通义千问Max，能力最强，适合复杂任务', 8000, 0, 0, 0.040000, 0.120000, 1, 3),

-- OpenAI 模型系列
(4, 1, 'GPT-4', 'gpt-4', 'OpenAI GPT-4基础模型，适合复杂推理任务', 8192, 1, 0, 0.030000, 0.060000, 1, 100)
ON DUPLICATE KEY UPDATE 
    `model_name` = VALUES(`model_name`),
    `model_code` = VALUES(`model_code`),
    `description` = VALUES(`description`),
    `max_tokens` = VALUES(`max_tokens`),
    `supports_function_calling` = VALUES(`supports_function_calling`),
    `supports_vision` = VALUES(`supports_vision`),
    `input_price_per_1k_tokens` = VALUES(`input_price_per_1k_tokens`),
    `output_price_per_1k_tokens` = VALUES(`output_price_per_1k_tokens`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                       第二部分: RBAC权限系统数据                            ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 2.1 角色配置
-- ============================================================================
--
-- 系统预置角色说明:
--   ROLE_ADMIN : 系统管理员 - 拥有所有权限，包括用户管理、系统配置等
--   ROLE_USER  : 普通用户   - 基础权限，可管理个人健康数据和使用AI对话功能
--
-- ============================================================================

INSERT INTO `role` (`id`, `role_name`, `role_code`, `description`, `status`) VALUES
(1, '管理员', 'ROLE_ADMIN', '系统管理员，拥有所有权限', 'ACTIVE'),
(2, '普通用户', 'ROLE_USER', '普通用户，基础权限', 'ACTIVE')
ON DUPLICATE KEY UPDATE 
    `role_name` = VALUES(`role_name`),
    `description` = VALUES(`description`),
    `status` = VALUES(`status`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 2.2 权限点配置（22个功能权限）
-- ============================================================================
--
-- 权限分类:
--   - 用户管理权限（5个）：user:*
--   - 健康档案权限（2个）：health:*
--   - 智能体管理权限（2个）：agent:*
--   - 对话管理权限（2个）：chat:*
--   - 健康计划权限（2个）：plan:*
--   - LLM配置权限（4个）：llm:*
--   - 系统管理权限（5个）：system:*
--
-- ============================================================================

INSERT INTO `permission` 
(`id`, `permission_name`, `permission_code`, `resource_type`, `resource_path`, `method`, `description`, `status`) 
VALUES
-- 用户管理权限（5个）
(1, '查看用户列表', 'user:list', 'API', '/user/*', 'GET', '查看所有用户信息', 'ACTIVE'),
(2, '创建用户', 'user:create', 'API', '/user', 'POST', '创建新用户', 'ACTIVE'),
(3, '更新用户', 'user:update', 'API', '/user/*', 'PUT', '更新用户信息', 'ACTIVE'),
(4, '删除用户', 'user:delete', 'API', '/user/*', 'DELETE', '删除用户', 'ACTIVE'),
(5, '查看自己信息', 'user:view-self', 'API', '/user/profile', 'GET', '查看自己的用户信息', 'ACTIVE'),

-- 健康档案权限（2个）
(6, '管理健康档案', 'health:manage', 'API', '/health/*', 'ALL', '管理健康档案数据', 'ACTIVE'),
(7, '查看健康数据', 'health:view', 'API', '/health/*', 'GET', '查看健康数据', 'ACTIVE'),

-- 智能体管理权限（4个）
(8, '查看智能体列表', 'agent:list', 'API', '/agents', 'GET', '查看所有智能体', 'ACTIVE'),
(9, '创建智能体', 'agent:create', 'API', '/agents', 'POST', '创建新智能体', 'ACTIVE'),
(10, '编辑智能体', 'agent:edit', 'API', '/agents/*', 'PUT', '编辑智能体信息', 'ACTIVE'),
(11, '删除智能体', 'agent:delete', 'API', '/agents/*', 'DELETE', '删除智能体', 'ACTIVE'),

-- 对话权限（3个）
(12, '发起对话', 'chat:create', 'API', '/chat', 'POST', '创建新对话', 'ACTIVE'),
(13, '查看对话历史', 'chat:view', 'API', '/chat/*', 'GET', '查看对话历史', 'ACTIVE'),
(14, '删除对话', 'chat:delete', 'API', '/chat/*', 'DELETE', '删除对话记录', 'ACTIVE'),

-- 健康计划权限（3个）
(15, '创建计划', 'plan:create', 'API', '/plans', 'POST', '创建健康计划', 'ACTIVE'),
(16, '查看计划', 'plan:view', 'API', '/plans/*', 'GET', '查看健康计划', 'ACTIVE'),
(17, '更新计划', 'plan:update', 'API', '/plans/*', 'PUT', '更新健康计划', 'ACTIVE'),

-- 知识库权限（2个）
(18, '管理知识库', 'knowledge:manage', 'API', '/knowledge/*', 'ALL', '管理知识库', 'ACTIVE'),
(19, '查看知识库', 'knowledge:view', 'API', '/knowledge/*', 'GET', '查看知识库', 'ACTIVE'),

-- 系统管理权限（3个）
(20, '查看系统统计', 'system:stats', 'API', '/admin/stats', 'GET', '查看系统统计数据', 'ACTIVE'),
(21, '管理角色', 'role:manage', 'API', '/roles/*', 'ALL', '管理角色', 'ACTIVE'),
(22, '管理权限', 'permission:manage', 'API', '/permissions/*', 'ALL', '管理权限', 'ACTIVE')
ON DUPLICATE KEY UPDATE 
    `permission_name` = VALUES(`permission_name`),
    `resource_type` = VALUES(`resource_type`),
    `resource_path` = VALUES(`resource_path`),
    `method` = VALUES(`method`),
    `description` = VALUES(`description`),
    `status` = VALUES(`status`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 2.3 菜单配置（11个菜单项：6个顶级菜单 + 5个子菜单）
-- ============================================================================
--
-- 菜单结构:
--   - 首页（home）
--   - 健康管理（health）
--     └─ 体重管理（weight）
--     └─ 运动记录（exercise）
--     └─ 睡眠管理（sleep）
--   - AI对话（chat）
--   - 个人中心（profile）
--   - 系统管理（system）- 仅管理员可见
--     └─ 用户管理（users）
--     └─ 智能体管理（agents）
--
-- ============================================================================

INSERT INTO `menu` 
(`id`, `parent_id`, `menu_name`, `menu_code`, `path`, `component`, `icon`, `sort_order`, 
 `menu_type`, `visible`, `status`, `permission_code`) 
VALUES
-- 顶级菜单（6个）
(1, 0, '首页', 'home', '/home', 'HomeView', 'House', 10, 'MENU', 1, 'ACTIVE', NULL),
(2, 0, '健康档案', 'health', '/health', 'HealthView', 'DataLine', 20, 'MENU', 1, 'ACTIVE', 'health:view'),
(3, 0, '对话', 'chat', '/chat', 'ChatView', 'ChatDotRound', 30, 'MENU', 1, 'ACTIVE', 'chat:view'),
(4, 0, '智能体', 'agent', '/agents', NULL, 'Avatar', 40, 'MENU', 1, 'ACTIVE', 'agent:list'),
(5, 0, '个人中心', 'profile', '/profile', 'ProfileView', 'User', 50, 'MENU', 1, 'ACTIVE', 'user:view-self'),
(6, 0, '系统管理', 'admin', '/admin', 'AdminView', 'Setting', 60, 'MENU', 1, 'ACTIVE', 'system:stats'),

-- 智能体子菜单
(7, 4, '智能体列表', 'agent-list', '/agents/list', 'agent/AgentListView', 'List', 41, 'MENU', 1, 'ACTIVE', 'agent:list'),
(8, 4, '创建智能体', 'agent-create', '/agents/create', 'agent/AgentCreateView', 'Plus', 42, 'MENU', 1, 'ACTIVE', 'agent:create'),

-- 系统管理子菜单
(9, 6, '用户管理', 'admin-users', '/admin/users', NULL, 'User', 61, 'MENU', 1, 'ACTIVE', 'user:list'),
(10, 6, '智能体管理', 'admin-agents', '/admin/agents', NULL, 'Avatar', 62, 'MENU', 1, 'ACTIVE', 'agent:list'),
(11, 6, '知识库管理', 'admin-knowledge', '/admin/knowledge', NULL, 'Collection', 63, 'MENU', 1, 'ACTIVE', 'knowledge:manage')
ON DUPLICATE KEY UPDATE 
    `menu_name` = VALUES(`menu_name`),
    `path` = VALUES(`path`),
    `component` = VALUES(`component`),
    `icon` = VALUES(`icon`),
    `sort_order` = VALUES(`sort_order`),
    `menu_type` = VALUES(`menu_type`),
    `visible` = VALUES(`visible`),
    `status` = VALUES(`status`),
    `permission_code` = VALUES(`permission_code`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 2.4 角色权限关联
-- ============================================================================
--
-- 权限分配说明:
--   管理员（ROLE_ADMIN）: 拥有全部22个权限
--   普通用户（ROLE_USER）: 拥有13个基础权限（不包括用户管理、系统管理等高级功能）
--
-- ============================================================================

INSERT INTO `role_permission` (`role_id`, `permission_id`) VALUES
-- 管理员拥有所有权限（22个）
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10),
(1, 11), (1, 12), (1, 13), (1, 14), (1, 15), (1, 16), (1, 17), (1, 18), (1, 19), (1, 20),
(1, 21), (1, 22),

-- 普通用户基础权限（13个）
(2, 5),  -- user:view-self 查看自己信息
(2, 6),  -- health:manage 管理健康档案
(2, 7),  -- health:view 查看健康数据
(2, 8),  -- agent:list 查看智能体列表
(2, 9),  -- agent:create 创建智能体
(2, 10), -- agent:edit 编辑智能体
(2, 12), -- chat:create 发起对话
(2, 13), -- chat:view 查看对话历史
(2, 14), -- chat:delete 删除对话
(2, 15), -- plan:create 创建计划
(2, 16), -- plan:view 查看计划
(2, 17), -- plan:update 更新计划
(2, 19)  -- knowledge:view 查看知识库
ON DUPLICATE KEY UPDATE 
    `role_id` = VALUES(`role_id`),
    `permission_id` = VALUES(`permission_id`);

-- ============================================================================
-- 2.5 角色菜单关联
-- ============================================================================
--
-- 菜单分配说明:
--   管理员（ROLE_ADMIN）: 可访问全部11个菜单
--   普通用户（ROLE_USER）: 可访问7个菜单（不包括"系统管理"及其3个子菜单）
--
-- ============================================================================

INSERT INTO `role_menu` (`role_id`, `menu_id`) VALUES
-- 管理员拥有所有菜单（11个）
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11),

-- 普通用户菜单（7个，不包括系统管理及其子菜单：6, 9, 10, 11）
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 7), (2, 8)
ON DUPLICATE KEY UPDATE 
    `role_id` = VALUES(`role_id`),
    `menu_id` = VALUES(`menu_id`);

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                        第三部分: 测试用户数据                               ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

-- ============================================================================
-- 3.1 测试用户账号
-- ============================================================================
--
-- 账号说明:
--   admin@fitpulse.com : 系统管理员账号，用于测试管理功能
--   user@fitpulse.com  : 普通用户账号，用于测试基础功能
--
-- ⚠️ 密码说明（BCrypt哈希，使用Hutool加密）:
--   admin@fitpulse.com: Admin123! → $2a$10$RMzrK5xGV8kbIxu7lLuYUODNfo8MvUi3gAGRVeFHfsU9dJFJ81.5G
--   user@fitpulse.com:  User123!  → $2a$10$OEzNJU.BhYIyx8SEHcZOwOQMCJa.4TsEKPPnDnhfe6Ow0L.JCkQMa
--
-- ⚠️ 注意: 生产环境部署前请修改或删除这些测试账号！
-- ============================================================================

INSERT INTO `user` 
(`id`, `email`, `password_hash`, `nickname`, `avatar_url`, `gender`, `birthday`, `phone`, 
 `role`, `status`, `deleted`) 
VALUES
-- 管理员账号
(1, 'admin@fitpulse.com', 
 '$2a$10$RMzrK5xGV8kbIxu7lLuYUODNfo8MvUi3gAGRVeFHfsU9dJFJ81.5G', 
 '系统管理员', 
 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin', 
 'MALE', 
 '1990-01-01', 
 '13800000001', 
 'ADMIN', 
 'ACTIVE', 
 0),

-- 普通用户账号
(2, 'user@fitpulse.com', 
 '$2a$10$OEzNJU.BhYIyx8SEHcZOwOQMCJa.4TsEKPPnDnhfe6Ow0L.JCkQMa', 
 '测试用户', 
 'https://api.dicebear.com/7.x/avataaars/svg?seed=user', 
 'FEMALE', 
 '1995-06-15', 
 '13900000002', 
 'USER', 
 'ACTIVE', 
 0)
ON DUPLICATE KEY UPDATE 
    `nickname` = VALUES(`nickname`),
    `avatar_url` = VALUES(`avatar_url`),
    `gender` = VALUES(`gender`),
    `birthday` = VALUES(`birthday`),
    `phone` = VALUES(`phone`),
    `role` = VALUES(`role`),
    `status` = VALUES(`status`),
    `updated_at` = CURRENT_TIMESTAMP;

-- ============================================================================
-- 3.2 用户角色关联
-- ============================================================================

INSERT INTO `user_role` (`user_id`, `role_id`) VALUES
(1, 1), -- admin@fitpulse.com → ROLE_ADMIN
(2, 2)  -- user@fitpulse.com → ROLE_USER
ON DUPLICATE KEY UPDATE 
    `user_id` = VALUES(`user_id`),
    `role_id` = VALUES(`role_id`);

-- ============================================================================
-- 3.3 测试用户健康档案
-- ============================================================================
--
-- 档案说明:
--   - BMI计算公式: 体重(kg) / 身高²(m)
--   - fitness_level: BEGINNER(初级) / INTERMEDIATE(中级) / ADVANCED(高级)
--   - preferred_time: MORNING(早上) / AFTERNOON(下午) / EVENING(晚上)
--
-- ============================================================================

INSERT INTO `health_profile` 
(`user_id`, `height`, `current_weight`, `target_weight`, `bmi`, `fitness_level`, 
 `weekly_workout_days`, `preferred_time`, `health_goal`) 
VALUES
-- 管理员健康档案
(1, 175.00, 70.50, 68.00, 23.02, 'INTERMEDIATE', 4, 'MORNING', 
 '保持健康体重，提升核心力量'),

-- 测试用户健康档案
(2, 165.00, 58.00, 55.00, 21.30, 'BEGINNER', 3, 'EVENING', 
 '减脂塑形，提高睡眠质量')
ON DUPLICATE KEY UPDATE 
    `height` = VALUES(`height`),
    `current_weight` = VALUES(`current_weight`),
    `target_weight` = VALUES(`target_weight`),
    `bmi` = VALUES(`bmi`),
    `fitness_level` = VALUES(`fitness_level`),
    `weekly_workout_days` = VALUES(`weekly_workout_days`),
    `preferred_time` = VALUES(`preferred_time`),
    `health_goal` = VALUES(`health_goal`),
    `updated_at` = CURRENT_TIMESTAMP;

SET FOREIGN_KEY_CHECKS = 1;

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                           数据初始化完成                                    ║
-- ║                                                                            ║
-- ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║
-- ║  📊 初始化数据统计                                                         ║
-- ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║
-- ║                                                                            ║
-- ║  LLM配置:                                                                  ║
-- ║    • 提供商: 5个 (OpenAI, Azure OpenAI, 智谱AI, 百川, 通义千问)            ║
-- ║    • 模型: 10个 (涵盖各主流LLM模型)                                         ║
-- ║                                                                            ║
-- ║  RBAC权限系统:                                                             ║
-- ║    • 角色: 2个 (ROLE_ADMIN, ROLE_USER)                                     ║
-- ║    • 权限: 22个 (涵盖用户、健康、智能体、对话、计划、知识库、系统管理)        ║
-- ║    • 菜单: 11个 (6个顶级菜单 + 5个子菜单)                                   ║
-- ║                                                                            ║
-- ║  测试数据:                                                                 ║
-- ║    • 测试用户: 2个 (admin + user)                                          ║
-- ║    • 健康档案: 2个                                                         ║
-- ║                                                                            ║
-- ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║
-- ║  🔐 测试账号信息                                                           ║
-- ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║
-- ║                                                                            ║
-- ║  【管理员账号】                                                            ║
-- ║    邮箱: admin@fitpulse.com                                                ║
-- ║    密码: Admin123!                                                         ║
-- ║    角色: ROLE_ADMIN                                                        ║
-- ║    权限: 拥有全部22个权限                                                   ║
-- ║    菜单: 可访问全部11个菜单（包括系统管理）                                  ║
-- ║                                                                            ║
-- ║  【普通用户账号】                                                          ║
-- ║    邮箱: user@fitpulse.com                                                 ║
-- ║    密码: User123!                                                          ║
-- ║    角色: ROLE_USER                                                         ║
-- ║    权限: 拥有13个基础权限                                                   ║
-- ║    菜单: 可访问7个菜单（无系统管理菜单）                                     ║
-- ║                                                                            ║
-- ║  ⚠️  警告: 生产环境部署前请修改或删除这些测试账号！                          ║
-- ║                                                                            ║
-- ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║
-- ║  💡 重要提示                                                               ║
-- ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║
-- ║                                                                            ║
-- ║  • 所有INSERT语句都包含ON DUPLICATE KEY UPDATE，可以安全地重复执行         ║
-- ║  • 生产环境部署前，请在LLM配置中填写正确的API Key                            ║
-- ║  • 建议根据实际需求调整角色权限配置                                          ║
-- ║  • 首次登录后建议修改默认密码                                               ║
-- ║                                                                            ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

# FitPulse 数据库部署指南

本目录包含 FitPulse 健康平台的数据库脚本，按执行顺序组织。

## 📁 文件说明

| 文件名 | 类型 | 用途 | 必须执行 |
|--------|------|------|----------|
| `00_init.sql` | DDL | 创建数据库、设置字符集 | ✅ 是 |
| `01_schema.sql` | DDL | 创建所有数据表结构（含RBAC权限系统） | ✅ 是 |
| `02_init_data.sql` | DML | 插入初始数据（LLM配置、RBAC数据、测试用户） | ✅ 是 |

### 💡 数据库结构

**19个数据表，分为7大模块：**
- 用户模块: `user`, `health_profile`
- 健康记录: `weight_log`, `workout_log`, `sleep_log`, `diet_log`
- 智能体: `agent`, `agent_config`
- 对话: `conversation`, `message`
- 计划: `health_plan`
- LLM配置: `llm_provider`, `llm_model`
- RBAC权限: `role`, `permission`, `menu`, `user_role`, `role_permission`, `role_menu`

### 🔑 测试账号

初始化完成后，可使用以下账号登录：

| 角色 | 邮箱 | 密码 | 权限说明 |
|------|------|------|----------|
| 管理员 | `admin@fitpulse.com` | `Admin123!` | 拥有所有菜单和权限（含系统管理） |
| 普通用户 | `user@fitpulse.com` | `User123!` | 基础权限，无系统管理菜单 |

## 🚀 部署步骤

### 生产环境部署（推荐）

```bash
# 步骤 1: 创建数据库
mysql -u root -p < 00_init.sql

# 步骤 2: 创建表结构（含RBAC）
mysql -u root -p < 01_schema.sql

# 步骤 3: 插入初始数据（含测试用户）
mysql -u root -p < 02_init_data.sql

# 完成！系统已可用，使用上述测试账号登录
```

### 开发/测试环境部署

开发环境使用相同的3个文件即可，无需额外的测试数据文件：

```bash
# 执行基本的3个文件（已包含测试账号）
mysql -u root -p < 00_init.sql
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_init_data.sql
```

### PowerShell 一键部署

```powershell
# 方式一：逐个执行
Get-Content .\00_init.sql | mysql -u root -p
Get-Content .\01_schema.sql | mysql -u root -p
Get-Content .\02_init_data.sql | mysql -u root -p

# 方式二：一条命令全部执行
Get-Content .\00_init.sql, .\01_schema.sql, .\02_init_data.sql | mysql -u root -p
```

### Docker MySQL 部署

```bash
# 进入容器执行
docker exec -i mysql8-demo mysql -u root -p123456 < 00_init.sql
docker exec -i mysql8-demo mysql -u root -p123456 < 01_schema.sql
docker exec -i mysql8-demo mysql -u root -p123456 < 02_init_data.sql
```

## 📊 脚本内容详解

### 00_init.sql - 数据库初始化

**包含内容**:
- 设置客户端字符集 (utf8mb4)
- 创建 `fitpulse_db` 数据库
- 验证数据库创建结果

**特点**:
- 独立的数据库创建脚本
- 可单独执行用于重建数据库

### 01_schema.sql - 表结构定义（含RBAC）

**包含内容**:
- 创建 **19 张数据表**（7大模块）：
  - **用户模块** (2表): `user`, `health_profile`
  - **健康记录** (4表): `weight_log`, `workout_log`, `sleep_log`, `diet_log`
  - **智能体模块** (2表): `agent`, `agent_config`
  - **对话模块** (2表): `conversation`, `message`
  - **计划模块** (1表): `health_plan`
  - **LLM配置** (2表): `llm_provider`, `llm_model`
  - **RBAC权限系统** (6表): `role`, `permission`, `menu`, `user_role`, `role_permission`, `role_menu`

**特点**:
- 纯 DDL 语句，不包含任何数据
- 使用 `DROP TABLE IF EXISTS` 支持重复执行
- 支持外键约束和多种索引
- 用户表支持软删除（deleted字段）
- 结构化分区注释

### 02_init_data.sql - 初始化数据（含测试用户）

**包含内容**:
- **LLM提供商** (5个): OpenAI、Azure OpenAI、智谱AI、百川智能、阿里通义千问
- **LLM模型** (10个): 
  - OpenAI: GPT-4, GPT-4 Turbo, GPT-3.5 Turbo
  - 智谱AI: GLM-4, GLM-3-Turbo
  - 百川: Baichuan2-Turbo, Baichuan2-Turbo-192K
  - 通义千问: Qwen-Turbo, Qwen-Plus, Qwen-Max
- **RBAC角色** (2个): ROLE_ADMIN (管理员), ROLE_USER (普通用户)
- **RBAC权限** (22个): 覆盖用户、健康、智能体、对话、计划、知识库、系统管理
- **RBAC菜单** (11个): 6个顶级菜单 + 5个子菜单
- **测试用户** (2个):
  - admin@fitpulse.com (Admin123!) - 管理员，拥有所有权限
  - user@fitpulse.com (User123!) - 普通用户，基础权限
- **健康档案**: 为两个测试用户创建初始档案

**特点**:
- 系统运行必需的配置 + 测试账号
- 密码使用BCrypt哈希（与后端加密算法一致）
- 包含完整的RBAC权限体系
- 执行后即可使用测试账号登录系统

## ⚙️ 配置修改

### 修改测试用户密码

如需修改测试用户密码，需要通过后端API注册新用户，然后从数据库获取BCrypt哈希值：

1. 启动后端服务
2. 调用 `/api/v1/auth/register` 注册临时用户
3. 从数据库查询 `password_hash` 字段
4. 将哈希值更新到 `02_init_data.sql` 的用户插入语句中

### 添加新的LLM提供商

在 `02_init_data.sql` 的LLM提供商插入部分添加：

```sql
INSERT INTO `llm_provider` 
(`name`, `code`, `api_base_url`, `api_key`, `description`, `is_enabled`, `sort_order`) 
VALUES ('新提供商', 'new_provider', 'https://api.example.com', 'your-api-key', '描述', 1, 10);
```

### 添加新的LLM模型

在 `02_init_data.sql` 的LLM模型插入部分添加：

```sql
INSERT INTO `llm_model` 
(`provider_id`, `model_name`, `model_code`, `description`, `max_tokens`, 
 `supports_function_calling`, `supports_vision`, `is_enabled`, `sort_order`) 
VALUES (1, '模型名称', 'model-code', '描述', 8192, 1, 0, 1, 20);
VALUES (4, '系统提示词...', ...);
```

## 🔧 常用操作

### 重置整个数据库

```sql
DROP DATABASE IF EXISTS fitpulse_db;
-- 然后重新执行 00_init.sql、01_schema.sql 和 02_init_data.sql
```

### 只清空用户数据（保留配置）

```sql
USE fitpulse_db;
SET FOREIGN_KEY_CHECKS = 0;

-- 清空用户相关表
TRUNCATE TABLE message;
TRUNCATE TABLE conversation;
TRUNCATE TABLE health_plan;
TRUNCATE TABLE diet_log;
TRUNCATE TABLE sleep_log;
TRUNCATE TABLE workout_log;
TRUNCATE TABLE weight_log;
TRUNCATE TABLE health_profile;
TRUNCATE TABLE user;

SET FOREIGN_KEY_CHECKS = 1;
```

### 查看当前配置

```sql
USE fitpulse_db;

-- 查看 LLM 配置
SELECT p.name, p.provider_type, p.status, 
       COUNT(m.id) as model_count
FROM llm_provider p
LEFT JOIN llm_model m ON p.id = m.provider_id
GROUP BY p.id;

-- 查看默认模型
SELECT p.name AS provider, m.model_name, m.display_name
FROM llm_model m
JOIN llm_provider p ON m.provider_id = p.id
WHERE m.is_default = 1;

-- 查看智能体
SELECT id, name, category, status FROM agent ORDER BY id;
```

### 备份数据库

```bash
# 备份结构和数据
mysqldump -u root -p fitpulse_db > backup_$(date +%Y%m%d).sql

# 只备份结构
mysqldump -u root -p --no-data fitpulse_db > schema_backup.sql

# 只备份数据
mysqldump -u root -p --no-create-info fitpulse_db > data_backup.sql
```

## 📝 测试账号

执行 `test_data.sql` 后可用以下账号登录：

| 邮箱 | 密码 | 姓名 | 特点 |
|------|------|------|------|
| zhangsan@example.com | password123 | 张三 | 减脂用户，中级健身水平 |
| lisi@example.com | password123 | 李四 | 女性，初级，有脂肪肝 |
| wangwu@example.com | password123 | 王五 | 增肌用户，高级健身水平 |
| zhaoliu@example.com | password123 | 赵六 | 女性，瑜伽爱好者 |
| sunqi@example.com | password123 | 孙七 | 有健康风险，需改善 |

## ⚠️ 注意事项

1. **执行顺序**: 必须按 `00_init.sql` → `01_schema.sql` → `02_init_data.sql` 顺序执行
2. **API Key**: 部署到生产环境前，请在「个人设置」页面配置 LLM API Key
3. **测试数据**: 生产环境不要执行 `test_data.sql`
4. **字符编码**: 确保 MySQL 使用 UTF-8 (utf8mb4) 编码
5. **权限**: 执行脚本的用户需要有创建数据库和表的权限

## 🆘 故障排查

### 错误: Access denied

```bash
# 检查用户权限
mysql -u root -p
GRANT ALL PRIVILEGES ON fitpulse_db.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### 错误: Unknown database

确保先执行了 `00_init.sql`，它会创建数据库。

### 错误: Table doesn't exist

确保按顺序执行：先 `00_init.sql`，再 `01_schema.sql`，最后 `02_init_data.sql`。

### 错误: Foreign key constraint fails

按顺序执行脚本。如果遇到问题，删除数据库重新开始：

```sql
DROP DATABASE IF EXISTS fitpulse_db;
-- 然后重新执行 00_init.sql、01_schema.sql 和 02_init_data.sql
```

### 表已存在

脚本使用 `IF NOT EXISTS` 和 `ON DUPLICATE KEY UPDATE`，可以安全地重复执行。

## 📞 技术支持

相关文档：
- 📖 [数据库设计文档](../docs/数据库设计文档.md)
- 📖 [API设计文档](../docs/API设计文档.md)
- 📖 [开发流程指南](../docs/开发流程指南.md)

## 📋 版本历史

- **v2.0** (2026-01-06) - 重构为三文件结构（init/schema/data），添加更多 GPT 模型
- **v1.1** (2025-12-17) - 拆分为 schema 和 data 两个文件
- **v1.0** (2025-12-05) - 初始版本

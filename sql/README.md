# FitPulse 数据库部署指南

本目录包含 FitPulse 健康平台的数据库脚本，按执行顺序组织。

## 📁 文件说明

| 文件名 | 类型 | 用途 | 必须执行 |
|--------|------|------|----------|
| `01_schema.sql` | DDL | 创建数据库和表结构 | ✅ 是 |
| `02_init_data.sql` | DML | 插入初始配置（LLM、智能体） | ✅ 是 |
| `test_data.sql` | DML | 插入测试用户和示例数据 | ❌ 可选 |

## 🚀 部署步骤

### 生产环境部署（推荐）

```bash
# 步骤 1: 创建数据库和表结构
mysql -u root -p < 01_schema.sql

# 步骤 2: 插入初始配置数据
mysql -u root -p < 02_init_data.sql

# 完成！系统已可用
```

### 开发/测试环境部署

```bash
# 步骤 1: 创建数据库和表结构
mysql -u root -p < 01_schema.sql

# 步骤 2: 插入初始配置数据
mysql -u root -p < 02_init_data.sql

# 步骤 3: 插入测试数据（可选）
mysql -u root -p < test_data.sql
```

### PowerShell 部署

```powershell
# 方式一：逐个执行
Get-Content .\01_schema.sql | mysql -u root -p
Get-Content .\02_init_data.sql | mysql -u root -p
Get-Content .\test_data.sql | mysql -u root -p  # 可选

# 方式二：一条命令全部执行
Get-Content .\01_schema.sql, .\02_init_data.sql | mysql -u root -p
```

## 📊 脚本内容详解

### 01_schema.sql - 表结构定义

**包含内容**:
- 创建 `fitpulse_db` 数据库
- 创建 13 张数据表：
  - 用户相关: `user`, `health_profile`
  - 健康记录: `weight_log`, `workout_log`, `sleep_log`, `diet_log`
  - AI 智能体: `agent`, `agent_config`, `conversation`, `message`
  - 计划管理: `health_plan`
  - LLM 配置: `llm_provider`, `llm_model`

**特点**:
- 纯 DDL 语句，不包含任何数据
- 可重复执行（使用 `IF NOT EXISTS`）
- 支持外键约束和索引

### 02_init_data.sql - 初始配置

**包含内容**:
- **LLM 提供商**: 阿里云百炼（默认启用）、OpenAI（备用）
- **LLM 模型**: qwen-plus（默认）、qwen-turbo、qwen-max、qwen-long、gpt-4o
- **预置智能体**: 3 个系统智能体
  1. AI 健康助手（综合健康咨询）
  2. 饮食营养顾问（饮食分析）
  3. 睡眠改善顾问（睡眠优化）

**特点**:
- 系统运行必需的配置
- 使用 `ON DUPLICATE KEY UPDATE`，可重复执行
- 包含查询语句，执行后显示配置结果

### test_data.sql - 测试数据

**包含内容**:
- 5 个测试用户（密码: `password123`）
- 健康档案和历史记录（体重、运动、睡眠、饮食）
- 4 个额外智能体
- 示例对话和消息
- 健康计划数据

**特点**:
- 仅用于开发和测试
- 生产环境不要执行
- 包含完整的用户使用场景

## ⚙️ 配置修改

### 修改阿里云百炼 API Key

编辑 `02_init_data.sql`，找到第 17 行：

```sql
'your-sk-api',  -- 请修改为您的 API Key
```

替换为您自己的 API Key。

### 切换到 OpenAI

1. 编辑 `02_init_data.sql`
2. 在 OpenAI 提供商配置中填入 API Key（第 29 行）
3. 将状态改为 `ENABLED`，将阿里云改为 `DISABLED`
4. 修改默认模型：将 gpt-4o 的 `is_default` 改为 1，qwen-plus 改为 0

### 添加新的智能体

在 `02_init_data.sql` 的智能体插入部分添加：

```sql
INSERT INTO `agent` (`id`, `name`, `category`, `description`, ...)
VALUES (4, '新智能体名称', 'GENERAL', '描述...', ...);

INSERT INTO `agent_config` (`agent_id`, `system_prompt`, ...)
VALUES (4, '系统提示词...', ...);
```

## 🔧 常用操作

### 重置整个数据库

```sql
DROP DATABASE IF EXISTS fitpulse_db;
-- 然后重新执行 01 和 02
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

1. **执行顺序**: 必须先执行 `01_schema.sql`，再执行 `02_init_data.sql`
2. **API Key**: 部署到生产环境前，请修改 `02_init_data.sql` 中的 API Key
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

确保先执行了 `01_schema.sql`，它会创建数据库。

### 错误: Foreign key constraint fails

按顺序执行脚本。如果遇到问题，删除数据库重新开始：

```sql
DROP DATABASE IF EXISTS fitpulse_db;
```

### 表已存在

脚本使用 `IF NOT EXISTS` 和 `ON DUPLICATE KEY UPDATE`，可以安全地重复执行。

## 📞 技术支持

相关文档：
- 📖 [数据库设计文档](../docs/数据库设计文档.md)
- 📖 [API设计文档](../docs/API设计文档.md)
- 📖 [开发流程指南](../docs/开发流程指南.md)

## 📋 版本历史

- **v2.0** (2025-12-17) - 拆分为 schema 和 data 两个文件，便于部署
- **v1.1** (2025-12-15) - 添加阿里云百炼支持
- **v1.0** (2025-12-05) - 初始版本

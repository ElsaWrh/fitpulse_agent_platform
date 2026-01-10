# FitPulse API 设计文档

**脉动健康 · 多维生活管理系统（FitPulse）**  
后端接口设计 · RESTful + JWT

---

## 📋 目录

- [0. 总览](#0-总览)
- [1. 通用约定](#1-通用约定)
- [2. 认证 & 用户模块](#2-认证--用户模块)
- [3. 健康档案 & 健康数据](#3-健康档案--健康数据)
- [4. 🤖 智能体（Agent）模块](#4--智能体agent模块)
- [5. 💬 会话 & 聊天模块](#5--会话--聊天模块)
- [6. 📚 知识库（RAG）](#6--知识库rag)
- [7. 📆 健康计划 & 工作流](#7--健康计划--工作流)
- [8. 🧠 LLM 管理模块](#8--llm-管理模块)
- [9. 🛠 管理后台接口](#9--管理后台接口)
- [10. MVP 优先级建议](#10-mvp-优先级建议)

---

## 0. 总览

### 技术栈

- **后端框架**: Spring Boot 3.x
- **数据库**: MySQL 8.0+
- **认证**: JWT (JSON Web Tokens)
- **权限**: RBAC (Role-Based Access Control)
- **架构风格**: RESTful API

### 领域模块

| 模块 | 说明 |
|------|------|
| 🔐 **认证 & 用户** | 用户注册、登录、个人信息管理 |
| 🩺 **健康档案 & 健康数据** | 体重 / 训练 / 睡眠 / 饮食记录 |
| 🤖 **智能体平台** | 教练 / 顾问智能体 + 模型选择 |
| 💬 **会话对话** | 多轮对话、上下文管理 |
| 📚 **RAG 知识库** | 健康知识检索与问答 |
| 📆 **健康计划** | 计划生成 / 周报 / 风险提醒 |
| 🧠 **LLM 管理** | 提供商 & 模型管理 |
| 🛠 **管理后台** | 用户管理、智能体审核、运营统计 |

---

## 1. 通用约定

### 1.1 Base URL

```
/api
```

**示例**: `https://api.fitpulse.com/api/auth/login`

### 1.2 统一响应格式

所有接口返回统一的 JSON 结构：

```json
{
  "code": 0,
  "message": "OK",
  "data": {},
  "timestamp": 1730000000000
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | int | 0 表示成功；其他为错误码 |
| `message` | string | 提示信息 |
| `data` | any | 实际数据，结构由具体接口约定 |
| `timestamp` | long | 服务器时间戳（毫秒） |

### 1.3 常用错误码

| code | 含义 |
|------|------|
| 0 | 成功 |
| 4001 | 参数错误 / 校验失败 |
| 4002 | 业务规则校验失败（状态不允许等） |
| 4010 | 未登录 / Token 失效 |
| 4030 | 权限不足 |
| 4040 | 资源不存在 |
| 4090 | 资源冲突（邮箱已存在等） |
| 5000 | 服务器内部错误 |

### 1.4 认证

采用 **JWT (JSON Web Token)** 进行身份认证。

**使用方式**:
1. 用户登录成功后，返回 `token`
2. 前端在后续请求头中携带：

```http
Authorization: Bearer <jwt-token>
```

### 1.5 分页规范

#### 请求参数 (Query)

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `page` | int | 1 | 页码，从 1 开始 |
| `size` | int | 10 | 每页条数，最大 100 |

#### 分页响应 `data` 结构

```json
{
  "items": [],
  "page": 1,
  "size": 10,
  "total": 123
}
```

**字段说明**:

| 字段 | 说明 |
|------|------|
| `items` | 当前页列表数据 |
| `page` | 当前页码 |
| `size` | 每页大小 |
| `total` | 总记录数 |

---

## 2. 认证 & 用户模块

### 2.1 Auth 认证

#### POST /auth/register · 用户注册

**属性**:
- 鉴权: ❌ 否
- Content-Type: `application/json`

**请求体**:

```json
{
  "email": "user@example.com",
  "password": "P@ssw0rd!",
  "nickname": "Leo"
}
```

**响应示例**:

```json
{
  "code": 0,
  "message": "注册成功",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "Leo",
    "role": "USER"
  },
  "timestamp": 1701648000000
}
```

---

#### POST /auth/login · 用户登录

**属性**:
- 鉴权: ❌ 否
- Content-Type: `application/json`

**请求体**:

```json
{
  "email": "user@example.com",
  "password": "P@ssw0rd!"
}
```

**响应示例**:

```json
{
  "code": 0,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "nickname": "Leo",
      "role": "USER"
    }
  },
  "timestamp": 1701648000000
}
```

**字段说明**:
- `token`: JWT 令牌
- `expiresIn`: 过期时间（秒）
- `user`: 用户基本信息

---

#### GET /auth/me · 当前登录用户

**属性**:
- 鉴权: ✅ 是
- 返回: 当前用户信息

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "Leo",
    "role": "USER",
    "avatarUrl": "https://example.com/avatar.png"
  }
}
```

---

### 2.2 用户信息

#### GET /users/me · 我的资料

**属性**:
- 鉴权: ✅ 是

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "Leo",
    "avatarUrl": "https://example.com/avatar.png",
    "gender": "MALE",
    "birthday": "1999-05-20",
    "createdAt": "2025-01-01T10:00:00"
  }
}
```

---

#### PUT /users/me · 更新资料

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体示例**:

```json
{
  "nickname": "Leo",
  "avatarUrl": "https://example.com/avatar.png",
  "gender": "MALE",
  "birthday": "1999-05-20"
}
```

**响应**: 返回更新后的用户信息

---

## 3. 健康档案 & 健康数据

### 3.1 健康档案 health_profile

#### GET /health/profile

**属性**:
- 鉴权: ✅ 是
- 返回: 当前用户健康档案

**响应示例 (data)**:

```json
{
  "height": 175.0,
  "currentWeight": 72.5,
  "targetWeight": 68.0,
  "bmi": 23.7,
  "fitnessLevel": "BEGINNER",
  "weeklyWorkoutDays": 3,
  "preferredTime": "EVENING",
  "medicalConditions": "由医生确诊为高血压",
  "familyHistory": "父亲2型糖尿病",
  "exerciseRestrictions": "不宜高强度爆发",
  "hasCardiovascularRisk": true,
  "hasDiabetesRisk": true,
  "healthGoal": "减脂+改善心肺耐力"
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `height` | float | 身高 (cm) |
| `currentWeight` | float | 当前体重 (kg) |
| `targetWeight` | float | 目标体重 (kg) |
| `bmi` | float | 体质指数 |
| `fitnessLevel` | enum | 健身水平: BEGINNER/INTERMEDIATE/ADVANCED |
| `weeklyWorkoutDays` | int | 每周训练天数 |
| `preferredTime` | enum | 偏好训练时间: MORNING/AFTERNOON/EVENING |
| `medicalConditions` | string | 已确诊疾病 |
| `familyHistory` | string | 家族病史 |
| `exerciseRestrictions` | string | 运动限制 |
| `hasCardiovascularRisk` | boolean | 是否有心血管风险 |
| `hasDiabetesRisk` | boolean | 是否有糖尿病风险 |
| `healthGoal` | string | 健康目标 |

---

#### POST /health/profile · 创建/初始化档案

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**说明**: 首次创建或关键字段变化时，可在 Service 层触发「初次评估 & 计划生成」工作流。

**请求体**: 同 GET 返回结构（可选字段部分为空）

---

#### PUT /health/profile · 更新档案

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**: 同 POST

---

### 3.2 体重记录 weight_log

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 新增记录 | POST | `/health/weights` |
| 查询记录 | GET | `/health/weights` |
| 更新记录 | PUT | `/health/weights/{id}` |
| 删除记录 | DELETE | `/health/weights/{id}` |

---

#### GET /health/weights

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 必填 | 说明 |
|------|------|------|
| `startDate` | ❌ | 起始日期 YYYY-MM-DD |
| `endDate` | ❌ | 结束日期 YYYY-MM-DD |
| `page` | ❌ | 分页页码 |
| `size` | ❌ | 每页条数 |

**响应 items 示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 1,
        "recordDate": "2025-12-01",
        "weight": 72.5,
        "bmi": 23.7,
        "bodyFatPercentage": 18.2,
        "notes": "训练后称重"
      },
      {
        "id": 2,
        "recordDate": "2025-12-02",
        "weight": 72.3,
        "bmi": 23.6,
        "bodyFatPercentage": 18.1,
        "notes": ""
      }
    ],
    "page": 1,
    "size": 10,
    "total": 25
  }
}
```

---

#### POST /health/weights

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "recordDate": "2025-12-03",
  "weight": 72.0,
  "bodyFatPercentage": 18.0,
  "notes": "晚上称的"
}
```

**响应**: 返回创建的体重记录

---

### 3.3 训练记录 workout_log

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 训练打卡 | POST | `/health/workouts` |
| 查询训练记录 | GET | `/health/workouts` |

---

#### POST /health/workouts

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "workoutDate": "2025-12-03",
  "workoutType": "CARDIO",
  "title": "30 分钟慢跑",
  "durationMinutes": 30,
  "intensity": "MODERATE",
  "caloriesBurned": 260,
  "agentId": 5,
  "planId": 12,
  "status": "COMPLETED",
  "notes": "感觉状态不错"
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `workoutType` | enum | CARDIO / STRENGTH / HIIT / FLEXIBILITY |
| `intensity` | enum | LOW / MODERATE / HIGH |
| `status` | enum | PLANNED / IN_PROGRESS / COMPLETED / SKIPPED |

---

#### GET /health/workouts

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `startDate` | 起始日期 |
| `endDate` | 结束日期 |
| `type` | CARDIO / STRENGTH / HIIT / ... |
| `page` / `size` | 分页 |

---

### 3.4 睡眠记录 sleep_log

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 新增睡眠记录 | POST | `/health/sleeps` |
| 查询睡眠记录 | GET | `/health/sleeps` |

---

#### POST /health/sleeps

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "sleepDate": "2025-12-03",
  "sleepHours": 7.5,
  "sleepQuality": 4,
  "bedTime": "23:30:00",
  "wakeTime": "07:00:00",
  "notes": "中途醒一次"
}
```

**字段说明**:
- `sleepQuality`: 1-5 分，5 分最好

---

### 3.5 饮食记录（文字）diet_log

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 记录饮食 | POST | `/health/diets` |
| 查询饮食 | GET | `/health/diets` |
| 查看详情 | GET | `/health/diets/{id}` |
| 更新记录 | PUT | `/health/diets/{id}` |
| 删除记录 | DELETE | `/health/diets/{id}` |

---

#### POST /health/diets

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "mealDate": "2025-12-03",
  "mealType": "BREAKFAST",
  "description": "燕麦+鸡蛋+苹果",
  "calories": 420,
  "protein": 24.0,
  "carbs": 50.0,
  "fat": 12.0,
  "notes": "比较清淡"
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `mealType` | enum | BREAKFAST / LUNCH / DINNER / SNACK |
| `calories` | int | 总热量 (kcal) |
| `protein` | float | 蛋白质 (g) |
| `carbs` | float | 碳水化合物 (g) |
| `fat` | float | 脂肪 (g) |

---

## 4. 🤖 智能体（Agent）模块

### 4.1 智能体列表 & 创建

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 查询智能体 | GET | `/agents` |
| 创建个人智能体 | POST | `/agents` |
| 查看智能体详情 | GET | `/agents/{id}` |
| 更新智能体 | PUT | `/agents/{id}` |
| 删除智能体（软删） | DELETE | `/agents/{id}` |

---

#### GET /agents

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `category` | FAT_LOSS_COACH / MUSCLE_COACH / NUTRITION_ADVISOR / GENERAL |
| `visibility` | PUBLIC / PRIVATE / MINE |
| `page` / `size` | 分页 |

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 5,
        "name": "夜跑友好型减脂教练",
        "category": "FAT_LOSS_COACH",
        "visibility": "PRIVATE",
        "avatarUrl": "https://example.com/coach.png",
        "createdBy": 1
      }
    ],
    "page": 1,
    "size": 10,
    "total": 1
  }
}
```

---

#### POST /agents

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体示例**:

```json
{
  "name": "夜跑友好型减脂教练",
  "avatarUrl": "https://example.com/coach.png",
  "description": "适合晚上训练的减脂教练，注意心血管风险控制。",
  "category": "FAT_LOSS_COACH",
  "visibility": "PRIVATE"
}
```

**响应 data**:

```json
{
  "id": 5,
  "name": "夜跑友好型减脂教练",
  "category": "FAT_LOSS_COACH",
  "visibility": "PRIVATE",
  "createdBy": 1
}
```

---

### 4.2 智能体配置 agent_config

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 获取配置 | GET | `/agents/{id}/config` |
| 更新配置 | PUT | `/agents/{id}/config` |

---

#### GET /agents/{id}/config

**属性**:
- 鉴权: ✅ 是

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "agentId": 5,
    "systemPrompt": "你是一名专业的夜跑减脂教练，要根据用户健康档案和训练记录给出循序渐进且安全的建议……",
    "languageStyle": "ENCOURAGING",
    "canReadProfile": true,
    "canReadWorkouts": true,
    "canReadDietLogs": true,
    "kbScope": ["FAT_LOSS_BASICS", "CARDIO_HEALTH", "NUTRITION"],
    "llmModelId": 2,
    "llmParams": {
      "temperature": 0.7,
      "maxTokens": 2048
    }
  }
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `systemPrompt` | string | 系统提示词 |
| `languageStyle` | enum | PROFESSIONAL / ENCOURAGING / CASUAL |
| `canReadProfile` | boolean | 是否可读取健康档案 |
| `canReadWorkouts` | boolean | 是否可读取训练记录 |
| `canReadDietLogs` | boolean | 是否可读取饮食记录 |
| `kbScope` | array | 知识库范围 |
| `llmModelId` | int | 关联的 LLM 模型 ID |
| `llmParams` | object | LLM 参数配置 |

---

#### PUT /agents/{id}/config

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**: 同 GET 返回结构

---

## 5. 💬 会话 & 聊天模块

### 5.1 会话 conversation

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 列表 | GET | `/conversations` |
| 新建会话 | POST | `/conversations` |
| 查看会话详情 | GET | `/conversations/{id}` |
| 删除会话（软删） | DELETE | `/conversations/{id}` |

---

#### POST /conversations

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "agentId": 5,
  "title": "12 月减脂计划讨论"
}
```

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "id": 100,
    "agentId": 5,
    "title": "12 月减脂计划讨论",
    "createdAt": "2025-12-03T10:00:00",
    "updatedAt": "2025-12-03T10:00:00"
  }
}
```

---

### 5.2 消息 message

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 获取消息列表 | GET | `/conversations/{id}/messages` |
| 发送消息 & 回复 | POST | `/conversations/{id}/messages` |

---

#### GET /conversations/{id}/messages

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `page` / `size` | 分页 |
| `order` | 可选 ASC / DESC |

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 1001,
        "role": "user",
        "content": "帮我看看今天这顿午饭对减脂和高血压是不是很不友好？",
        "createdAt": "2025-12-03T12:10:00",
        "llmModelId": null,
        "kbReferences": []
      },
      {
        "id": 1002,
        "role": "assistant",
        "content": "根据您的午餐记录，炸鸡腿含有较高的脂肪和钠，对减脂和高血压控制确实不太友好……",
        "createdAt": "2025-12-03T12:10:15",
        "llmModelId": 2,
        "kbReferences": [
          {
            "articleId": 10,
            "title": "高血压患者的饮食建议"
          }
        ]
      }
    ],
    "page": 1,
    "size": 10,
    "total": 2
  }
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `role` | enum | user / assistant |
| `content` | string | 消息内容 |
| `llmModelId` | int | 使用的 LLM 模型 ID（仅 assistant） |
| `kbReferences` | array | 引用的知识库文章 |

---

#### POST /conversations/{id}/messages

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "content": "帮我结合健康档案看下最近两周体重变化正常吗？",
  "extraContext": {
    "fromDietLogId": 101
  }
}
```

**响应**:

常见做法：`data` 返回 AI 回复对应的那条 `assistant` 消息，或包含 `user` + `assistant` 两条消息，由实现自行约定。

```json
{
  "code": 0,
  "data": {
    "userMessage": {
      "id": 1003,
      "role": "user",
      "content": "帮我结合健康档案看下最近两周体重变化正常吗？"
    },
    "assistantMessage": {
      "id": 1004,
      "role": "assistant",
      "content": "根据您的健康档案和最近两周的体重数据，您从 72.5kg 降至 71.8kg……"
    }
  }
}
```

---

## 6. 🧠 LLM 管理模块

### 6.1 提供商 llm_provider

#### 功能概览

| 功能 | 方法 | 路径 | 权限 |
|------|------|------|------|
| 列出提供商 | GET | `/llm/providers` | ADMIN |
| 新增提供商 | POST | `/llm/providers` | ADMIN |
| 更新提供商 | PUT | `/llm/providers/{id}` | ADMIN |
| 删除提供商 | DELETE | `/llm/providers/{id}` | ADMIN |

---

#### GET /llm/providers

**属性**:
- 鉴权: ✅ 是（ADMIN）

**响应示例**:

```json
{
  "code": 0,
  "data": [
    {
      "id": 1,
      "name": "OpenAI",
      "code": "OPENAI",
      "baseUrl": "https://api.openai.com/v1",
      "apiKey": "sk-***",
      "isEnabled": true
    },
    {
      "id": 2,
      "name": "Azure OpenAI",
      "code": "AZURE_OPENAI",
      "baseUrl": "https://your-resource.openai.azure.com",
      "isEnabled": true
    }
  ]
}
```

---

### 6.2 模型 llm_model

#### 功能概览

| 功能 | 方法 | 路径 | 权限 |
|------|------|------|------|
| 列出模型 | GET | `/llm/models` | ADMIN |
| 获取默认模型 | GET | `/llm/models/default` | ADMIN |
| 新增模型 | POST | `/llm/models` | ADMIN |
| 更新模型 | PUT | `/llm/models/{id}` | ADMIN |
| 删除模型 | DELETE | `/llm/models/{id}` | ADMIN |

---

#### GET /llm/models

**属性**:
- 鉴权: ✅ 是（ADMIN）

**响应示例**:

```json
{
  "code": 0,
  "data": [
    {
      "id": 1,
      "providerId": 1,
      "modelName": "gpt-4-turbo",
      "displayName": "GPT-4 Turbo",
      "modelType": "CHAT",
      "isDefault": false,
      "isEnabled": true
    },
    {
      "id": 2,
      "providerId": 1,
      "modelName": "gpt-4o",
      "displayName": "GPT-4o",
      "modelType": "MULTIMODAL",
      "isDefault": true,
      "isEnabled": true
    }
  ]
}
```

**字段说明**:
- `modelType`: CHAT / EMBEDDING / MULTIMODAL
- `isDefault`: 是否为默认模型

---

#### GET /llm/models/default

**属性**:
- 鉴权: ✅ 是（ADMIN）

**功能**: 获取默认模型配置

**智能体配置中的 `llmModelId` 与此表关联。**

---

## 7. 🛠 管理后台接口

### 7.1 用户 & 角色管理

#### 功能概览

| 功能 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 用户列表 | GET | `/admin/users` | 分页查看用户 |
| 用户详情 | GET | `/admin/users/{id}` | |
| 更新用户信息 | PUT | `/admin/users/{id}` | |
| 设置角色 | PUT | `/admin/users/{id}/role` | 分配 Admin 等 |
| 设置状态 | PUT | `/admin/users/{id}/status` | 启用/禁用 |

---

#### GET /admin/users

**属性**:
- 鉴权: ✅ 是（ADMIN）

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `keyword` | 邮箱/昵称模糊搜索 |
| `role` | USER / ADMIN |
| `status` | ACTIVE / DISABLED |
| `page` / `size` | 分页 |

---

#### PUT /admin/users/{id}/role

**请求体**:

```json
{
  "role": "ADMIN"
}
```

---

#### PUT /admin/users/{id}/status

**请求体**:

```json
{
  "status": "DISABLED",
  "reason": "违规操作"
}
```

---

### 7.2 智能体审核

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 待审核列表 | GET | `/admin/agents/pending` |
| 查看配置 | GET | `/admin/agents/{id}` |
| 审核通过 | POST | `/admin/agents/{id}/approve` |
| 审核驳回 | POST | `/admin/agents/{id}/reject` |
| 下架公开智能体 | POST | `/admin/agents/{id}/offline` |

---

#### GET /admin/agents/pending

**属性**:
- 鉴权: ✅ 是（ADMIN）

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 8,
        "name": "营养顾问 Pro",
        "category": "NUTRITION_ADVISOR",
        "visibility": "PUBLIC",
        "status": "PENDING",
        "createdBy": 3,
        "createdAt": "2025-12-01T10:00:00"
      }
    ],
    "page": 1,
    "size": 10,
    "total": 5
  }
}
```

---

#### POST /admin/agents/{id}/approve

**属性**:
- 鉴权: ✅ 是（ADMIN）

**功能**: 审核通过智能体，状态变更为 `APPROVED`

---

#### POST /admin/agents/{id}/reject

**属性**:
- 鉴权: ✅ 是（ADMIN）

**请求体**:

```json
{
  "reason": "系统提示词存在不当内容"
}
```

---

## 8. MVP 优先级建议

按实现顺序推荐：

### ✅ 第一阶段：基础能力

1. **认证 & 用户**
   - `/auth/*`, `/users/me`
   
2. **健康档案 & 基础数据**
   - `/health/profile`
   - `/health/weights`
   - `/health/workouts`

### ✅ 第二阶段：核心功能

3. **智能体 & 聊天**
   - `/agents`, `/agents/{id}/config`
   - `/conversations`, `/conversations/{id}/messages`

4. **饮食记录**
  - `/health/diets`

### ✅ 第三阶段：高级功能

5. **计划/周报/提醒**（可逐步补充）
   - `/health/plans/*`
   - `/health/reports`
   - `/health/alerts`

6. **LLM 管理**
   - `/llm/*`

7. **管理后台**
   - `/admin/**`

---

## 📝 附录

### 数据库表映射

本 API 设计与 **数据库设计文档 V1.1.0** 对应，核心表包括：

| 表名 | 对应 API 模块 |
|------|--------------|
| `user` | `/auth`, `/users` |
| `health_profile` | `/health/profile` |
| `weight_log` | `/health/weights` |
| `workout_log` | `/health/workouts` |
| `sleep_log` | `/health/sleeps` |
| `diet_log` | `/health/diets` |
| `agent` | `/agents` |
| `agent_config` | `/agents/{id}/config` |
| `conversation` | `/conversations` |
| `message` | `/conversations/{id}/messages` |1）功能实现范围与边界（必加，避免扣分）

你当前“功能介绍”描述得比较全面，但老师不知道哪些是“已实现、可演示”的。建议加一节：

## 功能实现状态（与代码一致）

✅ 已实现
- Docker Compose 一键部署（MySQL / phpMyAdmin / 后端 / 前端-Nginx）
- 数据库初始化（sql/01_schema.sql、sql/02_init_data.sql）
- 用户登录鉴权（JWT）
- 健康档案与基础记录管理（体重/训练/睡眠/饮食：以实际页面与接口为准）
- 智能对话：后端调用 LLM API 返回健康建议
- 会话历史持久化：对话记录落库，可再次进入查看历史

🧩 未实现 / 非本次范围
- RAG 知识库检索增强
- 工作流（计划/周报/风险提醒）
- 自动化测试（unit/integration/e2e）


这段能显著降低评测风险：不会因为 README 说了“工作流/知识库”但现场没有而被扣分。

2）快速演示路径（必加，老师按这条走就能打分）
## 快速演示（3–5 分钟）

1. 启动服务
```bash
cp deploy/.env.example .env
# 填写 OPENAI_API_KEY（不填则对话功能会提示未配置）
docker compose up -d --build
docker compose ps


访问页面

前端：http://localhost

phpMyAdmin：http://localhost:8081

演示流程（建议顺序）

登录（使用下方演示账号）

填写/更新健康档案与记录（体重/训练/睡眠/饮食）

打开“智能对话”页面，提问（如“根据我的目标给出训练建议”）

刷新页面/重新进入对话：历史对话仍存在（验证持久化）


---

## 3）演示账号与角色说明（强烈建议）

如果你 `02_init_data.sql` 里有初始化用户，务必写出来；没有也可以写“需自行注册”。

```md
## 演示账号（如有）

- 管理员（Admin）：（若已初始化）`admin@example.com` / `******`
- 普通用户（User）：（若已初始化）`user@example.com` / `******`

> 若仓库未内置账号，请在前端自行注册并登录。


评测现场“没有账号/找不到入口”是最常见扣分点之一。

4）环境变量清单（建议补齐，不止 Key）

你现在只写了 Key。建议加一个“最少字段表”，让别人不会卡在 DB/JWT 上。

## 环境变量说明（.env）

必填/常用项（示例，以 deploy/.env.example 为准）：
- 数据库：MYSQL_HOST / MYSQL_PORT / MYSQL_DATABASE / MYSQL_USER / MYSQL_PASSWORD / MYSQL_ROOT_PASSWORD
- 端口：FRONTEND_PORT / BACKEND_PORT / PMA_PORT / MYSQL_EXPOSE_PORT
- 鉴权：JWT_SECRET（如后端使用）
- LLM：OPENAI_API_KEY（可选但建议演示时配置），DASHSCOPE_API_KEY（可选）

5）LLM Key 未配置时行为（必写，避免老师无 Key 直接“功能坏了”）
## LLM Key 未配置时行为

- 未配置 OPENAI_API_KEY（或对应 Key）时：对话接口将返回“未配置 Key/无法调用”的提示（以实现返回为准）。
- 其他功能（登录、健康档案与记录管理、页面浏览、数据库持久化）不受影响。

6）接口文档入口 / 关键 API（加分项，写 5–10 条即可）

如果你有 Swagger，直接写地址；没有就列 API。

## 接口说明

- 后端 API 前缀：`/api`
- （可选）Swagger / OpenAPI：`http://localhost:8080/swagger-ui.html`（如有）

关键接口（示例，以代码为准）：
- POST `/api/auth/login`
- GET/PUT `/api/profile`
- GET/POST `/api/weight`
- GET/POST `/api/workout`
- GET/POST `/api/sleep`
- GET/POST `/api/diet`
- POST `/api/chat`（或 `/api/agent/chat`）
- GET `/api/conversation`、GET `/api/conversation/{id}/messages`


按照以上指南修改一下

| `health_plan` | `/health/plans` |
| `weekly_report` | `/health/reports` |
| `risk_alert` | `/health/alerts` |
| `llm_provider` | `/llm/providers` |
| `llm_model` | `/llm/models` |


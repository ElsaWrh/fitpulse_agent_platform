# FitPulse API 设计文档

**脉动健康 · 多维生活管理系统（FitPulse）**  
后端接口设计 · RESTful + JWT

---

## 📋 目录

- [0. 总览](#0-总览)
- [1. 通用约定](#1-通用约定)
- [2. 认证 & 用户模块](#2-认证--用户模块)
- [3. 健康档案 & 健康数据](#3-健康档案--健康数据)
- [4. 📸 一日三餐拍照 · AI 食物识别](#4--一日三餐拍照--ai-食物识别)
- [5. 🤖 智能体（Agent）模块](#5--智能体agent模块)
- [6. 💬 会话 & 聊天模块](#6--会话--聊天模块)
- [7. 📚 知识库（RAG）](#7--知识库rag)
- [8. 📆 健康计划 & 工作流](#8--健康计划--工作流)
- [9. 🧠 LLM 管理模块](#9--llm-管理模块)
- [10. 🛠 管理后台接口](#10--管理后台接口)
- [11. MVP 优先级建议](#11-mvp-优先级建议)

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
| 📸 **拍照识别** | AI 食物识别 & 卡路里估算 & 红黄绿灯评估 |
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

## 4. 📸 一日三餐拍照 · AI 食物识别

### 4.1 上传图片并识别 & 生成饮食记录

#### POST /health/diets/photo

**属性**:
- 鉴权: ✅ 是
- Content-Type: `multipart/form-data`

**功能**: 
上传餐食照片 → AI 识别食物 & 估算卡路里 + **红黄绿灯评估**，并在后台生成 `diet_log` 记录

---

**表单字段**:

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `mealDate` | string | ❌ | 日期，默认当天 YYYY-MM-DD |
| `mealType` | string | ✅ | BREAKFAST / LUNCH / DINNER / SNACK |
| `notes` | string | ❌ | 用户备注 |
| `files` | file[] | ✅ | 1～N 张餐食图片 |

---

**响应 data 示例**:

```json
{
  "dietLogId": 101,
  "mealDate": "2025-12-03",
  "mealType": "LUNCH",
  "totalCalories": 820,
  "overallRisk": {
    "weightControl": "YELLOW",
    "hypertension": "RED",
    "diabetes": "YELLOW"
  },
  "aiComment": "本餐总体能量偏高,炸鸡和含糖饮料对减脂和血压控制不友好,建议减少油炸和含糖饮料,增加蔬菜比例。",
  "foodItems": [
    {
      "name": "炸鸡腿",
      "estimatedWeight": 150,
      "calories": 360,
      "riskTags": ["HIGH_FAT", "HIGH_SODIUM"],
      "riskForWeightControl": "RED",
      "riskForHypertension": "RED",
      "riskForDiabetes": "YELLOW"
    },
    {
      "name": "白米饭",
      "estimatedWeight": 180,
      "calories": 250,
      "riskForWeightControl": "YELLOW",
      "riskForHypertension": "GREEN",
      "riskForDiabetes": "YELLOW"
    }
  ],
  "images": [
    {
      "url": "https://cdn.fitpulse.com/diet/2025/12/03/xyz.jpg",
      "width": 1080,
      "height": 1440
    }
  ]
}
```

---

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `dietLogId` | int | 生成的饮食记录 ID |
| `totalCalories` | int | 本餐总热量 (kcal) |
| `overallRisk` | object | 整体风险评估（红黄绿灯） |
| `overallRisk.weightControl` | enum | 减重控制: GREEN / YELLOW / RED |
| `overallRisk.hypertension` | enum | 高血压风险: GREEN / YELLOW / RED |
| `overallRisk.diabetes` | enum | 糖尿病风险: GREEN / YELLOW / RED |
| `aiComment` | string | AI 生成的饮食建议 |
| `foodItems` | array | 识别出的食物列表 |
| `foodItems[].name` | string | 食物名称 |
| `foodItems[].estimatedWeight` | int | 估算重量 (g) |
| `foodItems[].calories` | int | 该食物热量 (kcal) |
| `foodItems[].riskTags` | array | 风险标签: HIGH_FAT / HIGH_SODIUM / HIGH_SUGAR / PROCESSED |
| `images` | array | 上传的图片列表 |

---

**服务端逻辑**:

1. 保存图片 → 调用 AI 食物识别服务 → 解析食物 & 估算卡路里
2. 读取 `health_profile`（减脂目标、是否高血压/糖尿病风险）
3. 结合食物属性 → 得出**红/黄/绿灯**指标 & 文本建议
4. 写入 `diet_log`、`diet_photo`、`diet_food_item` 表（参考数据库设计文档 V1.1.0）

---

### 4.2 查看饮食记录对应的照片

#### GET /health/diets/{id}/photos

**属性**:
- 鉴权: ✅ 是

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "dietLogId": 101,
    "images": [
      {
        "url": "https://cdn.fitpulse.com/diet/2025/12/03/xyz.jpg",
        "uploadedAt": "2025-12-03T12:00:00"
      }
    ]
  }
}
```

---

## 5. 🤖 智能体（Agent）模块

### 5.1 智能体列表 & 创建

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

### 5.2 智能体配置 agent_config

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

## 6. 💬 会话 & 聊天模块

### 6.1 会话 conversation

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

### 6.2 消息 message

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
        "content": "根据您上传的午餐照片，炸鸡腿含有较高的脂肪和钠，对减脂和高血压控制确实不太友好……",
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

## 7. 📚 知识库（RAG）

### 7.1 分类 kb_category

#### 功能概览

| 功能 | 方法 | 路径 | 权限 |
|------|------|------|------|
| 列出分类 | GET | `/kb/categories` | 所有用户 |
| （Admin）增改删 | POST/PUT/DELETE | `/admin/kb/categories...` | ADMIN |

---

#### GET /kb/categories

**属性**:
- 鉴权: ✅ 是

**响应示例**:

```json
{
  "code": 0,
  "data": [
    {
      "id": 1,
      "name": "减脂基础",
      "code": "FAT_LOSS_BASICS",
      "description": "减脂相关的基础知识"
    },
    {
      "id": 2,
      "name": "心肺健康",
      "code": "CARDIO_HEALTH",
      "description": "有氧运动与心血管健康"
    }
  ]
}
```

---

### 7.2 文章 kb_article

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 搜索文章 | GET | `/kb/articles` |
| 查看详情 | GET | `/kb/articles/{id}` |

---

#### GET /kb/articles

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `categoryId` | 分类 ID |
| `keyword` | 标题/内容模糊匹配 |
| `tag` | 标签 |
| `page` / `size` | 分页 |

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 10,
        "title": "高血压患者的饮食建议",
        "summary": "详细介绍高血压患者的饮食原则……",
        "categoryId": 2,
        "tags": ["高血压", "饮食"],
        "createdAt": "2025-11-01T10:00:00"
      }
    ],
    "page": 1,
    "size": 10,
    "total": 50
  }
}
```

---

#### GET /kb/articles/{id}

**属性**:
- 鉴权: ✅ 是

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "id": 10,
    "title": "高血压患者的饮食建议",
    "content": "# 高血压患者的饮食建议\n\n## 1. 低钠饮食\n\n...",
    "categoryId": 2,
    "tags": ["高血压", "饮食"],
    "createdAt": "2025-11-01T10:00:00",
    "updatedAt": "2025-11-15T14:30:00"
  }
}
```

---

### 7.3 检索接口（供前端/智能体）

#### POST /kb/search

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "query": "高血压患者适合的运动强度",
  "categoryScope": ["CARDIO_HEALTH"],
  "topK": 5
}
```

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "results": [
      {
        "articleId": 10,
        "title": "高血压患者的饮食建议",
        "snippet": "...高血压患者应进行中低强度的有氧运动...",
        "score": 0.85
      },
      {
        "articleId": 15,
        "title": "心血管疾病与运动",
        "snippet": "...推荐快走、慢跑等中等强度运动...",
        "score": 0.78
      }
    ]
  }
}
```

**字段说明**:
- `topK`: 返回前 K 条最相关结果
- `score`: 相关度分数（0-1）

---

## 8. 📆 健康计划 & 工作流

### 8.1 健康计划 health_plan

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 当前计划 | GET | `/health/plans/current` |
| 历史计划列表 | GET | `/health/plans/history` |
| 手动生成新计划 | POST | `/health/plans/generate` |

---

#### GET /health/plans/current

**属性**:
- 鉴权: ✅ 是

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "id": 12,
    "title": "30 天夜跑减脂计划",
    "planType": "MIXED",
    "startDate": "2025-12-01",
    "endDate": "2025-12-30",
    "status": "ACTIVE",
    "planConfig": {
      "weeklyWorkouts": 4,
      "targetCaloriesPerDay": 1800,
      "workoutTypes": ["CARDIO", "STRENGTH"]
    }
  }
}
```

---

#### POST /health/plans/generate

**属性**:
- 鉴权: ✅ 是
- Content-Type: `application/json`

**请求体**:

```json
{
  "agentId": 5,
  "planType": "MIXED",
  "durationDays": 30
}
```

**字段说明**:
- `planType`: FAT_LOSS / MUSCLE_GAIN / MIXED / MAINTENANCE

**响应 data**:

```json
{
  "id": 12,
  "title": "30 天夜跑减脂计划",
  "planType": "MIXED",
  "startDate": "2025-12-01",
  "endDate": "2025-12-30",
  "status": "ACTIVE",
  "planConfig": {
    "weeklyWorkouts": 4,
    "targetCaloriesPerDay": 1800
  }
}
```

---

### 8.2 周度健康报告 weekly_report

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 周报列表 | GET | `/health/reports` |
| 周报详情 | GET | `/health/reports/{id}` |

---

#### GET /health/reports

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `page` / `size` | 分页 |

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 20,
        "reportWeek": "2025-W48",
        "startDate": "2025-11-24",
        "endDate": "2025-11-30",
        "workoutCount": 4,
        "totalDurationMinutes": 210,
        "weightChange": -0.8,
        "avgSleepHours": 7.2,
        "summary": "本周整体训练执行较好……",
        "highlights": "坚持完成 4 次训练……",
        "issues": "晚餐能量略高……",
        "suggestions": "控制晚餐油脂摄入，保持每天轻中强度活动……",
        "isRead": false
      }
    ],
    "page": 1,
    "size": 10,
    "total": 8
  }
}
```

---

#### GET /health/reports/{id}

**属性**:
- 鉴权: ✅ 是

**响应**: 返回单条周报详细信息

---

### 8.3 风险提醒 risk_alert

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 查看提醒列表 | GET | `/health/alerts` |
| 查看详情 | GET | `/health/alerts/{id}` |
| 标记已读 | POST | `/health/alerts/{id}/read` |
| 忽略提醒 | POST | `/health/alerts/{id}/dismiss` |

---

#### GET /health/alerts

**属性**:
- 鉴权: ✅ 是

**Query 参数**:

| 参数 | 说明 |
|------|------|
| `unreadOnly` | 是否仅看未读 true / false |
| `severity` | LOW / MEDIUM / HIGH / CRITICAL |
| `page` / `size` | 分页 |

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 30,
        "alertType": "WEIGHT_CHANGE",
        "severity": "HIGH",
        "title": "体重一周内下降过快",
        "content": "你最近一周体重下降超过 2.5kg，这可能存在风险，请谨慎评估训练强度和饮食控制，并考虑咨询专业医生。",
        "isRead": false,
        "isDismissed": false,
        "createdAt": "2025-12-03T09:00:00"
      }
    ],
    "page": 1,
    "size": 10,
    "total": 3
  }
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `alertType` | enum | WEIGHT_CHANGE / BLOOD_PRESSURE / DIET_RISK / ... |
| `severity` | enum | LOW / MEDIUM / HIGH / CRITICAL |
| `isRead` | boolean | 是否已读 |
| `isDismissed` | boolean | 是否已忽略 |

---

#### POST /health/alerts/{id}/read

**属性**:
- 鉴权: ✅ 是

**功能**: 标记提醒为已读

---

#### POST /health/alerts/{id}/dismiss

**属性**:
- 鉴权: ✅ 是

**功能**: 忽略提醒

---

## 9. 🧠 LLM 管理模块

### 9.1 提供商 llm_provider

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

### 9.2 模型 llm_model

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

## 10. 🛠 管理后台接口

### 10.1 用户 & 角色管理

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

### 10.2 智能体审核

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

### 10.3 知识库（Admin 视角）

#### 功能概览

| 功能 | 方法 | 路径 |
|------|------|------|
| 管理文章列表 | GET | `/admin/kb/articles` |
| 设置文章状态 | PUT | `/admin/kb/articles/{id}/status` |

---

#### PUT /admin/kb/articles/{id}/status

**属性**:
- 鉴权: ✅ 是（ADMIN）

**请求体示例**:

```json
{
  "status": "DISABLED",
  "reason": "内容过于医疗化，需要调整表述。"
}
```

**字段说明**:
- `status`: ENABLED / DISABLED

---

### 10.4 运营统计（可选）

#### GET /admin/stats/overview

**属性**:
- 鉴权: ✅ 是（ADMIN）

**响应示例**:

```json
{
  "code": 0,
  "data": {
    "totalUsers": 1200,
    "activeUsers7d": 320,
    "totalAgents": 80,
    "publicAgents": 15,
    "totalConversations": 9250,
    "llmTokensUsed": 1280000
  }
}
```

**字段说明**:

| 字段 | 说明 |
|------|------|
| `totalUsers` | 总用户数 |
| `activeUsers7d` | 近 7 天活跃用户 |
| `totalAgents` | 总智能体数 |
| `publicAgents` | 公开智能体数 |
| `totalConversations` | 总会话数 |
| `llmTokensUsed` | LLM Token 使用量 |

---

## 11. MVP 优先级建议

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

4. **饮食 & 拍照识别**（核心创新功能）
   - `/health/diets`
   - `/health/diets/photo` ⭐

### ✅ 第三阶段：高级功能

5. **计划/周报/提醒**（可逐步补充）
   - `/health/plans/*`
   - `/health/reports`
   - `/health/alerts`

6. **知识库 & LLM 管理**
   - `/kb/*`
   - `/llm/*`

7. **管理后台**
   - `/admin/**`

---

## 📝 附录

### A. 数据库表映射

本 API 设计与 **数据库设计文档 V1.1.0** 对应，核心表包括：

| 表名 | 对应 API 模块 |
|------|--------------|
| `user` | `/auth`, `/users` |
| `health_profile` | `/health/profile` |
| `weight_log` | `/health/weights` |
| `workout_log` | `/health/workouts` |
| `sleep_log` | `/health/sleeps` |
| `diet_log` | `/health/diets` |
| `diet_photo` | `/health/diets/photo` |
| `diet_food_item` | `/health/diets/photo` |
| `agent` | `/agents` |
| `agent_config` | `/agents/{id}/config` |
| `conversation` | `/conversations` |
| `message` | `/conversations/{id}/messages` |
| `kb_category` | `/kb/categories` |
| `kb_article` | `/kb/articles` |
| `health_plan` | `/health/plans` |
| `weekly_report` | `/health/reports` |
| `risk_alert` | `/health/alerts` |
| `llm_provider` | `/llm/providers` |
| `llm_model` | `/llm/models` |

---

### B. 红黄绿灯评估逻辑

**评估维度**:
- **减重控制** (`weightControl`)
- **高血压风险** (`hypertension`)
- **糖尿病风险** (`diabetes`)

**评估规则示例**:

| 食物属性 | 减重 | 高血压 | 糖尿病 |
|----------|------|--------|--------|
| 高脂肪 (`HIGH_FAT`) | 🔴 RED | 🟡 YELLOW | 🟡 YELLOW |
| 高钠 (`HIGH_SODIUM`) | 🟡 YELLOW | 🔴 RED | 🟢 GREEN |
| 高糖 (`HIGH_SUGAR`) | 🔴 RED | 🟢 GREEN | 🔴 RED |
| 加工食品 (`PROCESSED`) | 🟡 YELLOW | 🟡 YELLOW | 🟡 YELLOW |

**综合评估**: 结合用户 `health_profile` 中的目标和风险标志，生成个性化建议。

---

### C. 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| V1.0.0 | 2025-12-04 | 初始版本，完整 API 设计 |

---

### D. 联系方式

如有疑问或建议，请联系：

- **项目名称**: FitPulse (脉动健康)
- **技术栈**: Spring Boot + MySQL + JWT
- **文档维护**: 开发团队

---

**📌 提示**: 本文档采用 README 风格编写，易于阅读和维护。建议与数据库设计文档、用户需求说明书配合使用。

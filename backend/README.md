# FitPulse Backend

脉动健康管理平台后端服务

## 技术栈

- Java 17
- Spring Boot 3.4.12
- MySQL 8.0+
- Redis 7.x
- MyBatis-Plus 3.5.5
- JWT (jjwt 0.12.3)
- Hutool 5.8.25
- Fastjson2 2.0.45

## 快速开始

### 1. 环境准备

- JDK 17+
- Maven 3.9+
- MySQL 8.0+
- Redis 7.x

### 2. 配置数据库

创建数据库:
```sql
CREATE DATABASE fitpulse_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

执行数据库初始化脚本:
```bash
mysql -u root -p fitpulse_db < docs/sql/init.sql
```

### 3. 修改配置

编辑 `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/fitpulse_db
spring.datasource.username=your_username
spring.datasource.password=your_password

spring.data.redis.host=localhost
spring.data.redis.port=6379
```

### 4. 运行项目

```bash
# 使用 Maven
mvn spring-boot:run

# 或使用包装器
./mvnw spring-boot:run  # Linux/Mac
mvnw.cmd spring-boot:run  # Windows
```

### 5. 访问接口

- 健康检查: http://localhost:8080/api/health
- 用户注册: POST http://localhost:8080/api/auth/register
- 用户登录: POST http://localhost:8080/api/auth/login

## 项目结构

```
backend/
├── src/main/java/com/example/backend/
│   ├── common/           # 公共类
│   │   └── Result.java   # 统一返回结果
│   ├── config/           # 配置类
│   │   ├── CorsConfig.java
│   │   ├── MyBatisPlusConfig.java
│   │   ├── MyBatisMetaObjectHandler.java
│   │   ├── RedisConfig.java
│   │   └── WebConfig.java
│   ├── controller/       # 控制器
│   │   ├── AuthController.java
│   │   ├── UserController.java
│   │   ├── HealthController.java
│   │   └── HealthProfileController.java
│   ├── service/          # 服务层
│   │   ├── AuthService.java
│   │   ├── UserService.java
│   │   ├── HealthProfileService.java
│   │   └── impl/
│   ├── mapper/           # 数据访问层
│   │   ├── UserMapper.java
│   │   ├── HealthProfileMapper.java
│   │   └── ... (13个Mapper)
│   ├── entity/           # 实体类
│   │   ├── User.java
│   │   ├── HealthProfile.java
│   │   ├── WeightLog.java
│   │   └── ... (13个实体)
│   ├── dto/              # 数据传输对象
│   │   ├── LoginRequest.java
│   │   ├── RegisterRequest.java
│   │   └── ...
│   ├── vo/               # 视图对象
│   │   ├── UserVO.java
│   │   ├── LoginResponse.java
│   │   └── PageResponse.java
│   ├── interceptor/      # 拦截器
│   │   └── JwtInterceptor.java
│   ├── exception/        # 异常处理
│   │   ├── BusinessException.java
│   │   └── GlobalExceptionHandler.java
│   └── utils/            # 工具类
│       ├── JwtUtil.java
│       ├── RedisUtil.java
│       └── UserContext.java
└── src/main/resources/
    ├── application.properties
    └── mapper/           # MyBatis XML 映射文件
```

## API 接口

### 认证接口

- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/me` - 获取当前用户信息

### 用户接口

- `GET /api/users/me` - 获取我的资料
- `PUT /api/users/me` - 更新我的资料

### 健康档案接口

- `GET /api/health/profile` - 获取健康档案
- `POST /api/health/profile` - 创建健康档案
- `PUT /api/health/profile` - 更新健康档案

## 开发规范

1. 所有 API 接口统一返回 `Result<T>` 类型
2. 使用 `@Valid` 进行参数校验
3. 业务异常统一抛出 `BusinessException`
4. 使用 Lombok 简化代码
5. 遵循 RESTful API 设计规范
6. 使用 JWT 进行身份认证
7. 敏感接口需要登录后访问

## 已完成功能

- ✅ 项目基础架构搭建
- ✅ 统一返回结果封装
- ✅ 全局异常处理
- ✅ JWT 认证
- ✅ 跨域配置
- ✅ MyBatis-Plus 集成
- ✅ Redis 集成
- ✅ 用户注册登录
- ✅ 用户信息管理
- ✅ 健康档案管理
- ✅ 13个核心实体类
- ✅ 完整的三层架构

## 待开发功能

- [ ] 体重记录功能
- [ ] 训练记录功能
- [ ] 睡眠记录功能
- [ ] 饮食记录功能
- [ ] 智能体管理
- [ ] 会话与消息
- [ ] 健康计划生成
- [ ] LLM 服务集成
- [ ] 文件上传功能
- [ ] Swagger API 文档
- [ ] 单元测试

## 许可证

MIT License

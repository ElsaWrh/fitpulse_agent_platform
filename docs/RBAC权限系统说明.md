# FitPulse RBAC权限管理系统

## 📋 概述

FitPulse健康平台已成功实现完整的**RBAC（基于角色的访问控制）**权限管理系统。系统支持动态菜单、细粒度权限控制、角色管理等功能。

## 🎯 核心功能

### 1. 用户认证与授权
- ✅ 用户登录（JWT Token）
- ✅ 自动加载用户菜单和权限
- ✅ Token失效自动跳转登录页
- ✅ 登录状态持久化

### 2. 动态菜单渲染
- ✅ 根据用户角色动态显示菜单
- ✅ 管理员和普通用户看到不同的菜单
- ✅ 支持树形菜单结构
- ✅ 菜单图标动态映射

### 3. 权限验证
- ✅ 后端拦截器验证权限
- ✅ `@RequiresRole` 注解验证角色
- ✅ `@RequiresPermission` 注解验证权限
- ✅ 无权访问返回403错误

### 4. 前端权限控制
- ✅ 路由守卫检查登录状态
- ✅ 按钮级权限控制
- ✅ 权限不足友好提示

## 🗂️ 数据库设计

### RBAC核心表

#### 1. **role** - 角色表
```sql
id, role_name, role_code, description, status
```
- 系统管理员（ROLE_ADMIN）
- 普通用户（ROLE_USER）

#### 2. **permission** - 权限表
```sql
id, permission_name, permission_code, resource_type, resource_path, method
```
- 功能权限：`user:list`, `user:delete` 等
- API权限：`/users`, `/agents` 等

#### 3. **menu** - 菜单表
```sql
id, parent_id, menu_name, menu_code, path, component, icon, sort_order
```
- 支持树形结构
- 菜单类型：MENU（菜单）、BUTTON（按钮）

#### 4. **user_role** - 用户角色关联表
```sql
id, user_id, role_id
```
- 多对多关系

#### 5. **role_permission** - 角色权限关联表
```sql
id, role_id, permission_id
```
- 多对多关系

#### 6. **role_menu** - 角色菜单关联表
```sql
id, role_id, menu_id
```
- 多对多关系

## 📁 文件结构

### 后端文件

```
backend/src/main/java/com/example/backend/
├── annotation/
│   ├── RequiresRole.java           # 角色验证注解
│   └── RequiresPermission.java     # 权限验证注解
├── entity/
│   ├── Role.java                   # 角色实体
│   ├── Permission.java             # 权限实体
│   ├── Menu.java                   # 菜单实体
│   ├── UserRole.java               # 用户角色关联
│   ├── RolePermission.java         # 角色权限关联
│   └── RoleMenu.java               # 角色菜单关联
├── mapper/
│   ├── RoleMapper.java             # 角色Mapper
│   ├── PermissionMapper.java       # 权限Mapper
│   ├── MenuMapper.java             # 菜单Mapper
│   ├── UserRoleMapper.java
│   ├── RolePermissionMapper.java
│   └── RoleMenuMapper.java
├── service/
│   ├── RbacService.java            # RBAC服务接口
│   └── impl/
│       └── RbacServiceImpl.java    # RBAC服务实现
├── controller/
│   └── RbacController.java         # RBAC控制器
├── interceptor/
│   ├── JwtInterceptor.java         # JWT验证拦截器
│   └── PermissionInterceptor.java  # 权限验证拦截器
└── vo/
    ├── MenuVO.java                 # 菜单VO
    └── PermissionVO.java           # 权限VO
```

### 前端文件

```
frontend/src/
├── api/
│   └── rbac.js                     # RBAC API接口
├── stores/
│   └── user.js                     # 用户状态管理（已更新）
├── components/
│   └── Layout.vue                  # 布局组件（动态菜单）
└── views/
    └── ProfileView.vue             # 个人设置（权限测试）
```

### SQL文件

```
sql/
├── 03_rbac_schema.sql              # RBAC表结构
└── 04_rbac_init_data.sql           # RBAC初始化数据
```

## 🚀 部署步骤

### 1. 数据库初始化

按顺序执行SQL文件：

```bash
# 1. 创建数据库（如果未执行）
mysql -u root -p < sql/00_init.sql

# 2. 创建基础表（如果未执行）
mysql -u root -p fitpulse_db < sql/01_schema.sql

# 3. 创建RBAC表
mysql -u root -p fitpulse_db < sql/03_rbac_schema.sql

# 4. 插入RBAC初始化数据
mysql -u root -p fitpulse_db < sql/04_rbac_init_data.sql
```

### 2. 后端启动

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### 3. 前端启动

```bash
cd frontend
npm install
npm run dev
```

## 🧪 测试账号

### 管理员账号
- **邮箱**: `admin@fitpulse.com`
- **密码**: `123456`
- **权限**: 拥有所有权限，可访问所有菜单

### 普通用户账号
- **邮箱**: `user@fitpulse.com`
- **密码**: `123456`
- **权限**: 基础功能权限，不能访问系统管理

> 注意：需要在数据库中手动创建这些测试用户，或使用已有用户。

## 📖 使用说明

### 前端使用

#### 1. 登录获取权限

```javascript
// 用户登录后自动加载菜单和权限
await userStore.login({ email, password })
// 会自动调用 loadMenusAndPermissions()
```

#### 2. 检查权限

```javascript
// 在组件中检查权限
if (userStore.hasPermission('user:delete')) {
  // 显示删除按钮
}
```

#### 3. 获取用户菜单

```javascript
// 菜单自动存储在 userStore.menus
const menus = userStore.menus
```

### 后端使用

#### 1. 添加角色验证

```java
@RestController
@RequestMapping("/admin")
public class AdminController {
    
    @GetMapping("/users")
    @RequiresRole("ROLE_ADMIN")  // 需要管理员角色
    public Result<List<User>> getUsers() {
        // ...
    }
}
```

#### 2. 添加权限验证

```java
@DeleteMapping("/users/{id}")
@RequiresPermission("user:delete")  // 需要删除权限
public Result<Void> deleteUser(@PathVariable Long id) {
    // ...
}
```

#### 3. 在Service中检查权限

```java
@Service
public class UserService {
    @Autowired
    private RbacService rbacService;
    
    public void deleteUser(Long userId, Long operatorId) {
        if (!rbacService.hasPermission(operatorId, "user:delete")) {
            throw new BusinessException("权限不足");
        }
        // ...
    }
}
```

## 🔍 API接口

### 1. 获取用户菜单
```
GET /rbac/menus
Response: List<MenuVO>
```

### 2. 获取用户权限
```
GET /rbac/permissions
Response: List<PermissionVO>
```

### 3. 测试管理员操作
```
POST /rbac/admin/test
Requires: ROLE_ADMIN
Response: "管理员操作成功"
```

### 4. 测试删除用户权限
```
DELETE /rbac/admin/delete-user
Requires: user:delete permission
Response: "删除用户成功（模拟操作）"
```

## 🎨 权限测试

访问 **个人设置** 页面底部的"权限测试"区域：

1. **管理员操作按钮**：测试角色验证
   - 管理员：操作成功
   - 普通用户：提示"权限不足：需要角色 ROLE_ADMIN"

2. **删除用户按钮**：测试权限验证
   - 有权限：操作成功
   - 无权限：提示"权限不足：需要权限 user:delete"

3. **权限列表**：显示当前用户拥有的所有权限代码

## 🔒 安全特性

1. **Token验证**：所有请求需要携带有效JWT Token
2. **权限拦截**：后端拦截器自动验证权限
3. **角色检查**：支持基于角色的粗粒度控制
4. **权限检查**：支持基于权限的细粒度控制
5. **403处理**：无权访问统一返回403错误

## 🎯 权限模型

```
User（用户）
  └─ UserRole（用户角色关联）
       └─ Role（角色）
            ├─ RolePermission（角色权限关联）
            │    └─ Permission（权限）
            │         └─ 验证API访问
            └─ RoleMenu（角色菜单关联）
                 └─ Menu（菜单）
                      └─ 前端动态渲染
```

## 📝 扩展指南

### 添加新角色

1. 在`role`表插入新角色
2. 在`role_permission`表分配权限
3. 在`role_menu`表分配菜单
4. 在`user_role`表给用户分配角色

### 添加新权限

1. 在`permission`表插入新权限
2. 在`role_permission`表关联到角色
3. 在Controller使用`@RequiresPermission`注解

### 添加新菜单

1. 在`menu`表插入新菜单项
2. 在`role_menu`表关联到角色
3. 前端自动显示（无需修改代码）

## ✅ 功能清单

- [x] 用户登录认证
- [x] JWT Token管理
- [x] 动态菜单加载
- [x] 菜单权限验证
- [x] API权限验证
- [x] 角色管理
- [x] 权限管理
- [x] 用户角色分配
- [x] 角色权限分配
- [x] 角色菜单分配
- [x] 前端路由守卫
- [x] 权限测试页面
- [x] 403错误处理

## 🎓 学习资源

- [Spring Security官方文档](https://spring.io/projects/spring-security)
- [JWT官方介绍](https://jwt.io/)
- [RBAC权限模型详解](https://en.wikipedia.org/wiki/Role-based_access_control)

## 📞 技术支持

如有问题，请查看：
1. 后端日志：检查权限验证是否正常
2. 浏览器控制台：检查API请求响应
3. 数据库：确认用户角色和权限是否正确配置

---

**系统版本**: v1.0  
**更新时间**: 2026-01-07  
**开发团队**: FitPulse Development Team

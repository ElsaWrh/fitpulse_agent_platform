# FitPulse 前端项目

基于 Vue 3 + Vite 构建的健康管理平台前端应用。

## 技术栈

- **框架**: Vue 3.5.25 (Composition API)
- **构建工具**: Vite
- **UI 框架**: Element Plus
- **状态管理**: Pinia 3.0.4
- **路由**: Vue Router 4.6.3
- **HTTP 客户端**: Axios
- **CSS 预处理器**: Sass
- **工具库**: dayjs

## 项目结构

```
src/
├── api/              # API 接口封装
│   ├── auth.js       # 认证相关
│   ├── health.js     # 健康数据
│   ├── chat.js       # 聊天相关
│   ├── agent.js      # 智能体
│   ├── plan.js       # 健康计划
│   └── index.js      # 统一导出
├── assets/           # 静态资源
│   ├── base.css
│   └── main.css
├── components/       # 公共组件
│   ├── Layout.vue    # 主布局
│   └── icons/        # 图标组件
├── composables/      # 组合式函数
│   ├── useLoading.js
│   ├── usePagination.js
│   ├── useDialog.js
│   └── index.js
├── constants/        # 常量定义
│   └── index.js      # 全局常量
├── directives/       # 自定义指令
│   ├── loading.js
│   └── index.js
├── router/           # 路由配置
│   └── index.js
├── stores/           # Pinia 状态管理
│   ├── user.js       # 用户状态
│   ├── health.js     # 健康数据
│   └── chat.js       # 聊天状态
├── styles/           # 全局样式
│   ├── variables.scss # SCSS 变量
│   ├── reset.scss    # 重置样式
│   └── common.scss   # 通用样式类
├── utils/            # 工具函数
│   ├── request.js    # Axios 配置
│   ├── format.js     # 格式化工具
│   ├── validate.js   # 验证工具
│   ├── storage.js    # 本地存储
│   └── index.js      # 统一导出
├── views/            # 页面组件
│   ├── LoginView.vue
│   ├── RegisterView.vue
│   ├── HomeView.vue
│   ├── ProfileView.vue
│   ├── HealthView.vue
│   └── ChatView.vue
├── App.vue           # 根组件
└── main.js           # 入口文件
```

## 环境配置

### 开发环境 (.env.development)
```
VITE_API_BASE_URL=http://localhost:8080/api
```

### 生产环境 (.env.production)
```
VITE_API_BASE_URL=https://your-production-api.com/api
```

## 开发指南

### 安装依赖
```bash
npm install
```

### 启动开发服务器
```bash
npm run dev
```

### 构建生产版本
```bash
npm run build
```

### 预览生产构建
```bash
npm run preview
```

## 核心功能

### 1. 用户认证
- 用户注册(邮箱 + 密码)
- 用户登录(JWT Token)
- 自动登录(Token 持久化)
- 路由守卫(认证拦截)

### 2. 健康管理
- 健康档案管理
- 体重记录
- 运动记录
- 睡眠记录
- 饮食记录

### 3. AI 对话
- 智能体对话
- 消息历史
- 多模态输入(图片 + 文本)

### 4. 健康计划
- 一键生成计划
- 计划列表查看
- 计划详情展示

## 代码规范

### 组件命名
- 页面组件: `XxxView.vue`
- 公共组件: `PascalCase.vue`
- 布局组件: `XxxLayout.vue`

### API 命名
- 接口函数: `xxxAPI`
- 例如: `loginAPI`, `getUserInfoAPI`

### Store 命名
- Store 名称: `useXxxStore`
- 例如: `useUserStore`, `useHealthStore`

### 常量命名
- 全部大写: `CONSTANT_NAME`
- 例如: `GENDER`, `ACTIVITY_LEVEL`

## 最佳实践

### 1. 使用组合式 API
```js
<script setup>
import { ref, computed, onMounted } from 'vue'

const count = ref(0)
const doubleCount = computed(() => count.value * 2)

onMounted(() => {
  console.log('组件已挂载')
})
</script>
```

### 2. 使用组合式函数
```js
import { useLoading, usePagination } from '@/composables'

const { loading, startLoading, stopLoading } = useLoading()
const { currentPage, pageSize, total } = usePagination()
```

### 3. 使用常量
```js
import { GENDER, GENDER_LABELS } from '@/constants'

const gender = GENDER.MALE
const genderLabel = GENDER_LABELS[gender] // '男'
```

### 4. 错误处理
```js
try {
  const res = await loginAPI(form)
  ElMessage.success('登录成功')
} catch (error) {
  // Axios 拦截器已统一处理错误提示
  console.error('登录失败:', error)
}
```

## 路由结构

```
/                   # 首页(需认证)
  ├── /profile      # 用户资料
  ├── /health       # 健康数据
  └── /chat         # AI 对话
/login              # 登录页
/register           # 注册页
```

## API 接口

所有接口已在 `src/api/` 目录下封装,使用统一的 Axios 实例。

### 请求拦截器
- 自动添加 Token 到请求头

### 响应拦截器
- 自动解包 `res.data`
- 统一错误处理
- Token 过期自动登出

## 状态管理

使用 Pinia 进行状态管理,主要包括:

- **userStore**: 用户信息、Token、登录/登出
- **healthStore**: 健康数据
- **chatStore**: 聊天会话、消息列表

## 样式系统

### SCSS 变量
所有主题色、字体大小、间距等定义在 `styles/variables.scss`

### 通用样式类
常用的 flex、文本、间距等类定义在 `styles/common.scss`

### 使用示例
```vue
<div class="flex-between p-3 card">
  <span class="text-primary font-bold">标题</span>
  <el-button type="primary">按钮</el-button>
</div>
```

## 工具函数

### 格式化
```js
import { formatDateTime, calculateBMI } from '@/utils'

formatDateTime(new Date()) // '2025-12-05 10:30:00'
calculateBMI(70, 175) // 22.9
```

### 验证
```js
import { isEmail, isStrongPassword } from '@/utils'

isEmail('test@example.com') // true
isStrongPassword('Abc@1234') // true
```

### 存储
```js
import { setLocal, getLocal } from '@/utils'

setLocal('key', { name: 'value' })
const value = getLocal('key')
```

## 常见问题

### 1. API 请求 CORS 错误?
确保后端已配置 CORS,允许前端域名访问。

### 2. Token 过期怎么处理?
Axios 响应拦截器会自动检测 4010 错误码,清除 Token 并跳转登录页。

### 3. 如何添加新页面?
1. 在 `views/` 创建组件
2. 在 `router/index.js` 添加路由
3. 在 `Layout.vue` 添加导航(如需要)

### 4. 如何添加新 API?
1. 在 `api/` 对应模块添加函数
2. 使用统一的 `request()` 函数
3. 在 `api/index.js` 导出

## 下一步计划

- [ ] 实现健康数据记录页面
- [ ] 实现 AI 对话功能
- [ ] 实现健康计划生成
- [ ] 添加图表可视化
- [ ] 优化移动端适配
- [ ] 添加单元测试

## 许可证

MIT

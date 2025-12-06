<template>
  <div class="login-container">
    <div class="login-wrapper">
      <!-- 左侧品牌展示区 -->
      <div class="brand-section">
        <div class="brand-content">
          <div class="logo-icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
          </div>
          <h1>FitPulse</h1>
          <p class="tagline">脉动健康 · 智慧生活</p>
          <div class="features">
            <div class="feature-item">
              <span class="feature-icon">📊</span>
              <span>智能健康数据追踪</span>
            </div>
            <div class="feature-item">
              <span class="feature-icon">🤖</span>
              <span>AI 私人健康顾问</span>
            </div>
            <div class="feature-item">
              <span class="feature-icon">🎯</span>
              <span>个性化健身计划</span>
            </div>
            <div class="feature-item">
              <span class="feature-icon">📈</span>
              <span>科学饮食分析</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 右侧登录表单区 -->
      <div class="form-section">
        <el-card class="login-card" shadow="never">
          <div class="card-header">
            <h2>欢迎回来</h2>
            <p>登录您的 FitPulse 账户</p>
          </div>
          
          <el-form
            ref="loginFormRef"
            :model="loginForm"
            :rules="loginRules"
            label-position="top"
            size="large"
          >
            <el-form-item label="邮箱地址" prop="email">
              <el-input
                v-model="loginForm.email"
                placeholder="请输入您的邮箱"
                prefix-icon="Message"
                clearable
              />
            </el-form-item>
            
            <el-form-item label="登录密码" prop="password">
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入您的密码"
                prefix-icon="Lock"
                show-password
                clearable
              />
            </el-form-item>
            
            <el-form-item>
              <el-button
                type="primary"
                :loading="loading"
                @click="handleLogin"
                class="login-btn"
              >
                {{ loading ? '登录中...' : '登 录' }}
              </el-button>
            </el-form-item>
          </el-form>
          
          <div class="form-footer">
            <span>还没有账号？</span>
            <el-link type="primary" @click="goToRegister" :underline="false">立即注册</el-link>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  email: '',
  password: ''
})

const loginRules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await userStore.login(loginForm)
        router.push('/')
      } catch (error) {
        console.error('登录失败:', error)
      } finally {
        loading.value = false
      }
    }
  })
}

const goToRegister = () => {
  router.push('/register')
}
</script>

<style scoped lang="scss">
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.login-wrapper {
  display: flex;
  width: 100%;
  max-width: 1200px;
  min-height: 600px;
  background: #fff;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.brand-section {
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  
  .brand-content {
    color: #fff;
    text-align: center;
    
    .logo-icon {
      width: 80px;
      height: 80px;
      margin: 0 auto 24px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      
      svg {
        width: 48px;
        height: 48px;
      }
    }
    
    h1 {
      font-size: 48px;
      font-weight: 700;
      margin: 0 0 12px;
      letter-spacing: 2px;
    }
    
    .tagline {
      font-size: 20px;
      opacity: 0.9;
      margin-bottom: 48px;
    }
    
    .features {
      text-align: left;
      
      .feature-item {
        display: flex;
        align-items: center;
        padding: 16px 0;
        font-size: 16px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        
        &:last-child {
          border-bottom: none;
        }
        
        .feature-icon {
          font-size: 24px;
          margin-right: 16px;
        }
      }
    }
  }
}

.form-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
  background: #fff;
}

.login-card {
  width: 100%;
  max-width: 420px;
  border: none;
  
  :deep(.el-card__body) {
    padding: 0;
  }
  
  .card-header {
    text-align: center;
    margin-bottom: 40px;
    
    h2 {
      font-size: 32px;
      color: #1a1a2e;
      margin: 0 0 12px;
      font-weight: 600;
    }
    
    p {
      font-size: 16px;
      color: #6b7280;
      margin: 0;
    }
  }
  
  :deep(.el-form-item) {
    margin-bottom: 24px;
    
    .el-form-item__label {
      font-weight: 500;
      color: #374151;
      padding-bottom: 8px;
    }
    
    .el-input__wrapper {
      padding: 8px 16px;
      border-radius: 12px;
      box-shadow: 0 0 0 1px #e5e7eb;
      
      &:hover, &.is-focus {
        box-shadow: 0 0 0 2px #667eea;
      }
    }
  }
  
  .login-btn {
    width: 100%;
    height: 52px;
    font-size: 16px;
    font-weight: 600;
    border-radius: 12px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    margin-top: 16px;
    
    &:hover {
      opacity: 0.9;
    }
  }
  
  .form-footer {
    text-align: center;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid #f3f4f6;
    font-size: 15px;
    color: #6b7280;
    
    .el-link {
      font-size: 15px;
      font-weight: 500;
      margin-left: 8px;
    }
  }
}

/* 响应式适配 */
@media (max-width: 968px) {
  .login-wrapper {
    flex-direction: column;
    max-width: 500px;
  }
  
  .brand-section {
    padding: 40px;
    
    .brand-content {
      h1 {
        font-size: 36px;
      }
      
      .features {
        display: none;
      }
    }
  }
  
  .form-section {
    padding: 40px;
  }
}
</style>

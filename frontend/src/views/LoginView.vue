<template>
  <div class="login-page">
    <div class="login-container">
      <!-- 左侧品牌展示区 -->
      <section class="login-left">
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
      </section>
      
      <!-- 右侧登录表单区 -->
      <section class="login-right">
        <div class="form-content">
          <div class="form-header">
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
        </div>
      </section>
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
.login-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  overflow: hidden;
}

.login-container {
  display: flex;
  width: 100%;
  height: 100%;
}

// 左侧品牌展示区 (45%)
.login-left {
  flex: 0 0 45%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
  color: white;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.95) 0%, rgba(118, 75, 162, 0.95) 100%);
  position: relative;
  
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600"><defs><linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:rgb(255,255,255);stop-opacity:0.05" /><stop offset="100%" style="stop-color:rgb(255,255,255);stop-opacity:0" /></linearGradient></defs><circle cx="200" cy="150" r="120" fill="url(%23grad1)"/><circle cx="800" cy="400" r="180" fill="url(%23grad1)"/><circle cx="1000" cy="100" r="100" fill="url(%23grad1)"/></svg>');
    opacity: 0.4;
    pointer-events: none;
  }
  
  .brand-content {
    position: relative;
    z-index: 1;
    max-width: 600px;
    
    .logo-icon {
      width: 80px;
      height: 80px;
      margin: 0 auto 24px;
      background: rgba(255, 255, 255, 0.15);
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      backdrop-filter: blur(10px);
      
      svg {
        width: 48px;
        height: 48px;
      }
    }
    
    h1 {
      font-size: 52px;
      font-weight: 700;
      margin: 0 0 16px;
      text-align: center;
      letter-spacing: 1px;
      text-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
    }
    
    .tagline {
      font-size: 20px;
      margin: 0 0 48px;
      text-align: center;
      opacity: 0.95;
      font-weight: 300;
    }
    
    .features {
      display: grid;
      gap: 20px;
      
      .feature-item {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 20px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.15);
        transition: all 0.3s ease;
        
        &:hover {
          background: rgba(255, 255, 255, 0.15);
          transform: translateX(8px);
        }
        
        .feature-icon {
          font-size: 28px;
          flex-shrink: 0;
        }
        
        span:not(.feature-icon) {
          font-size: 16px;
          font-weight: 400;
        }
      }
    }
  }
}

// 右侧表单区 (55%)
.login-right {
  flex: 0 0 55%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
  background: #ffffff;
  
  .form-content {
    width: 100%;
    max-width: 420px;
    
    .form-header {
      margin-bottom: 40px;
      text-align: center;
      
      h2 {
        font-size: 32px;
        font-weight: 600;
        color: #1a1a1a;
        margin: 0 0 12px;
      }
      
      p {
        font-size: 15px;
        color: #666;
        margin: 0;
      }
    }
    
    :deep(.el-form) {
      .el-form-item__label {
        font-weight: 500;
        color: #333;
        font-size: 14px;
      }
      
      .el-input {
        height: 48px;
        
        .el-input__wrapper {
          padding: 12px 16px;
          border-radius: 8px;
          box-shadow: 0 0 0 1px #e0e0e0 inset;
          
          &:hover {
            box-shadow: 0 0 0 1px #c0c0c0 inset;
          }
          
          &.is-focus {
            box-shadow: 0 0 0 2px var(--el-color-primary) inset !important;
          }
        }
        
        .el-input__inner {
          font-size: 15px;
        }
      }
      
      .login-btn {
        width: 100%;
        height: 48px;
        font-size: 16px;
        font-weight: 500;
        border-radius: 8px;
        margin-top: 12px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: none;
        
        &:hover {
          opacity: 0.9;
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        &:active {
          transform: translateY(0);
        }
      }
    }
    
    .form-footer {
      margin-top: 32px;
      text-align: center;
      font-size: 14px;
      color: #666;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 4px;
      
      .el-link {
        font-weight: 500;
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .login-container {
    flex-direction: column;
  }
  
  .login-left {
    flex: 0 0 auto;
    min-height: 40vh;
    padding: 40px 24px;
    
    .brand-content {
      .logo-icon {
        width: 60px;
        height: 60px;
        margin-bottom: 16px;
        
        svg {
          width: 36px;
          height: 36px;
        }
      }
      
      h1 {
        font-size: 36px;
        margin-bottom: 8px;
      }
      
      .tagline {
        font-size: 16px;
        margin-bottom: 24px;
      }
      
      .features {
        gap: 12px;
        
        .feature-item {
          padding: 12px;
          
          .feature-icon {
            font-size: 20px;
          }
          
          span:not(.feature-icon) {
            font-size: 14px;
          }
        }
      }
    }
  }
  
  .login-right {
    flex: 1;
    padding: 40px 24px;
    
    .form-content {
      .form-header {
        margin-bottom: 32px;
        
        h2 {
          font-size: 26px;
        }
        
        p {
          font-size: 14px;
        }
      }
    }
  }
}
</style>

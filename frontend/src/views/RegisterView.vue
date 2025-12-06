<template>
  <div class="register-container">
    <div class="register-wrapper">
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
          <div class="benefits">
            <div class="benefit-item">
              <div class="benefit-icon">✓</div>
              <div class="benefit-text">
                <h4>智能健康管理</h4>
                <p>AI 驱动的个性化健康建议</p>
              </div>
            </div>
            <div class="benefit-item">
              <div class="benefit-icon">✓</div>
              <div class="benefit-text">
                <h4>全方位数据追踪</h4>
                <p>体重、运动、饮食、睡眠一站管理</p>
              </div>
            </div>
            <div class="benefit-item">
              <div class="benefit-icon">✓</div>
              <div class="benefit-text">
                <h4>专业计划定制</h4>
                <p>减脂增肌计划科学制定</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 右侧注册表单区 -->
      <div class="form-section">
        <el-card class="register-card" shadow="never">
          <div class="card-header">
            <h2>创建账户</h2>
            <p>开启您的健康管理之旅</p>
          </div>
          
          <el-form
            ref="registerFormRef"
            :model="registerForm"
            :rules="registerRules"
            label-position="top"
            size="large"
          >
            <el-form-item label="邮箱地址" prop="email">
              <el-input
                v-model="registerForm.email"
                placeholder="请输入您的邮箱"
                prefix-icon="Message"
                clearable
              />
            </el-form-item>
            
            <el-form-item label="用户昵称" prop="nickname">
              <el-input
                v-model="registerForm.nickname"
                placeholder="请输入您的昵称"
                prefix-icon="User"
                clearable
              />
            </el-form-item>
            
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="设置密码" prop="password">
                  <el-input
                    v-model="registerForm.password"
                    type="password"
                    placeholder="设置登录密码"
                    prefix-icon="Lock"
                    show-password
                    clearable
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="确认密码" prop="confirmPassword">
                  <el-input
                    v-model="registerForm.confirmPassword"
                    type="password"
                    placeholder="再次输入密码"
                    prefix-icon="Lock"
                    show-password
                    clearable
                  />
                </el-form-item>
              </el-col>
            </el-row>
            
            <div class="password-tips">
              <p>密码要求：至少8位，包含大小写字母、数字和特殊字符</p>
            </div>
            
            <el-form-item>
              <el-button
                type="primary"
                :loading="loading"
                @click="handleRegister"
                class="register-btn"
              >
                {{ loading ? '注册中...' : '立即注册' }}
              </el-button>
            </el-form-item>
          </el-form>
          
          <div class="form-footer">
            <span>已有账号？</span>
            <el-link type="primary" @click="goToLogin" :underline="false">立即登录</el-link>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { registerAPI } from '@/api/auth'
import { ElMessage } from 'element-plus'

const router = useRouter()

const registerFormRef = ref(null)
const loading = ref(false)

const registerForm = reactive({
  email: '',
  nickname: '',
  password: '',
  confirmPassword: ''
})

const validatePassword = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请输入密码'))
  } else if (value.length < 8) {
    callback(new Error('密码至少8位'))
  } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/.test(value)) {
    callback(new Error('密码需包含大小写字母、数字和特殊字符'))
  } else {
    callback()
  }
}

const validateConfirmPassword = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const registerRules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 20, message: '昵称长度在2-20个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, validator: validatePassword, trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await registerAPI({
          email: registerForm.email,
          nickname: registerForm.nickname,
          password: registerForm.password
        })
        ElMessage.success('注册成功，请登录')
        router.push('/login')
      } catch (error) {
        console.error('注册失败:', error)
      } finally {
        loading.value = false
      }
    }
  })
}

const goToLogin = () => {
  router.push('/login')
}
</script>

<style scoped lang="scss">
.register-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.register-wrapper {
  display: flex;
  width: 100%;
  max-width: 1200px;
  min-height: 650px;
  background: #fff;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.brand-section {
  flex: 1;
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
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
    
    .benefits {
      text-align: left;
      
      .benefit-item {
        display: flex;
        align-items: flex-start;
        padding: 20px 0;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        
        &:last-child {
          border-bottom: none;
        }
        
        .benefit-icon {
          width: 28px;
          height: 28px;
          background: rgba(255, 255, 255, 0.2);
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 14px;
          margin-right: 16px;
          flex-shrink: 0;
        }
        
        .benefit-text {
          h4 {
            margin: 0 0 4px;
            font-size: 16px;
            font-weight: 600;
          }
          
          p {
            margin: 0;
            font-size: 14px;
            opacity: 0.8;
          }
        }
      }
    }
  }
}

.form-section {
  flex: 1.2;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
  background: #fff;
}

.register-card {
  width: 100%;
  max-width: 480px;
  border: none;
  
  :deep(.el-card__body) {
    padding: 0;
  }
  
  .card-header {
    text-align: center;
    margin-bottom: 32px;
    
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
    margin-bottom: 20px;
    
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
  
  .password-tips {
    margin-bottom: 24px;
    
    p {
      margin: 0;
      font-size: 13px;
      color: #9ca3af;
    }
  }
  
  .register-btn {
    width: 100%;
    height: 52px;
    font-size: 16px;
    font-weight: 600;
    border-radius: 12px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    
    &:hover {
      opacity: 0.9;
    }
  }
  
  .form-footer {
    text-align: center;
    margin-top: 28px;
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
  .register-wrapper {
    flex-direction: column;
    max-width: 540px;
  }
  
  .brand-section {
    padding: 40px;
    
    .brand-content {
      h1 {
        font-size: 36px;
      }
      
      .benefits {
        display: none;
      }
    }
  }
  
  .form-section {
    padding: 40px;
  }
  
  .register-card {
    :deep(.el-row) {
      flex-direction: column;
      
      .el-col {
        max-width: 100%;
        flex: 0 0 100%;
      }
    }
  }
}
</style>

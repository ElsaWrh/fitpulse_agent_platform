<template>
  <div class="profile-view">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1>个人设置</h1>
      <p>管理您的账户信息和个人偏好</p>
    </div>

    <div class="profile-content">
      <!-- 左侧头像卡片 -->
      <div class="avatar-section">
        <div class="avatar-card">
          <div class="avatar-wrapper">
            <el-avatar :size="120" class="user-avatar">
              {{ userStore.userInfo?.nickname?.charAt(0) || 'U' }}
            </el-avatar>
            <div class="avatar-overlay">
              <el-icon><Camera /></el-icon>
            </div>
          </div>
          <h3 class="user-name">{{ userStore.userInfo?.nickname || '未设置昵称' }}</h3>
          <p class="user-email">{{ userStore.userInfo?.email || '' }}</p>
          <div class="user-stats">
            <div class="stat-item">
              <span class="stat-value">15</span>
              <span class="stat-label">健康天数</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <span class="stat-value">23</span>
              <span class="stat-label">运动记录</span>
            </div>
          </div>
        </div>

        <!-- 账户安全 -->
        <div class="security-card">
          <h4>账户安全</h4>
          <div class="security-item">
            <div class="security-info">
              <el-icon><Lock /></el-icon>
              <span>登录密码</span>
            </div>
            <el-button text type="primary" size="small">修改</el-button>
          </div>
          <div class="security-item">
            <div class="security-info">
              <el-icon><Message /></el-icon>
              <span>邮箱验证</span>
            </div>
            <el-tag type="success" size="small">已验证</el-tag>
          </div>
        </div>
      </div>

      <!-- 右侧表单区域 -->
      <div class="form-section">
        <div class="form-card">
          <div class="card-header">
            <h3>基本信息</h3>
            <p>更新您的个人基本信息</p>
          </div>

          <el-form
            ref="profileFormRef"
            :model="profileForm"
            label-position="top"
            class="profile-form"
          >
            <div class="form-row">
              <el-form-item label="昵称" class="form-col">
                <el-input 
                  v-model="profileForm.nickname" 
                  placeholder="请输入昵称"
                  size="large"
                >
                  <template #prefix>
                    <el-icon><User /></el-icon>
                  </template>
                </el-input>
              </el-form-item>
              
              <el-form-item label="手机号" class="form-col">
                <el-input 
                  v-model="profileForm.phone" 
                  placeholder="请输入手机号"
                  size="large"
                >
                  <template #prefix>
                    <el-icon><Phone /></el-icon>
                  </template>
                </el-input>
              </el-form-item>
            </div>

            <div class="form-row">
              <el-form-item label="性别" class="form-col">
                <el-select 
                  v-model="profileForm.gender" 
                  placeholder="请选择性别"
                  size="large"
                  style="width: 100%"
                >
                  <el-option label="男" value="MALE" />
                  <el-option label="女" value="FEMALE" />
                  <el-option label="其他" value="OTHER" />
                </el-select>
              </el-form-item>
              
              <el-form-item label="生日" class="form-col">
                <el-date-picker
                  v-model="profileForm.birthday"
                  type="date"
                  placeholder="选择日期"
                  format="YYYY-MM-DD"
                  value-format="YYYY-MM-DD"
                  size="large"
                  style="width: 100%"
                />
              </el-form-item>
            </div>

            <el-form-item label="邮箱">
              <el-input 
                v-model="userStore.userInfo.email" 
                disabled 
                size="large"
              >
                <template #prefix>
                  <el-icon><Message /></el-icon>
                </template>
              </el-input>
              <div class="form-tip">邮箱作为登录账号，暂不支持修改</div>
            </el-form-item>

            <div class="form-actions">
              <el-button @click="handleReset" size="large">重置</el-button>
              <el-button type="primary" @click="handleUpdate" size="large" :loading="loading">
                保存修改
              </el-button>
            </div>
          </el-form>
        </div>

        <!-- 健康目标设置 -->
        <div class="form-card">
          <div class="card-header">
            <h3>健康目标</h3>
            <p>设置您的健康管理目标</p>
          </div>

          <div class="goals-grid">
            <div class="goal-item">
              <div class="goal-icon">
                <el-icon><ScaleToOriginal /></el-icon>
              </div>
              <div class="goal-content">
                <span class="goal-label">目标体重</span>
                <span class="goal-value">65 kg</span>
              </div>
              <el-button text type="primary" size="small">编辑</el-button>
            </div>
            
            <div class="goal-item">
              <div class="goal-icon">
                <el-icon><Timer /></el-icon>
              </div>
              <div class="goal-content">
                <span class="goal-label">每周运动</span>
                <span class="goal-value">3 次</span>
              </div>
              <el-button text type="primary" size="small">编辑</el-button>
            </div>
            
            <div class="goal-item">
              <div class="goal-icon">
                <el-icon><Aim /></el-icon>
              </div>
              <div class="goal-content">
                <span class="goal-label">每日步数</span>
                <span class="goal-value">8000 步</span>
              </div>
              <el-button text type="primary" size="small">编辑</el-button>
            </div>
          </div>
        </div>

        <!-- LLM 模型设置 -->
        <div class="form-card">
          <div class="card-header">
            <h3>🤖 AI 模型设置</h3>
            <p>配置大语言模型提供商和 API 密钥</p>
          </div>

          <el-alert
            title="提示"
            type="info"
            :closable="false"
            style="margin-bottom: 24px"
          >
            配置 API Key 后，智能体将使用您选择的模型进行对话。目前支持阿里云通义千问、OpenAI 等多个模型。
          </el-alert>

          <div class="llm-providers">
            <div 
              v-for="provider in llmProviders" 
              :key="provider.id"
              class="provider-card"
            >
              <div class="provider-header">
                <div class="provider-info">
                  <h4>{{ provider.name }}</h4>
                  <el-tag 
                    :type="provider.status === 'ENABLED' ? 'success' : 'info'" 
                    size="small"
                  >
                    {{ provider.status === 'ENABLED' ? '已启用' : '已禁用' }}
                  </el-tag>
                </div>
                <el-tag 
                  v-if="hasApiKey(provider)"
                  type="success" 
                  size="small"
                  effect="plain"
                >
                  已配置
                </el-tag>
                <el-tag 
                  v-else
                  type="warning" 
                  size="small"
                  effect="plain"
                >
                  未配置
                </el-tag>
              </div>

              <!-- 可用模型列表 -->
              <div class="provider-models">
                <div class="models-label">可用模型:</div>
                <div class="models-list">
                  <el-tag
                    v-for="model in getProviderModels(provider.id)"
                    :key="model.id"
                    :type="model.isDefault ? 'primary' : ''"
                    size="small"
                    style="margin-right: 8px; margin-bottom: 8px"
                  >
                    {{ model.displayName }}
                    <span v-if="model.isDefault"> (默认)</span>
                  </el-tag>
                </div>
              </div>

              <!-- API Key 配置 -->
              <div class="provider-config">
                <el-input
                  v-model="apiKeys[provider.id]"
                  type="password"
                  :placeholder="`请输入 ${provider.name} 的 API Key`"
                  show-password
                  size="large"
                >
                  <template #prepend>API Key</template>
                </el-input>
                <el-button 
                  type="primary" 
                  size="large"
                  :loading="savingProvider === provider.id"
                  @click="saveApiKey(provider.id)"
                >
                  保存
                </el-button>
              </div>

              <!-- 提供商说明 -->
              <div class="provider-tips">
                <template v-if="provider.providerType === 'DASHSCOPE'">
                  <p>💡 获取阿里云百炼 API Key：</p>
                  <p>1. 访问 <a href="https://dashscope.console.aliyun.com/" target="_blank">阿里云百炼控制台</a></p>
                  <p>2. 创建 API Key 并复制到上方输入框</p>
                </template>
                <template v-else-if="provider.providerType === 'OPENAI'">
                  <p>💡 获取 OpenAI API Key：</p>
                  <p>1. 访问 <a href="https://platform.openai.com/api-keys" target="_blank">OpenAI 控制台</a></p>
                  <p>2. 创建 API Key 并复制到上方输入框</p>
                </template>
              </div>
            </div>
          </div>

          <!-- 测试连接 -->
          <div class="llm-test">
            <el-button 
              type="success" 
              size="large"
              :loading="testingConnection"
              @click="testConnection"
            >
              <el-icon><Connection /></el-icon>
              测试连接
            </el-button>
            <span v-if="connectionTestResult" class="test-result">
              {{ connectionTestResult }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { updateUserProfileAPI } from '@/api/auth'
import { getLLMProviders, getLLMModels, updateProviderApiKey, testLLMConnection } from '@/api/llm'
import { ElMessage } from 'element-plus'
import { 
  Camera, 
  Lock, 
  Message, 
  User, 
  Phone, 
  ScaleToOriginal, 
  Timer, 
  Aim,
  Connection
} from '@element-plus/icons-vue'

const userStore = useUserStore()
const profileFormRef = ref(null)
const loading = ref(false)

const profileForm = reactive({
  nickname: '',
  gender: '',
  birthday: '',
  phone: ''
})

const originalForm = reactive({
  nickname: '',
  gender: '',
  birthday: '',
  phone: ''
})

// LLM 相关状态
const llmProviders = ref([])
const llmModels = ref([])
const apiKeys = reactive({})
const savingProvider = ref(null)
const testingConnection = ref(false)
const connectionTestResult = ref('')

// 加载数据
onMounted(async () => {
  if (userStore.userInfo) {
    const data = {
      nickname: userStore.userInfo.nickname || '',
      gender: userStore.userInfo.gender || '',
      birthday: userStore.userInfo.birthday || '',
      phone: userStore.userInfo.phone || ''
    }
    Object.assign(profileForm, data)
    Object.assign(originalForm, data)
  }
  
  // 加载 LLM 配置
  await loadLLMConfig()
})

// 加载 LLM 配置
const loadLLMConfig = async () => {
  try {
    const [providersRes, modelsRes] = await Promise.all([
      getLLMProviders(),
      getLLMModels()
    ])
    
    // request.js响应拦截器已经返回了res.data，直接使用
    llmProviders.value = Array.isArray(providersRes) ? providersRes : (providersRes?.data || providersRes || [])
    llmModels.value = Array.isArray(modelsRes) ? modelsRes : (modelsRes?.data || modelsRes || [])
    
    console.log('✅ 加载 LLM 提供商:', llmProviders.value)
    console.log('✅ 加载 LLM 模型:', llmModels.value)
    
    // 初始化 API Keys（显示为已配置状态）
    llmProviders.value.forEach(provider => {
      apiKeys[provider.id] = provider.apiKey || ''
    })
  } catch (error) {
    console.error('加载 LLM 配置失败:', error)
    ElMessage.error('加载 LLM 配置失败')
  }
}

// 获取提供商的模型列表
const getProviderModels = (providerId) => {
  return llmModels.value.filter(m => m.providerId === providerId)
}

// 判断是否已配置 API Key
const hasApiKey = (provider) => {
  return provider.apiKey && provider.apiKey !== '' && !provider.apiKey.includes('未配置')
}

// 保存 API Key
const saveApiKey = async (providerId) => {
  const apiKey = apiKeys[providerId]
  
  if (!apiKey || apiKey.trim() === '') {
    ElMessage.warning('请输入 API Key')
    return
  }
  
  try {
    savingProvider.value = providerId
    await updateProviderApiKey(providerId, apiKey.trim())
    ElMessage.success('API Key 保存成功')
    
    // 重新加载配置
    await loadLLMConfig()
  } catch (error) {
    console.error('保存 API Key 失败:', error)
    ElMessage.error(error.message || '保存失败')
  } finally {
    savingProvider.value = null
  }
}

// 测试连接
const testConnection = async () => {
  try {
    testingConnection.value = true
    connectionTestResult.value = ''
    
    const result = await testLLMConnection()
    connectionTestResult.value = result.data
    ElMessage.success('连接测试成功')
  } catch (error) {
    console.error('测试连接失败:', error)
    connectionTestResult.value = error.message || '连接测试失败'
    ElMessage.error(error.message || '连接测试失败')
  } finally {
    testingConnection.value = false
  }
}

const handleReset = () => {
  Object.assign(profileForm, originalForm)
}

const handleUpdate = async () => {
  try {
    loading.value = true
    const data = await updateUserProfileAPI(profileForm)
    userStore.userInfo = data
    Object.assign(originalForm, profileForm)
    ElMessage.success('更新成功')
  } catch (error) {
    console.error('更新失败:', error)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.profile-view {
  width: 100%;
  min-height: 100%;
}

.page-header {
  margin-bottom: 32px;
  
  h1 {
    font-size: 28px;
    font-weight: 700;
    color: #1a1a2e;
    margin: 0 0 8px;
  }
  
  p {
    font-size: 15px;
    color: #6b7280;
    margin: 0;
  }
}

.profile-content {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: 32px;
}

/* 左侧头像区域 */
.avatar-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.avatar-card {
  background: #fff;
  border-radius: 20px;
  padding: 40px 32px;
  text-align: center;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  
  .avatar-wrapper {
    position: relative;
    display: inline-block;
    margin-bottom: 20px;
    
    .user-avatar {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      font-size: 48px;
      font-weight: 600;
    }
    
    .avatar-overlay {
      position: absolute;
      bottom: 0;
      right: 0;
      width: 36px;
      height: 36px;
      background: #fff;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
      cursor: pointer;
      transition: all 0.3s;
      
      .el-icon {
        color: #667eea;
        font-size: 18px;
      }
      
      &:hover {
        background: #667eea;
        
        .el-icon {
          color: #fff;
        }
      }
    }
  }
  
  .user-name {
    font-size: 20px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 4px;
  }
  
  .user-email {
    font-size: 14px;
    color: #9ca3af;
    margin: 0 0 24px;
  }
  
  .user-stats {
    display: flex;
    justify-content: center;
    align-items: center;
    padding-top: 20px;
    border-top: 1px solid #f0f0f0;
    
    .stat-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 0 24px;
      
      .stat-value {
        font-size: 24px;
        font-weight: 700;
        color: #667eea;
      }
      
      .stat-label {
        font-size: 13px;
        color: #9ca3af;
        margin-top: 4px;
      }
    }
    
    .stat-divider {
      width: 1px;
      height: 40px;
      background: #f0f0f0;
    }
  }
}

.security-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  
  h4 {
    font-size: 16px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 16px;
  }
  
  .security-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 0;
    
    &:not(:last-child) {
      border-bottom: 1px solid #f0f0f0;
    }
    
    .security-info {
      display: flex;
      align-items: center;
      gap: 10px;
      
      .el-icon {
        color: #9ca3af;
        font-size: 18px;
      }
      
      span {
        font-size: 14px;
        color: #4b5563;
      }
    }
  }
}

/* 右侧表单区域 */
.form-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-card {
  background: #fff;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  
  .card-header {
    margin-bottom: 28px;
    
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #1a1a2e;
      margin: 0 0 6px;
    }
    
    p {
      font-size: 14px;
      color: #9ca3af;
      margin: 0;
    }
  }
}

.profile-form {
  .form-row {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
  }
  
  .form-col {
    margin-bottom: 0;
  }
  
  :deep(.el-form-item__label) {
    font-weight: 500;
    color: #374151;
    padding-bottom: 8px;
  }
  
  :deep(.el-input__wrapper) {
    padding: 4px 16px;
    border-radius: 10px;
  }
  
  .form-tip {
    font-size: 12px;
    color: #9ca3af;
    margin-top: 6px;
  }
  
  .form-actions {
    margin-top: 32px;
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    
    .el-button {
      min-width: 100px;
      border-radius: 10px;
    }
  }
}

/* 健康目标 */
.goals-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
  
  .goal-item {
    display: flex;
    align-items: center;
    padding: 16px;
    background: #f9fafb;
    border-radius: 12px;
    
    .goal-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      margin-right: 16px;
      
      .el-icon {
        font-size: 24px;
      }
    }
    
    .goal-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      
      .goal-label {
        font-size: 13px;
        color: #9ca3af;
      }
      
      .goal-value {
        font-size: 18px;
        font-weight: 600;
        color: #1a1a2e;
      }
    }
  }
}

/* LLM 模型设置 */
.llm-providers {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-bottom: 24px;
}

.provider-card {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 20px;
  background: #fafafa;
  
  .provider-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    
    .provider-info {
      display: flex;
      align-items: center;
      gap: 12px;
      
      h4 {
        font-size: 16px;
        font-weight: 600;
        color: #1a1a2e;
        margin: 0;
      }
    }
  }
  
  .provider-models {
    margin-bottom: 16px;
    padding: 12px;
    background: #fff;
    border-radius: 8px;
    
    .models-label {
      font-size: 13px;
      color: #6b7280;
      margin-bottom: 8px;
    }
    
    .models-list {
      display: flex;
      flex-wrap: wrap;
    }
  }
  
  .provider-config {
    display: flex;
    gap: 12px;
    margin-bottom: 12px;
    
    .el-input {
      flex: 1;
    }
  }
  
  .provider-tips {
    padding: 12px;
    background: #fffbeb;
    border-left: 3px solid #f59e0b;
    border-radius: 6px;
    font-size: 13px;
    color: #78350f;
    
    p {
      margin: 4px 0;
      line-height: 1.6;
    }
    
    a {
      color: #2563eb;
      text-decoration: none;
      
      &:hover {
        text-decoration: underline;
      }
    }
  }
}

.llm-test {
  display: flex;
  align-items: center;
  gap: 16px;
  padding-top: 20px;
  border-top: 1px solid #e5e7eb;
  
  .test-result {
    font-size: 14px;
    color: #059669;
    font-weight: 500;
  }
}

/* 响应式适配 */
@media (max-width: 1024px) {
  .profile-content {
    grid-template-columns: 1fr;
  }
  
  .avatar-section {
    flex-direction: row;
    
    .avatar-card,
    .security-card {
      flex: 1;
    }
  }
}

@media (max-width: 768px) {
  .avatar-section {
    flex-direction: column;
  }
  
  .profile-form .form-row {
    grid-template-columns: 1fr;
  }
  
  .provider-config {
    flex-direction: column;
  }
}
</style>

<template>
  <div class="agent-edit-page" v-loading="pageLoading">
    <!-- 顶部操作栏 -->
    <div class="page-toolbar">
      <el-button @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
      <div class="toolbar-right">
        <el-tag v-if="agentStatus" :type="agentStatus === 'ACTIVE' ? 'success' : 'info'">
          {{ agentStatus === 'ACTIVE' ? '已发布' : '草稿' }}
        </el-tag>
        <el-button type="primary" @click="saveAgent" :loading="saving">
          <el-icon><Check /></el-icon>
          保存
        </el-button>
      </div>
    </div>

    <!-- 三列布局 -->
    <div class="edit-layout">
      <!-- 左侧导航 -->
      <aside class="left-nav">
        <div
          v-for="section in navSections"
          :key="section.key"
          class="nav-item"
          :class="{ active: activeSection === section.key }"
          @click="scrollToSection(section.key)"
        >
          <el-icon>
            <component :is="section.icon" />
          </el-icon>
          <span>{{ section.label }}</span>
        </div>
      </aside>

      <!-- 中间编辑区 -->
      <main class="main-editor">
        <el-form ref="formRef" :model="formData" :rules="formRules" label-position="top">
          <!-- 基础信息 -->
          <el-card id="section-basic" class="edit-section" shadow="never">
            <template #header>
              <div class="section-header">
                <el-icon><InfoFilled /></el-icon>
                <span>基础信息</span>
              </div>
            </template>

            <el-form-item label="智能体名称" prop="name" required>
              <el-input
                v-model="formData.name"
                placeholder="请输入智能体名称,如:专业减脂教练"
                maxlength="100"
                show-word-limit
              />
            </el-form-item>

            <el-form-item label="头像">
              <el-upload
                class="avatar-uploader"
                :show-file-list="false"
                :before-upload="beforeAvatarUpload"
                :http-request="uploadAvatar"
              >
                <el-avatar v-if="formData.avatarUrl" :size="80" :src="formData.avatarUrl" />
                <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
              </el-upload>
              <div class="upload-tip">建议尺寸: 200x200 像素, 支持 JPG、PNG 格式</div>
            </el-form-item>

            <el-form-item label="简介">
              <el-input
                v-model="formData.description"
                type="textarea"
                :rows="3"
                placeholder="简要描述该智能体的功能和特点"
                maxlength="500"
                show-word-limit
              />
            </el-form-item>

            <el-form-item label="智能体类型" prop="category">
              <el-select v-model="formData.category" placeholder="请选择类型" style="width: 100%">
                <el-option label="减脂教练" value="FAT_LOSS_COACH" />
                <el-option label="增肌教练" value="MUSCLE_COACH" />
                <el-option label="营养顾问" value="NUTRITION_COACH" />
                <el-option label="睡眠顾问" value="SLEEP_COACH" />
                <el-option label="心血管顾问" value="CARDIOVASCULAR_COACH" />
                <el-option label="糖尿病顾问" value="DIABETES_COACH" />
                <el-option label="通用助手" value="GENERAL" />
              </el-select>
            </el-form-item>

            <el-form-item label="可见性">
              <el-radio-group v-model="formData.visibility">
                <el-radio value="PRIVATE">私有</el-radio>
                <el-radio value="PUBLIC">公开</el-radio>
              </el-radio-group>
              <div class="field-tip">公开后其他用户也可以使用该智能体</div>
            </el-form-item>
          </el-card>

          <!-- 角色与回复风格 -->
          <el-card id="section-personality" class="edit-section" shadow="never">
            <template #header>
              <div class="section-header">
                <el-icon><ChatDotRound /></el-icon>
                <span>角色与回复风格(人设)</span>
              </div>
            </template>

            <el-form-item label="系统提示词(System Prompt)">
              <el-input
                v-model="configData.systemPrompt"
                type="textarea"
                :rows="8"
                placeholder="定义智能体的角色、职责、回复风格等,例如:&#10;你是一名专业的减脂健身教练,名叫FitPulse教练......"
              />
              <div class="field-tip">
                这段文本将作为 AI 的系统级指令,影响智能体的回复风格和行为方式
              </div>
            </el-form-item>

            <el-form-item label="回复风格">
              <el-radio-group v-model="configData.languageStyle">
                <el-radio value="ENCOURAGING">鼓励型 - 积极正面,激励用户坚持</el-radio>
                <el-radio value="PROFESSIONAL">理性科普型 - 客观专业,注重数据</el-radio>
                <el-radio value="MEDICAL">严谨医学风格 - 医学术语,谨慎建议</el-radio>
                <el-radio value="CASUAL">轻松随和 - 亲切友好,生活化表达</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-card>

          <!-- 模型设置 -->
          <el-card id="section-model" class="edit-section" shadow="never">
            <template #header>
              <div class="section-header">
                <el-icon><Setting /></el-icon>
                <span>模型设置</span>
              </div>
            </template>

            <el-form-item label="LLM 模型">
              <el-select
                v-model="configData.llmModelId"
                placeholder="选择语言模型"
                style="width: 100%"
                @change="onModelChange"
              >
                <el-option
                  v-for="model in llmModels"
                  :key="model.id"
                  :label="model.displayName || model.modelName"
                  :value="model.id"
                >
                  <div class="model-option">
                    <span class="model-name">{{ model.displayName || model.modelName }}</span>
                    <el-tag v-if="model.isDefault" size="small" type="success">默认</el-tag>
                    <el-tag size="small" type="info">{{ model.modelType }}</el-tag>
                  </div>
                </el-option>
              </el-select>
              <div class="form-tip" v-if="llmModels.length === 0">
                暂无可用模型，请先在<router-link to="/profile">个人设置</router-link>中配置 LLM 提供商
              </div>
            </el-form-item>

            <div v-if="selectedModel" class="model-info">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item label="模型名称">{{ selectedModel.modelName }}</el-descriptions-item>
                <el-descriptions-item label="模型代码">{{ selectedModel.modelCode }}</el-descriptions-item>
                <el-descriptions-item label="最大Token">{{ selectedModel.maxTokens || '未设置' }}</el-descriptions-item>
                <el-descriptions-item label="状态">
                  <el-tag :type="selectedModel.isEnabled ? 'success' : 'info'" size="small">
                    {{ selectedModel.isEnabled ? '已启用' : '已禁用' }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item v-if="selectedModel.description" label="描述" :span="2">
                  {{ selectedModel.description }}
                </el-descriptions-item>
              </el-descriptions>
            </div>
          </el-card>

          <!-- 工具与权限 -->
          <el-card id="section-tools" class="edit-section" shadow="never">
            <template #header>
              <div class="section-header">
                <el-icon><Tools /></el-icon>
                <span>工具与权限</span>
              </div>
            </template>

            <el-form-item label="数据访问权限">
              <el-checkbox-group v-model="permissions">
                <el-checkbox value="read_profile">
                  读取用户健康档案(身高、体重、目标等)
                </el-checkbox>
                <el-checkbox value="read_logs">
                  读取训练记录和体重记录
                </el-checkbox>
                <el-checkbox value="write_plan">
                  创建或修改健康计划
                </el-checkbox>
              </el-checkbox-group>
            </el-form-item>
          </el-card>

          <!-- 知识库设置 -->
          <el-card id="section-knowledge" class="edit-section" shadow="never">
            <template #header>
              <div class="section-header">
                <el-icon><Reading /></el-icon>
                <span>知识库设置</span>
              </div>
            </template>

            <el-form-item label="绑定知识库分类">
              <div class="knowledge-selector">
                <div class="available-categories">
                  <div class="category-title">可用分类</div>
                  <el-checkbox-group v-model="selectedKBCategories">
                    <el-checkbox
                      v-for="category in kbCategories"
                      :key="category.id"
                      :value="category.id"
                    >
                      {{ category.name }}
                    </el-checkbox>
                  </el-checkbox-group>
                </div>
              </div>
              <div class="field-tip">
                选中的知识库内容将作为上下文提供给智能体,帮助其更准确地回答专业问题
              </div>
            </el-form-item>
          </el-card>

          <!-- 安全边界 -->
          <el-card id="section-safety" class="edit-section" shadow="never">
            <template #header>
              <div class="section-header">
                <el-icon><Lock /></el-icon>
                <span>安全边界与提示</span>
              </div>
            </template>

            <el-alert type="warning" :closable="false" style="margin-bottom: 16px">
              <template #title>
                <div style="line-height: 1.6;">
                  <strong>安全提示(自动附加到所有回复):</strong><br>
                  • 不提供疾病诊断和用药建议<br>
                  • 出现严重症状时必须提醒用户就医<br>
                  • 运动建议需考虑用户的健康状况和限制
                </div>
              </template>
            </el-alert>

            <el-form-item label="自定义安全提示">
              <el-input
                v-model="configData.customSafetyPrompt"
                type="textarea"
                :rows="4"
                placeholder="可以添加针对特定场景的额外安全提示,这段文字会附加到系统提示词尾部"
              />
            </el-form-item>
          </el-card>
        </el-form>
      </main>

      <!-- 右侧预览区 -->
      <aside class="right-preview">
        <div class="preview-header">
          <h3>{{ formData.name || '智能体预览' }}</h3>
          <el-tag v-if="agentStatus" :type="agentStatus === 'ACTIVE' ? 'success' : 'info'" size="small">
            {{ agentStatus === 'ACTIVE' ? '已发布' : '草稿' }}
          </el-tag>
        </div>

        <div class="chat-preview">
          <div class="chat-messages" ref="chatMessagesRef">
            <div v-for="msg in previewMessages" :key="msg.id" class="chat-message" :class="msg.role">
              <div class="message-content">{{ msg.content }}</div>
            </div>
          </div>

          <div class="chat-input">
            <el-input
              v-model="previewInput"
              placeholder="输入消息测试智能体..."
              @keyup.enter="sendPreviewMessage"
            >
              <template #append>
                <el-button @click="sendPreviewMessage" :loading="sendingPreview">
                  发送
                </el-button>
              </template>
            </el-input>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ArrowLeft,
  Check,
  InfoFilled,
  ChatDotRound,
  Setting,
  Tools,
  Reading,
  Lock,
  Plus
} from '@element-plus/icons-vue'
import {
  getAgentDetail,
  getAgentConfig,
  createAgent,
  updateAgent,
  updateAgentConfig
} from '@/api/agent'
import { getLLMModels } from '@/api/llm'
import { getKBCategories } from '@/api/knowledge'
import { sendMessageAPI } from '@/api/chat'

const route = useRoute()
const router = useRouter()

// 页面状态
const pageLoading = ref(false)
const saving = ref(false)
const sendingPreview = ref(false)
const formRef = ref()

// 是否是新建模式
const isNewAgent = computed(() => route.params.id === 'new')

// 智能体基础信息
const formData = reactive({
  name: '',
  avatarUrl: '',
  description: '',
  category: '',
  visibility: 'PRIVATE'
})

// 智能体配置
const configData = reactive({
  systemPrompt: '',
  languageStyle: 'ENCOURAGING',
  llmModelId: null,
  customSafetyPrompt: ''
})

// 权限数据
const permissions = ref([])
const selectedKBCategories = ref([])

// LLM 模型列表
const llmModels = ref([])
const selectedModel = computed(() => {
  return llmModels.value.find(m => m.id === configData.llmModelId)
})

// 知识库分类
const kbCategories = ref([])

// 智能体状态
const agentStatus = ref('')

// 左侧导航配置
const navSections = [
  { key: 'basic', label: '基础信息', icon: 'InfoFilled' },
  { key: 'personality', label: '人设与回复', icon: 'ChatDotRound' },
  { key: 'model', label: '模型设置', icon: 'Setting' },
  { key: 'tools', label: '工具权限', icon: 'Tools' },
  { key: 'knowledge', label: '知识库', icon: 'Reading' },
  { key: 'safety', label: '安全边界', icon: 'Lock' }
]

const activeSection = ref('basic')

// 表单验证规则
const formRules = {
  name: [
    { required: true, message: '请输入智能体名称', trigger: 'blur' }
  ],
  category: [
    { required: true, message: '请选择智能体类型', trigger: 'change' }
  ]
}

// 预览消息
const previewMessages = ref([
  {
    id: 1,
    role: 'assistant',
    content: '您好！我是您的智能助手，很高兴为您服务。有什么可以帮助您的吗？'
  }
])
const previewInput = ref('')
const chatMessagesRef = ref()

/**
 * 加载页面数据
 */
const loadPageData = async () => {
  pageLoading.value = true
  try {
    // 加载 LLM 模型列表
    const modelsRes = await getLLMModels()
    // request.js响应拦截器已经返回了res.data，所以modelsRes就是数组
    llmModels.value = Array.isArray(modelsRes) ? modelsRes : (modelsRes?.data || modelsRes || [])
    console.log('✅ 加载 LLM 模型列表:', llmModels.value)

    // 加载知识库分类
    const kbRes = await getKBCategories()
    kbCategories.value = Array.isArray(kbRes) ? kbRes : (kbRes?.data || kbRes || [])

    // 如果不是新建,加载智能体数据
    if (!isNewAgent.value) {
      await loadAgentData()
    } else {
      // 新建模式:设置默认值
      if (llmModels.value.length > 0) {
        configData.llmModelId = llmModels.value.find(m => m.isDefault)?.id || llmModels.value[0].id
        console.log('✅ 设置默认模型 ID:', configData.llmModelId)
      }
    }
  } catch (error) {
    console.error('❌ 加载页面数据失败:', error)
    ElMessage.error('加载页面数据失败: ' + (error.message || '未知错误'))
  } finally {
    pageLoading.value = false
  }
}

/**
 * 加载智能体数据
 */
const loadAgentData = async () => {
  try {
    // 加载基础信息
    // request.js 拦截器已经返回了 res.data，所以直接访问 agentRes
    const agent = await getAgentDetail(route.params.id)
    
    formData.name = agent.name
    formData.avatarUrl = agent.avatarUrl
    formData.description = agent.description
    formData.category = agent.category
    formData.visibility = agent.visibility
    agentStatus.value = agent.status

    // 从 Agent 对象获取核心配置
    configData.systemPrompt = agent.systemPrompt || ''
    configData.llmModelId = agent.llmModelId

    // 加载扩展配置信息（key-value 结构）
    const configs = await getAgentConfig(route.params.id)
    
    // 从配置列表中提取值
    const configMap = {}
    configs.forEach(item => {
      configMap[item.configKey] = item.configValue
    })

    configData.languageStyle = configMap.languageStyle || 'ENCOURAGING'
    configData.customSafetyPrompt = configMap.customSafetyPrompt || ''

    // 加载权限
    permissions.value = []
    if (configMap.canReadProfile === 'true') permissions.value.push('read_profile')
    if (configMap.canReadLogs === 'true') permissions.value.push('read_logs')
    if (configMap.canWritePlan === 'true') permissions.value.push('write_plan')

    // 加载知识库绑定
    const kbScope = configMap.kbScope ? JSON.parse(configMap.kbScope) : []
    selectedKBCategories.value = kbScope
  } catch (error) {
    console.error('加载智能体数据失败:', error)
    ElMessage.error('加载智能体数据失败')
  }
}

/**
 * 保存智能体
 */
const saveAgent = async () => {
  // 表单验证
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) {
    ElMessage.warning('请完善必填信息')
    return
  }

  saving.value = true
  try {
    let agentId = route.params.id

    if (isNewAgent.value) {
      // 创建新智能体
      const createRes = await createAgent(formData)
      // request.js 拦截器已经返回了 res.data，所以直接访问 createRes.id
      agentId = createRes.id
      ElMessage.success('智能体创建成功')
      
      // 创建后跳转到编辑页
      await router.replace(`/agents/${agentId}`)
    } else {
      // 更新基础信息
      await updateAgent(agentId, formData)
    }

    // 保存配置
    const configPayload = {
      systemPrompt: configData.systemPrompt,
      languageStyle: configData.languageStyle,
      llmModelId: configData.llmModelId,
      customSafetyPrompt: configData.customSafetyPrompt,
      canReadProfile: permissions.value.includes('read_profile'),
      canReadLogs: permissions.value.includes('read_logs'),
      canWritePlan: permissions.value.includes('write_plan'),
      kbScope: selectedKBCategories.value
    }

    await updateAgentConfig(agentId, configPayload)
    
    if (!isNewAgent.value) {
      ElMessage.success('保存成功')
    }
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

/**
 * 返回列表
 */
const goBack = () => {
  router.push('/agents')
}

/**
 * 滚动到指定区域
 */
const scrollToSection = (key) => {
  activeSection.value = key
  const element = document.getElementById(`section-${key}`)
  if (element) {
    element.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}

/**
 * 模型变化
 */
const onModelChange = () => {
  // 可以在这里添加模型切换时的逻辑
}

/**
 * 头像上传前验证
 */
const beforeAvatarUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

/**
 * 上传头像
 */
const uploadAvatar = async ({ file }) => {
  // TODO: 实现真实的文件上传逻辑
  // 这里先使用 base64 预览
  const reader = new FileReader()
  reader.onload = (e) => {
    formData.avatarUrl = e.target.result
  }
  reader.readAsDataURL(file)
}

/**
 * 发送预览消息
 */
const sendPreviewMessage = async () => {
  if (!previewInput.value.trim()) return

  const userMessage = {
    id: Date.now(),
    role: 'user',
    content: previewInput.value
  }

  previewMessages.value.push(userMessage)
  const inputText = previewInput.value
  previewInput.value = ''

  // 滚动到底部
  await nextTick()
  if (chatMessagesRef.value) {
    chatMessagesRef.value.scrollTop = chatMessagesRef.value.scrollHeight
  }

  // TODO: 调用实际的对话接口
  sendingPreview.value = true
  setTimeout(() => {
    previewMessages.value.push({
      id: Date.now(),
      role: 'assistant',
      content: `这是一条预览回复: "${inputText}"。实际回复将基于你配置的模型和提示词生成。`
    })
    sendingPreview.value = false

    nextTick(() => {
      if (chatMessagesRef.value) {
        chatMessagesRef.value.scrollTop = chatMessagesRef.value.scrollHeight
      }
    })
  }, 1000)
}

// 页面加载
onMounted(() => {
  loadPageData()
})
</script>

<style scoped lang="scss">
.agent-edit-page {
  min-height: 100vh;
  background: #f5f7fa;
}

.page-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: white;
  border-bottom: 1px solid #e4e7ed;
  position: sticky;
  top: 0;
  z-index: 100;

  .toolbar-right {
    display: flex;
    align-items: center;
    gap: 12px;
  }
}

.edit-layout {
  display: flex;
  gap: 20px;
  padding: 20px;
  width: 100%;
}

// 左侧导航
.left-nav {
  width: 200px;
  flex-shrink: 0;
  background: white;
  border-radius: 8px;
  padding: 12px 0;
  height: fit-content;
  position: sticky;
  top: 80px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

  .nav-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 20px;
    cursor: pointer;
    color: #606266;
    transition: all 0.3s;

    &:hover {
      background: #f5f7fa;
      color: #409eff;
    }

    &.active {
      background: #ecf5ff;
      color: #409eff;
      border-right: 3px solid #409eff;
    }

    .el-icon {
      font-size: 18px;
    }

    span {
      font-size: 14px;
    }
  }
}

// 中间编辑区
.main-editor {
  flex: 1;
  min-width: 0;

  .edit-section {
    margin-bottom: 20px;
    border-radius: 8px;

    :deep(.el-card__header) {
      background: #fafafa;
      border-bottom: 1px solid #e4e7ed;
    }

    .section-header {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: #303133;

      .el-icon {
        font-size: 20px;
        color: #409eff;
      }
    }
  }

  .avatar-uploader {
    :deep(.el-upload) {
      border: 2px dashed #d9d9d9;
      border-radius: 8px;
      cursor: pointer;
      position: relative;
      overflow: hidden;
      transition: all 0.3s;
      width: 80px;
      height: 80px;
      display: flex;
      align-items: center;
      justify-content: center;

      &:hover {
        border-color: #409eff;
      }
    }

    .avatar-uploader-icon {
      font-size: 32px;
      color: #8c939d;
    }
  }

  .upload-tip {
    margin-top: 8px;
    font-size: 12px;
    color: #909399;
  }

  .field-tip {
    margin-top: 8px;
    font-size: 12px;
    color: #909399;
    line-height: 1.5;
  }

  .model-option {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;

    .model-name {
      font-weight: 500;
      flex: 1;
    }
  }

  .model-info {
    margin-top: 16px;
    padding: 12px;
    background: #f5f7fa;
    border-radius: 6px;
  }
  
  .form-tip {
    margin-top: 8px;
    font-size: 13px;
    color: #909399;
    
    a {
      color: #409eff;
      text-decoration: none;
      
      &:hover {
        text-decoration: underline;
      }
    }
  }

  .knowledge-selector {
    .available-categories {
      padding: 16px;
      background: #fafafa;
      border-radius: 6px;

      .category-title {
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 12px;
        color: #606266;
      }

      :deep(.el-checkbox-group) {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
    }
  }
}

// 右侧预览区
.right-preview {
  width: 380px;
  flex-shrink: 0;
  background: white;
  border-radius: 8px;
  padding: 20px;
  height: fit-content;
  position: sticky;
  top: 80px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

  .preview-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    padding-bottom: 16px;
    border-bottom: 1px solid #e4e7ed;

    h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .chat-preview {
    .chat-messages {
      height: 400px;
      overflow-y: auto;
      padding: 16px;
      background: #f5f7fa;
      border-radius: 6px;
      margin-bottom: 16px;

      .chat-message {
        margin-bottom: 16px;

        &.user {
          display: flex;
          justify-content: flex-end;

          .message-content {
            background: #409eff;
            color: white;
            max-width: 70%;
            padding: 10px 14px;
            border-radius: 12px 12px 0 12px;
            line-height: 1.5;
          }
        }

        &.assistant {
          display: flex;
          justify-content: flex-start;

          .message-content {
            background: white;
            color: #303133;
            max-width: 70%;
            padding: 10px 14px;
            border-radius: 12px 12px 12px 0;
            line-height: 1.5;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.06);
          }
        }
      }
    }

    .chat-input {
      :deep(.el-input-group__append) {
        padding: 0;

        .el-button {
          margin: 0;
          border-radius: 0 4px 4px 0;
        }
      }
    }
  }
}

// 响应式
@media (max-width: 1400px) {
  .edit-layout {
    flex-direction: column;
  }

  .left-nav,
  .right-preview {
    width: 100%;
    position: static;
  }

  .left-nav {
    display: flex;
    overflow-x: auto;

    .nav-item {
      flex-shrink: 0;
      border-right: none;
      border-bottom: 3px solid transparent;

      &.active {
        border-right: none;
        border-bottom-color: #409eff;
      }
    }
  }
}
</style>

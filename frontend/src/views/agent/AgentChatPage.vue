<template>
  <div class="agent-chat-page">
    <div class="chat-container">
      <!-- 左侧对话历史 -->
      <div class="chat-sidebar">
        <div class="sidebar-header">
          <h3>对话历史</h3>
          <el-button type="primary" size="small" @click="handleNewChat">
            <el-icon><Plus /></el-icon>
            新对话
          </el-button>
        </div>
        
        <div class="conversation-list">
          <div 
            v-for="conv in conversations" 
            :key="conv.id"
            class="conversation-item"
            :class="{ active: currentConversation === conv.id }"
            @click="switchConversation(conv.id)"
          >
            <div class="conv-icon">
              <el-icon><ChatDotSquare /></el-icon>
            </div>
            <div class="conv-info">
              <span class="conv-title">{{ conv.title }}</span>
              <span class="conv-date">{{ conv.date }}</span>
            </div>
            <el-icon class="conv-delete" @click.stop="handleDeleteConv(conv.id)">
              <Delete />
            </el-icon>
          </div>
        </div>
      </div>

      <!-- 右侧聊天区域 -->
      <div class="chat-main">
        <!-- 智能体信息头部 -->
        <div class="chat-header">
          <div class="agent-info">
            <div class="agent-avatar" :style="{ background: agentConfig.iconColor }">
              {{ agentConfig.icon }}
            </div>
            <div class="agent-text">
              <div class="agent-name-row">
                <span class="agent-name">{{ agentConfig.name }}</span>
                <span class="agent-status">
                  <span class="status-dot"></span>
                  在线
                </span>
              </div>
              <span class="agent-description">{{ agentConfig.description }}</span>
            </div>
          </div>
          <div class="header-actions">
            <el-tooltip content="返回智能体中心">
              <el-button :icon="ArrowLeft" circle @click="backToAgentCenter" />
            </el-tooltip>
            <el-tooltip content="清空对话">
              <el-button :icon="Delete" circle @click="handleClearChat" />
            </el-tooltip>
          </div>
        </div>

        <!-- 消息列表 -->
        <div class="messages-container" ref="messagesContainer">
          <!-- 欢迎消息 -->
          <div class="welcome-message" v-if="messages.length === 0">
            <div class="welcome-icon" :style="{ background: agentConfig.iconColor }">
              <span class="welcome-emoji">{{ agentConfig.icon }}</span>
            </div>
            <h2>您好，我是{{ agentConfig.name }}</h2>
            <p>{{ agentConfig.welcomeText }}</p>
            
            <!-- 快捷问题按钮 -->
            <div class="suggestion-cards">
              <div 
                v-for="(q, idx) in agentConfig.quickQuestions" 
                :key="idx"
                class="suggestion-card" 
                @click="handleQuickQuestion(q.text)"
              >
                <span class="suggestion-icon">{{ q.icon }}</span>
                <span class="suggestion-text">{{ q.text }}</span>
              </div>
            </div>
          </div>

          <!-- 消息列表 -->
          <div 
            v-for="(msg, idx) in messages" 
            :key="idx"
            class="message-item"
            :class="msg.role"
          >
            <div class="message-avatar">
              <el-avatar v-if="msg.role === 'user'" :size="40">
                {{ userStore.userInfo?.nickname?.charAt(0) || 'U' }}
              </el-avatar>
              <div v-else class="ai-avatar" :style="{ background: agentConfig.iconColor }">
                {{ agentConfig.icon }}
              </div>
            </div>
            <div class="message-content">
              <div class="message-bubble">
                <div class="message-text">{{ msg.content }}</div>
              </div>
              <span class="message-time">{{ msg.time }}</span>
            </div>
          </div>

          <!-- AI 正在输入 -->
          <div class="message-item assistant" v-if="isTyping">
            <div class="message-avatar">
              <div class="ai-avatar" :style="{ background: agentConfig.iconColor }">
                {{ agentConfig.icon }}
              </div>
            </div>
            <div class="message-content">
              <div class="message-bubble typing">
                <span class="typing-dot"></span>
                <span class="typing-dot"></span>
                <span class="typing-dot"></span>
              </div>
            </div>
          </div>
        </div>

        <!-- 输入区域 -->
        <div class="input-area">
          <div class="input-wrapper">
            <el-input
              v-model="inputMessage"
              type="textarea"
              :rows="1"
              :autosize="{ minRows: 1, maxRows: 4 }"
              :placeholder="`向 ${agentConfig.name} 提问...`"
              @keydown.enter.exact.prevent="handleSend"
            />
            <el-button 
              type="primary" 
              :icon="Promotion" 
              circle 
              class="send-btn"
              :disabled="!inputMessage.trim() || isTyping"
              @click="handleSend"
            />
          </div>
          <p class="input-tip">按 Enter 发送消息，Shift + Enter 换行</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Plus, 
  ChatDotSquare, 
  Delete, 
  Promotion,
  ArrowLeft
} from '@element-plus/icons-vue'
import {
  createConversationAPI,
  getConversationListAPI,
  deleteConversationAPI,
  sendMessageAPI,
  getMessageHistoryAPI
} from '@/api/chat'
import { getAgentById } from '@/api/agent'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const messagesContainer = ref(null)
const inputMessage = ref('')
const isTyping = ref(false)
const loading = ref(false)
const messages = ref([])
const conversations = ref([])
const currentConversation = ref(null)
const currentAgent = ref(null)

// 图标颜色映射
const iconColors = {
  'HEALTH_COACH': 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  'NUTRITION_COACH': 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  'SLEEP_COACH': 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  'FITNESS_COACH': 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  'default': 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)'
}

// 当前智能体配置（从后端获取）
const agentConfig = computed(() => {
  if (!currentAgent.value) {
    return {
      name: '加载中...',
      description: '',
      icon: '🤖',
      iconColor: iconColors.default,
      welcomeText: '正在加载智能体配置...',
      quickQuestions: []
    }
  }

  const agent = currentAgent.value
  return {
    id: agent.id,
    name: agent.name,
    description: agent.description || '',
    icon: agent.avatarUrl || '🤖',
    iconColor: iconColors[agent.category] || iconColors.default,
    welcomeText: agent.welcomeMessage || `您好！我是${agent.name}，很高兴为您服务。`,
    quickQuestions: parseQuickQuestions(agent)
  }
})

/**
 * 解析快捷问题
 */
const parseQuickQuestions = (agent) => {
  // 可以从 agent.permissions 或其他字段解析
  // 这里提供一个通用的默认问题
  return [
    { icon: '💬', text: '你能帮我做什么？' },
    { icon: '📋', text: '给我一些建议' },
    { icon: '❓', text: '如何开始？' }
  ]
}

/**
 * 新建对话
 */
const handleNewChat = async () => {
  try {
    const agentId = route.params.agentId
    if (!agentId) {
      ElMessage.error('智能体 ID 不能为空')
      return
    }
    const res = await createConversationAPI({
      agentId: parseInt(agentId),
      title: `与${agentConfig.value.name}的对话`
    })
    
    // request.js 拦截器在 code=0 时直接返回 data 部分
    if (res && res.id) {
      currentConversation.value = res.id
      messages.value = []
      await loadConversations()
      ElMessage.success('已创建新对话')
    }
  } catch (error) {
    console.error('创建对话失败:', error)
    ElMessage.error('创建对话失败')
  }
}

/**
 * 加载对话列表
 */
const loadConversations = async () => {
  try {
    const agentId = route.params.agentId
    if (!agentId) return
    
    const res = await getConversationListAPI({
      current: 1,
      size: 50,
      agentId: parseInt(agentId)
    })
    
    // request.js 拦截器在 code=0 时直接返回 data 部分
    if (res) {
      conversations.value = (res.records || []).map(conv => ({
        id: conv.id,
        title: conv.title || '新对话',
        date: formatDate(conv.createdAt)
      }))
    }
  } catch (error) {
    console.error('加载对话列表失败:', error)
  }
}

/**
 * 加载对话消息
 */
const loadMessages = async (conversationId) => {
  if (!conversationId) return
  
  try {
    loading.value = true
    const res = await getMessageHistoryAPI({
      conversationId,
      limit: 100
    })
    
    // request.js 拦截器在 code=0 时直接返回 data 部分
    if (res && Array.isArray(res)) {
      messages.value = res.map(msg => ({
        role: msg.role,
        content: msg.content,
        time: formatTime(msg.createdAt)
      }))
      scrollToBottom()
    }
  } catch (error) {
    console.error('加载消息失败:', error)
  } finally {
    loading.value = false
  }
}

/**
 * 格式化日期
 */
const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' })
}

/**
 * 格式化时间
 */
const formatTime = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

/**
 * 切换对话
 */
const switchConversation = async (convId) => {
  currentConversation.value = convId
  await loadMessages(convId)
}

/**
 * 删除对话
 */
const handleDeleteConv = async (convId) => {
  try {
    await ElMessageBox.confirm('确定要删除这条对话吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await deleteConversationAPI(convId)
    // 删除成功（如果失败会抛出异常）
    conversations.value = conversations.value.filter(c => c.id !== convId)
    if (currentConversation.value === convId) {
      currentConversation.value = null
      messages.value = []
    }
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除对话失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

/**
 * 清空对话
 */
const handleClearChat = () => {
  if (messages.value.length === 0) {
    ElMessage.warning('当前对话为空')
    return
  }
  
  ElMessageBox.confirm('确定要清空当前对话吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    messages.value = []
    ElMessage.success('已清空对话')
  }).catch(() => {})
}

/**
 * 返回智能体中心
 */
const backToAgentCenter = () => {
  router.push('/agents')
}

/**
 * 快捷问题点击
 */
const handleQuickQuestion = (question) => {
  inputMessage.value = question
  handleSend()
}

/**
 * 发送消息
 */
const handleSend = async () => {
  if (!inputMessage.value.trim() || isTyping.value) return
  
  const userMessage = inputMessage.value.trim()
  inputMessage.value = ''
  
  // 添加用户消息
  messages.value.push({
    role: 'user',
    content: userMessage,
    time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  })
  
  scrollToBottom()
  
  // 调用后端 AI 接口
  isTyping.value = true
  
  try {
    const agentId = route.params.agentId || 'health_assistant'
    
    // 构建历史消息（最近10条）
    const history = messages.value.slice(-10).map(msg => ({
      role: msg.role,
      content: msg.content
    }))
    
    const res = await sendMessageAPI({
      agentId: agentId,
      conversationId: currentConversation.value,
      message: userMessage,
      history: history
    })
    
    // request.js 拦截器在 code=0 时直接返回 data 部分
    if (res && res.response) {
      // 更新会话ID（可能是新创建的）
      if (res.conversationId && !currentConversation.value) {
        currentConversation.value = res.conversationId
        // 仅在会话列表为空时刷新，避免页面跳转
        if (conversations.value.length === 0) {
          await loadConversations()
        }
      }
      
      // 添加 AI 回复
      messages.value.push({
        role: 'assistant',
        content: res.response,
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
      })
    } else {
      throw new Error('请求失败')
    }
    
    scrollToBottom()
  } catch (error) {
    console.error('发送消息失败:', error)
    console.error('错误详情:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status
    })
    
    // 根据错误类型显示不同消息
    let errorMsg = '发送失败，请重试'
    if (error.response) {
      errorMsg = error.response.data?.message || `服务器错误 (${error.response.status})`
    } else if (error.request) {
      errorMsg = '网络连接失败，请检查网络'
    }
    
    ElMessage.error(errorMsg)
    // 移除用户消息
    messages.value.pop()
  } finally {
    isTyping.value = false
  }
}

/**
 * 滚动到底部
 */
const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

/**
 * 加载智能体信息
 */
const loadAgentInfo = async () => {
  try {
    const agentId = route.params.agentId
    if (!agentId) {
      ElMessage.error('智能体 ID 不能为空')
      router.push('/agents')
      return
    }
    
    const agent = await getAgentById(parseInt(agentId))
    currentAgent.value = agent
  } catch (error) {
    console.error('加载智能体信息失败:', error)
    ElMessage.error('加载智能体信息失败: ' + (error.message || '未知错误'))
    router.push('/agents')
  }
}

onMounted(async () => {
  // 先加载智能体信息
  await loadAgentInfo()
  // 加载当前智能体的对话历史
  await loadConversations()
})

// 监听路由变化，切换智能体时重新加载
watch(() => route.params.agentId, async (newAgentId) => {
  if (newAgentId) {
    messages.value = []
    currentConversation.value = null
    await loadAgentInfo()
    await loadConversations()
  }
})
</script>

<style scoped lang="scss">
.agent-chat-page {
  height: 100%;
  background: #f5f7fa;
}

.chat-container {
  display: flex;
  height: 100%;
  width: 100%;
  background: white;
}

// 左侧边栏
.chat-sidebar {
  width: 280px;
  border-right: 1px solid #e4e7ed;
  display: flex;
  flex-direction: column;
  background: #fafafa;
  
  .sidebar-header {
    padding: 20px;
    border-bottom: 1px solid #e4e7ed;
    
    h3 {
      margin: 0 0 12px;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
    }
    
    .el-button {
      width: 100%;
    }
  }
  
  .conversation-list {
    flex: 1;
    overflow-y: auto;
    padding: 8px;
    
    .conversation-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s;
      margin-bottom: 4px;
      
      &:hover {
        background: #f0f2f5;
        
        .conv-delete {
          opacity: 1;
        }
      }
      
      &.active {
        background: #ecf5ff;
        border-left: 3px solid #409eff;
      }
      
      .conv-icon {
        font-size: 20px;
        color: #909399;
      }
      
      .conv-info {
        flex: 1;
        min-width: 0;
        
        .conv-title {
          display: block;
          font-size: 14px;
          font-weight: 500;
          color: #303133;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
        
        .conv-date {
          display: block;
          font-size: 12px;
          color: #909399;
          margin-top: 2px;
        }
      }
      
      .conv-delete {
        opacity: 0;
        color: #f56c6c;
        transition: opacity 0.2s;
        
        &:hover {
          color: #ff4d4f;
        }
      }
    }
  }
}

// 右侧聊天区
.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 1px solid #e4e7ed;
  background: white;
  
  .agent-info {
    display: flex;
    align-items: center;
    gap: 16px;
    
    .agent-avatar {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 28px;
      flex-shrink: 0;
    }
    
    .agent-text {
      .agent-name-row {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 4px;
        
        .agent-name {
          font-size: 18px;
          font-weight: 600;
          color: #303133;
        }
        
        .agent-status {
          display: flex;
          align-items: center;
          gap: 6px;
          font-size: 12px;
          color: #67c23a;
          
          .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #67c23a;
            animation: pulse 2s infinite;
          }
        }
      }
      
      .agent-description {
        font-size: 13px;
        color: #909399;
      }
    }
  }
  
  .header-actions {
    display: flex;
    gap: 8px;
  }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  background: #f5f7fa;
}

.welcome-message {
  text-align: center;
  padding: 60px 20px;
  
  .welcome-icon {
    width: 100px;
    height: 100px;
    margin: 0 auto 24px;
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    
    .welcome-emoji {
      font-size: 56px;
    }
  }
  
  h2 {
    font-size: 24px;
    font-weight: 600;
    color: #303133;
    margin: 0 0 12px;
  }
  
  p {
    font-size: 14px;
    color: #606266;
    margin: 0 0 32px;
  }
  
  .suggestion-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 16px;
    max-width: 800px;
    margin: 0 auto;
    
    .suggestion-card {
      padding: 16px;
      background: white;
      border: 1px solid #e4e7ed;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      gap: 12px;
      
      &:hover {
        border-color: #409eff;
        box-shadow: 0 2px 12px rgba(64, 158, 255, 0.1);
        transform: translateY(-2px);
      }
      
      .suggestion-icon {
        font-size: 24px;
      }
      
      .suggestion-text {
        flex: 1;
        font-size: 14px;
        color: #606266;
        text-align: left;
      }
    }
  }
}

.message-item {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  
  &.user {
    flex-direction: row-reverse;
    
    .message-bubble {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    
    .message-time {
      text-align: right;
    }
  }
  
  .message-avatar {
    flex-shrink: 0;
    
    .ai-avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 20px;
    }
  }
  
  .message-content {
    max-width: 70%;
    
    .message-bubble {
      padding: 12px 16px;
      border-radius: 12px;
      background: white;
      color: #303133;
      line-height: 1.6;
      word-wrap: break-word;
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
      
      .message-text {
        white-space: pre-wrap; /* 保留换行符和空格 */
        word-break: break-word; /* 英文单词换行 */
      }
      
      &.typing {
        display: flex;
        gap: 6px;
        padding: 16px 20px;
        
        .typing-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: #909399;
          animation: typing 1.4s infinite;
          
          &:nth-child(2) {
            animation-delay: 0.2s;
          }
          
          &:nth-child(3) {
            animation-delay: 0.4s;
          }
        }
      }
    }
    
    .message-time {
      display: block;
      margin-top: 6px;
      font-size: 12px;
      color: #909399;
    }
  }
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.7;
  }
  30% {
    transform: translateY(-10px);
    opacity: 1;
  }
}

.input-area {
  padding: 16px 24px;
  border-top: 1px solid #e4e7ed;
  background: white;
  
  .input-wrapper {
    display: flex;
    gap: 12px;
    align-items: flex-end;
    
    .el-textarea {
      flex: 1;
    }
    
    .send-btn {
      flex-shrink: 0;
    }
  }
  
  .input-tip {
    margin: 8px 0 0;
    font-size: 12px;
    color: #909399;
  }
}
</style>

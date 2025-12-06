<template>
  <div class="chat-view">
    <div class="chat-container">
      <!-- 左侧对话列表 -->
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
            @click="currentConversation = conv.id"
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

        <!-- 快捷提问 -->
        <div class="quick-questions">
          <h4>快捷提问</h4>
          <div class="question-tags">
            <el-tag 
              v-for="(q, idx) in quickQuestions" 
              :key="idx"
              @click="handleQuickQuestion(q)"
              class="question-tag"
            >
              {{ q }}
            </el-tag>
          </div>
        </div>
      </div>

      <!-- 右侧聊天区域 -->
      <div class="chat-main">
        <!-- 聊天头部 -->
        <div class="chat-header">
          <div class="assistant-info">
            <div class="assistant-avatar">
              <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z" fill="currentColor"/>
              </svg>
            </div>
            <div class="assistant-text">
              <span class="assistant-name">FitPulse AI 健康助手</span>
              <span class="assistant-status">
                <span class="status-dot"></span>
                在线
              </span>
            </div>
          </div>
          <div class="header-actions">
            <el-tooltip content="清空对话">
              <el-button :icon="Delete" circle @click="handleClearChat" />
            </el-tooltip>
          </div>
        </div>

        <!-- 消息列表 -->
        <div class="messages-container" ref="messagesContainer">
          <!-- 欢迎消息 -->
          <div class="welcome-message" v-if="messages.length === 0">
            <div class="welcome-icon">
              <svg viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="40" cy="40" r="36" fill="url(#gradient1)"/>
                <path d="M40 20 L40 60 M20 40 L60 40" stroke="white" stroke-width="4" stroke-linecap="round"/>
                <circle cx="40" cy="40" r="20" stroke="white" stroke-width="3" fill="none"/>
                <defs>
                  <linearGradient id="gradient1" x1="0" y1="0" x2="80" y2="80">
                    <stop offset="0%" stop-color="#667eea"/>
                    <stop offset="100%" stop-color="#764ba2"/>
                  </linearGradient>
                </defs>
              </svg>
            </div>
            <h2>您好，我是您的 AI 健康助手</h2>
            <p>我可以帮助您解答健康相关问题、制定运动计划、提供饮食建议等。</p>
            <div class="suggestion-cards">
              <div class="suggestion-card" @click="handleQuickQuestion('如何制定一个适合初学者的健身计划？')">
                <el-icon><Medal /></el-icon>
                <span>制定健身计划</span>
              </div>
              <div class="suggestion-card" @click="handleQuickQuestion('健康饮食应该注意哪些方面？')">
                <el-icon><Apple /></el-icon>
                <span>健康饮食建议</span>
              </div>
              <div class="suggestion-card" @click="handleQuickQuestion('如何改善睡眠质量？')">
                <el-icon><Moon /></el-icon>
                <span>改善睡眠质量</span>
              </div>
              <div class="suggestion-card" @click="handleQuickQuestion('办公室久坐如何保持健康？')">
                <el-icon><OfficeBuilding /></el-icon>
                <span>办公健康指南</span>
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
              <div v-else class="ai-avatar">
                <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z" fill="currentColor"/>
                </svg>
              </div>
            </div>
            <div class="message-content">
              <div class="message-bubble">
                {{ msg.content }}
              </div>
              <span class="message-time">{{ msg.time }}</span>
            </div>
          </div>

          <!-- AI 正在输入 -->
          <div class="message-item assistant" v-if="isTyping">
            <div class="message-avatar">
              <div class="ai-avatar">
                <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z" fill="currentColor"/>
                </svg>
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
              placeholder="输入您的健康问题..."
              @keydown.enter.exact.prevent="handleSend"
            />
            <el-button 
              type="primary" 
              :icon="Promotion" 
              circle 
              class="send-btn"
              :disabled="!inputMessage.trim()"
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
import { ref, nextTick } from 'vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { 
  Plus, 
  ChatDotSquare, 
  Delete, 
  Promotion,
  Medal,
  Apple,
  Moon,
  OfficeBuilding
} from '@element-plus/icons-vue'

const userStore = useUserStore()
const messagesContainer = ref(null)

const inputMessage = ref('')
const isTyping = ref(false)
const currentConversation = ref(1)

// 对话历史
const conversations = ref([
  { id: 1, title: '健身计划咨询', date: '今天' },
  { id: 2, title: '饮食营养建议', date: '昨天' },
  { id: 3, title: '睡眠质量改善', date: '12月03日' },
])

// 消息列表
const messages = ref([])

// 快捷提问
const quickQuestions = ref([
  '如何减脂增肌？',
  '每天喝多少水？',
  'BMI 怎么计算？',
  '跑步注意事项',
])

const handleNewChat = () => {
  messages.value = []
  ElMessage.success('已创建新对话')
}

const handleDeleteConv = (id) => {
  conversations.value = conversations.value.filter(c => c.id !== id)
  ElMessage.success('对话已删除')
}

const handleClearChat = () => {
  messages.value = []
}

const handleQuickQuestion = (question) => {
  inputMessage.value = question
  handleSend()
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

const getCurrentTime = () => {
  const now = new Date()
  return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
}

const handleSend = async () => {
  if (!inputMessage.value.trim()) return
  
  const userMessage = inputMessage.value.trim()
  inputMessage.value = ''
  
  // 添加用户消息
  messages.value.push({
    role: 'user',
    content: userMessage,
    time: getCurrentTime()
  })
  
  scrollToBottom()
  
  // 模拟 AI 回复
  isTyping.value = true
  scrollToBottom()
  
  setTimeout(() => {
    isTyping.value = false
    messages.value.push({
      role: 'assistant',
      content: getAIResponse(userMessage),
      time: getCurrentTime()
    })
    scrollToBottom()
  }, 1500)
}

// 模拟 AI 回复（后续接入真实 API）
const getAIResponse = (question) => {
  const responses = {
    '如何减脂增肌？': '减脂增肌需要科学的训练和饮食配合：\n\n1. 训练方面：建议每周进行3-4次力量训练，配合2-3次有氧运动。力量训练以复合动作为主，如深蹲、硬拉、卧推等。\n\n2. 饮食方面：保证每天摄入足够蛋白质（每公斤体重1.6-2.2克），控制总热量摄入略低于消耗。\n\n3. 休息恢复：保证每天7-8小时睡眠，训练日之间给肌肉足够恢复时间。',
    '每天喝多少水？': '成年人每天建议饮水量为2000-2500ml，具体因人而异：\n\n• 体重因素：每公斤体重约30-35ml\n• 运动量：运动后需额外补充500-1000ml\n• 气候环境：高温环境需增加饮水量\n• 饮食因素：水果蔬菜摄入多可适当减少\n\n建议少量多次饮用，不要等口渴再喝。',
    default: '感谢您的提问！作为您的 AI 健康助手，我会尽力为您提供专业的健康建议。\n\n您的问题涉及到健康管理的重要方面，建议您：\n1. 保持规律的作息时间\n2. 适当进行体育锻炼\n3. 注意均衡饮食\n4. 定期进行健康检查\n\n如需更详细的个性化建议，欢迎继续向我咨询！'
  }
  
  return responses[question] || responses.default
}
</script>

<style scoped lang="scss">
.chat-view {
  width: 100%;
  height: calc(100vh - 64px - 48px);
  min-height: 500px;
}

.chat-container {
  display: flex;
  height: 100%;
  background: #fff;
  border-radius: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

/* 左侧边栏 */
.chat-sidebar {
  width: 280px;
  background: #f9fafb;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  
  .sidebar-header {
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #e5e7eb;
    
    h3 {
      font-size: 16px;
      font-weight: 600;
      color: #1a1a2e;
      margin: 0;
    }
  }
}

.conversation-list {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  
  .conversation-item {
    display: flex;
    align-items: center;
    padding: 12px;
    border-radius: 10px;
    cursor: pointer;
    margin-bottom: 4px;
    transition: all 0.2s;
    
    &:hover {
      background: #e5e7eb;
      
      .conv-delete {
        opacity: 1;
      }
    }
    
    &.active {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      
      .conv-icon,
      .conv-title,
      .conv-date {
        color: #fff;
      }
    }
    
    .conv-icon {
      color: #9ca3af;
      font-size: 18px;
      margin-right: 12px;
    }
    
    .conv-info {
      flex: 1;
      min-width: 0;
      
      .conv-title {
        display: block;
        font-size: 14px;
        font-weight: 500;
        color: #1a1a2e;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      
      .conv-date {
        font-size: 12px;
        color: #9ca3af;
      }
    }
    
    .conv-delete {
      color: #9ca3af;
      opacity: 0;
      transition: all 0.2s;
      
      &:hover {
        color: #ef4444;
      }
    }
  }
}

.quick-questions {
  padding: 16px 20px;
  border-top: 1px solid #e5e7eb;
  
  h4 {
    font-size: 13px;
    color: #6b7280;
    margin: 0 0 12px;
    font-weight: 500;
  }
  
  .question-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    
    .question-tag {
      cursor: pointer;
      border-radius: 16px;
      
      &:hover {
        background: #667eea;
        border-color: #667eea;
        color: #fff;
      }
    }
  }
}

/* 右侧聊天区域 */
.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.chat-header {
  padding: 16px 24px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .assistant-info {
    display: flex;
    align-items: center;
    
    .assistant-avatar {
      width: 44px;
      height: 44px;
      border-radius: 12px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 12px;
      
      svg {
        width: 26px;
        height: 26px;
        color: #fff;
      }
    }
    
    .assistant-text {
      display: flex;
      flex-direction: column;
      
      .assistant-name {
        font-size: 16px;
        font-weight: 600;
        color: #1a1a2e;
      }
      
      .assistant-status {
        font-size: 13px;
        color: #10b981;
        display: flex;
        align-items: center;
        gap: 6px;
        
        .status-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: #10b981;
        }
      }
    }
  }
}

/* 消息容器 */
.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

/* 欢迎消息 */
.welcome-message {
  text-align: center;
  padding: 60px 40px;
  
  .welcome-icon {
    margin-bottom: 24px;
    
    svg {
      width: 80px;
      height: 80px;
    }
  }
  
  h2 {
    font-size: 24px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 12px;
  }
  
  p {
    font-size: 15px;
    color: #6b7280;
    margin: 0 0 32px;
  }
  
  .suggestion-cards {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    max-width: 480px;
    margin: 0 auto;
    
    .suggestion-card {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 16px 20px;
      background: #f9fafb;
      border-radius: 12px;
      cursor: pointer;
      transition: all 0.3s;
      
      &:hover {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;
        transform: translateY(-2px);
        
        .el-icon {
          color: #fff;
        }
      }
      
      .el-icon {
        font-size: 24px;
        color: #667eea;
      }
      
      span {
        font-size: 14px;
        font-weight: 500;
      }
    }
  }
}

/* 消息项 */
.message-item {
  display: flex;
  margin-bottom: 20px;
  
  &.user {
    flex-direction: row-reverse;
    
    .message-content {
      align-items: flex-end;
    }
    
    .message-bubble {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      border-radius: 18px 18px 4px 18px;
    }
    
    .message-avatar {
      margin-left: 12px;
      margin-right: 0;
      
      .el-avatar {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;
        font-weight: 600;
      }
    }
  }
  
  &.assistant {
    .message-bubble {
      background: #f3f4f6;
      color: #1a1a2e;
      border-radius: 18px 18px 18px 4px;
    }
  }
  
  .message-avatar {
    margin-right: 12px;
    flex-shrink: 0;
    
    .ai-avatar {
      width: 40px;
      height: 40px;
      border-radius: 12px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      
      svg {
        width: 24px;
        height: 24px;
        color: #fff;
      }
    }
  }
  
  .message-content {
    display: flex;
    flex-direction: column;
    max-width: 70%;
    
    .message-bubble {
      padding: 14px 18px;
      font-size: 14px;
      line-height: 1.6;
      white-space: pre-wrap;
      word-break: break-word;
      
      &.typing {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 16px 24px;
        
        .typing-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: #9ca3af;
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
      font-size: 12px;
      color: #9ca3af;
      margin-top: 6px;
    }
  }
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.6;
  }
  30% {
    transform: translateY(-6px);
    opacity: 1;
  }
}

/* 输入区域 */
.input-area {
  padding: 16px 24px 20px;
  border-top: 1px solid #e5e7eb;
  
  .input-wrapper {
    display: flex;
    align-items: flex-end;
    gap: 12px;
    background: #f3f4f6;
    border-radius: 16px;
    padding: 12px 16px;
    
    :deep(.el-textarea__inner) {
      background: transparent;
      border: none;
      box-shadow: none;
      resize: none;
      font-size: 14px;
      line-height: 1.5;
      padding: 0;
      
      &::placeholder {
        color: #9ca3af;
      }
    }
    
    .send-btn {
      flex-shrink: 0;
      width: 40px;
      height: 40px;
    }
  }
  
  .input-tip {
    font-size: 12px;
    color: #9ca3af;
    margin: 8px 0 0;
    text-align: center;
  }
}

/* 响应式适配 */
@media (max-width: 968px) {
  .chat-sidebar {
    width: 240px;
  }
}

@media (max-width: 768px) {
  .chat-sidebar {
    display: none;
  }
  
  .welcome-message .suggestion-cards {
    grid-template-columns: 1fr;
  }
}
</style>

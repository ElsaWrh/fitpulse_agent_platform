/**
 * 聊天状态管理
 */
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useChatStore = defineStore('chat', () => {
  // 当前对话 ID
  const currentConversationId = ref(null)
  
  // 对话列表
  const conversationList = ref([])
  
  // 消息列表
  const messageList = ref([])
  
  // 设置当前对话
  const setCurrentConversation = (id) => {
    currentConversationId.value = id
  }
  
  // 清空当前对话
  const clearCurrentConversation = () => {
    currentConversationId.value = null
    messageList.value = []
  }
  
  // 添加消息
  const addMessage = (message) => {
    messageList.value.push(message)
  }
  
  // 清空状态
  const clearChatState = () => {
    currentConversationId.value = null
    conversationList.value = []
    messageList.value = []
  }

  return {
    currentConversationId,
    conversationList,
    messageList,
    setCurrentConversation,
    clearCurrentConversation,
    addMessage,
    clearChatState
  }
})

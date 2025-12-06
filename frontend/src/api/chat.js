/**
 * 聊天相关 API
 */
import request from '@/utils/request'

/**
 * 创建对话
 * @param {Object} data - { agentId: number, title?: string }
 */
export const createConversationAPI = (data) => {
  return request({
    method: 'POST',
    url: '/conversation/create',
    data
  })
}

/**
 * 获取对话列表
 * @param {Object} params - { current: number, size: number }
 */
export const getConversationListAPI = (params) => {
  return request({
    method: 'GET',
    url: '/conversation/list',
    params
  })
}

/**
 * 删除对话
 * @param {number} id - 对话 ID
 */
export const deleteConversationAPI = (id) => {
  return request({
    method: 'DELETE',
    url: `/conversation/${id}`
  })
}

/**
 * 发送消息
 * @param {Object} data - { conversationId: number, content: string, images?: string[] }
 */
export const sendMessageAPI = (data) => {
  return request({
    method: 'POST',
    url: '/message/send',
    data
  })
}

/**
 * 获取消息历史
 * @param {Object} params - { conversationId: number, current: number, size: number }
 */
export const getMessageHistoryAPI = (params) => {
  return request({
    method: 'GET',
    url: '/message/history',
    params
  })
}

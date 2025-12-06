/**
 * 智能体相关 API
 */
import request from '@/utils/request'

/**
 * 获取智能体列表
 */
export const getAgentListAPI = () => {
  return request({
    method: 'GET',
    url: '/agent/list'
  })
}

/**
 * 获取智能体详情
 * @param {number} id - 智能体 ID
 */
export const getAgentDetailAPI = (id) => {
  return request({
    method: 'GET',
    url: `/agent/${id}`
  })
}

/**
 * 智能体相关 API
 */
import request from '@/utils/request'

/**
 * 获取智能体列表
 * @param {Object} params - 查询参数
 * @param {string} params.category - 智能体分类
 * @param {string} params.visibility - 可见性
 */
export const getAgents = (params) => {
  return request({
    method: 'GET',
    url: '/agents',
    params
  })
}

/**
 * 获取智能体详情
 * @param {string|number} id - 智能体ID
 */
export const getAgentDetail = (id) => {
  return request({
    method: 'GET',
    url: `/agents/${id}`
  })
}

/**
 * 创建智能体
 * @param {Object} data - 智能体数据
 */
export const createAgent = (data) => {
  return request({
    method: 'POST',
    url: '/agents',
    data
  })
}

/**
 * 更新智能体基础信息
 * @param {string|number} id - 智能体ID
 * @param {Object} data - 更新数据
 */
export const updateAgent = (id, data) => {
  return request({
    method: 'PUT',
    url: `/agents/${id}`,
    data
  })
}

/**
 * 删除智能体
 * @param {string|number} id - 智能体ID
 */
export const deleteAgent = (id) => {
  return request({
    method: 'DELETE',
    url: `/agents/${id}`
  })
}

/**
 * 获取智能体配置
 * @param {string|number} id - 智能体ID
 */
export const getAgentConfig = (id) => {
  return request({
    method: 'GET',
    url: `/agents/${id}/config`
  })
}

/**
 * 更新智能体配置
 * @param {string|number} id - 智能体ID
 * @param {Object} data - 配置数据
 */
export const updateAgentConfig = (id, data) => {
  return request({
    method: 'PUT',
    url: `/agents/${id}/config`,
    data
  })
}

/**
 * 获取 LLM 模型列表
 */
export const getLLMModels = () => {
  return request({
    method: 'GET',
    url: '/llm/models'
  })
}

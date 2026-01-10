import request from '@/utils/request'

// ==================== 用户管理 API ====================

// 获取用户列表（分页）
export const getUserListAPI = (params) => {
  return request({
    url: '/v1/admin/users',
    method: 'GET',
    params
  })
}

// 获取用户详情
export const getUserDetailAPI = (userId) => {
  return request({
    url: `/v1/admin/users/${userId}`,
    method: 'GET'
  })
}

// 创建用户
export const createUserAPI = (data) => {
  return request({
    url: '/v1/admin/users',
    method: 'POST',
    data
  })
}

// 更新用户
export const updateUserAPI = (userId, data) => {
  return request({
    url: `/v1/admin/users/${userId}`,
    method: 'PUT',
    data
  })
}

// 软删除用户
export const deleteUserAPI = (userId) => {
  return request({
    url: `/v1/admin/users/${userId}`,
    method: 'DELETE'
  })
}

// 恢复已删除用户
export const restoreUserAPI = (userId) => {
  return request({
    url: `/v1/admin/users/${userId}/restore`,
    method: 'PUT'
  })
}

// 禁用用户
export const disableUserAPI = (userId) => {
  return request({
    url: `/v1/admin/users/${userId}/disable`,
    method: 'PUT'
  })
}

// 启用用户
export const enableUserAPI = (userId) => {
  return request({
    url: `/v1/admin/users/${userId}/enable`,
    method: 'PUT'
  })
}

// ==================== 智能体管理 API ====================

// 获取所有智能体列表（管理员）
export const getAllAgentsAPI = (params) => {
  return request({
    url: '/v1/admin/agents',
    method: 'GET',
    params
  })
}

// 删除智能体（管理员）
export const deleteAgentAPI = (agentId) => {
  return request({
    url: `/v1/admin/agents/${agentId}`,
    method: 'DELETE'
  })
}

// 启用/禁用智能体
export const toggleAgentStatusAPI = (agentId, status) => {
  return request({
    url: `/v1/admin/agents/${agentId}/status`,
    method: 'PUT',
    data: { status }
  })
}

// ==================== 知识库管理 API ====================

// 获取所有知识库列表（管理员）
export const getAllKnowledgeAPI = (params) => {
  return request({
    url: '/v1/admin/knowledge',
    method: 'GET',
    params
  })
}

// 创建知识库
export const createKnowledgeAPI = (data) => {
  return request({
    url: '/v1/admin/knowledge',
    method: 'POST',
    data
  })
}

// 更新知识库
export const updateKnowledgeAPI = (kbId, data) => {
  return request({
    url: `/v1/admin/knowledge/${kbId}`,
    method: 'PUT',
    data
  })
}

// 删除知识库
export const deleteKnowledgeAPI = (kbId) => {
  return request({
    url: `/v1/admin/knowledge/${kbId}`,
    method: 'DELETE'
  })
}

// ==================== 系统统计 API ====================

// 获取系统统计信息
export const getSystemStatsAPI = () => {
  return request({
    url: '/v1/admin/stats',
    method: 'GET'
  })
}

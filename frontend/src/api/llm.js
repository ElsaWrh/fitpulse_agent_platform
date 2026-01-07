import request from '@/utils/request'

/**
 * 获取所有LLM提供商列表
 */
export const getLLMProviders = () => {
  return request({
    method: 'GET',
    url: '/llm/providers'
  })
}

/**
 * 获取所有启用的LLM模型列表
 */
export const getLLMModels = () => {
  return request({
    method: 'GET',
    url: '/llm/models'
  })
}

/**
 * 获取指定模型详情
 */
export const getLLMModel = (id) => {
  return request({
    method: 'GET',
    url: `/llm/models/${id}`
  })
}

/**
 * 更新LLM提供商的API Key
 */
export const updateProviderApiKey = (providerId, apiKey) => {
  return request({
    method: 'POST',
    url: `/llm/providers/${providerId}/api-key`,
    data: { apiKey }
  })
}

/**
 * 测试LLM连接
 */
export const testLLMConnection = () => {
  return request({
    method: 'POST',
    url: '/llm/test-connection'
  })
}

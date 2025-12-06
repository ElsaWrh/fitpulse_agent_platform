/**
 * 健康计划相关 API
 */
import request from '@/utils/request'

/**
 * 生成健康计划
 * @param {Object} data - { days: number, goal?: string }
 */
export const generatePlanAPI = (data) => {
  return request({
    method: 'POST',
    url: '/plan/generate',
    data
  })
}

/**
 * 获取计划列表
 * @param {Object} params - { current: number, size: number }
 */
export const getPlanListAPI = (params) => {
  return request({
    method: 'GET',
    url: '/plan/list',
    params
  })
}

/**
 * 获取计划详情
 * @param {number} id - 计划 ID
 */
export const getPlanDetailAPI = (id) => {
  return request({
    method: 'GET',
    url: `/plan/${id}`
  })
}

/**
 * 删除计划
 * @param {number} id - 计划 ID
 */
export const deletePlanAPI = (id) => {
  return request({
    method: 'DELETE',
    url: `/plan/${id}`
  })
}

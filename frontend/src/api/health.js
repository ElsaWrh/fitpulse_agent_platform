import request from '@/utils/request'

// ========== 健康档案 ==========

// 获取健康档案
export const getHealthProfileAPI = () => {
  return request({
    url: '/health/profile',
    method: 'GET'
  })
}

// 创建健康档案
export const createHealthProfileAPI = (data) => {
  return request({
    url: '/health/profile',
    method: 'POST',
    data
  })
}

// 更新健康档案
export const updateHealthProfileAPI = (data) => {
  return request({
    url: '/health/profile',
    method: 'PUT',
    data
  })
}

// ========== 体重记录 ==========

// 获取体重记录列表
export const getWeightLogsAPI = (params) => {
  return request({
    url: '/health/weight',
    method: 'GET',
    params
  })
}

// 获取最新体重记录
export const getLatestWeightAPI = () => {
  return request({
    url: '/health/weight/latest',
    method: 'GET'
  })
}

// 添加体重记录
export const addWeightLogAPI = (data) => {
  return request({
    url: '/health/weight',
    method: 'POST',
    data
  })
}

// 删除体重记录
export const deleteWeightLogAPI = (id) => {
  return request({
    url: `/health/weight/${id}`,
    method: 'DELETE'
  })
}

// ========== 运动记录 ==========

// 获取运动记录列表
export const getWorkoutLogsAPI = (params) => {
  return request({
    url: '/health/workout',
    method: 'GET',
    params
  })
}

// 获取本周运动统计
export const getWeeklySummaryAPI = () => {
  return request({
    url: '/health/workout/weekly-summary',
    method: 'GET'
  })
}

// 添加运动记录
export const addWorkoutLogAPI = (data) => {
  return request({
    url: '/health/workout',
    method: 'POST',
    data
  })
}

// 删除运动记录
export const deleteWorkoutLogAPI = (id) => {
  return request({
    url: `/health/workout/${id}`,
    method: 'DELETE'
  })
}

// ========== 睡眠记录 ==========

// 获取睡眠记录
export const getSleepLogsAPI = (params) => {
  return request({
    url: '/health/sleeps',
    method: 'GET',
    params
  })
}

// 添加睡眠记录
export const addSleepLogAPI = (data) => {
  return request({
    url: '/health/sleeps',
    method: 'POST',
    data
  })
}

// ========== 饮食记录 ==========

// 获取饮食记录
export const getDietLogsAPI = (params) => {
  return request({
    url: '/health/diets',
    method: 'GET',
    params
  })
}

// 添加饮食记录
export const addDietLogAPI = (data) => {
  return request({
    url: '/health/diets',
    method: 'POST',
    data
  })
}

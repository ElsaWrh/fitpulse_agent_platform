import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getHealthProfileAPI } from '@/api/health'

export const useHealthStore = defineStore('health', () => {
  // 状态
  const healthProfile = ref(null)
  const weightLogs = ref([])
  const workoutLogs = ref([])
  const sleepLogs = ref([])
  const dietLogs = ref([])
  
  // 获取健康档案
  const getHealthProfile = async () => {
    try {
      const data = await getHealthProfileAPI()
      healthProfile.value = data
      return data
    } catch (error) {
      console.error('获取健康档案失败:', error)
      throw error
    }
  }
  
  // 清空数据
  const clearData = () => {
    healthProfile.value = null
    weightLogs.value = []
    workoutLogs.value = []
    sleepLogs.value = []
    dietLogs.value = []
  }
  
  return {
    healthProfile,
    weightLogs,
    workoutLogs,
    sleepLogs,
    dietLogs,
    getHealthProfile,
    clearData
  }
})

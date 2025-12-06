import { defineStore } from 'pinia'
import { ref } from 'vue'
import { loginAPI, getCurrentUserAPI } from '@/api/auth'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(null)
  
  // 登录
  const login = async (loginData) => {
    try {
      const data = await loginAPI(loginData)
      token.value = data.token
      userInfo.value = data.user
      localStorage.setItem('token', data.token)
      ElMessage.success('登录成功')
      return data
    } catch (error) {
      console.error('登录失败:', error)
      throw error
    }
  }
  
  // 获取用户信息
  const getUserInfo = async () => {
    try {
      const data = await getCurrentUserAPI()
      userInfo.value = data
      return data
    } catch (error) {
      console.error('获取用户信息失败:', error)
      throw error
    }
  }
  
  // 退出登录
  const logout = () => {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
    ElMessage.success('已退出登录')
  }
  
  return {
    token,
    userInfo,
    login,
    getUserInfo,
    logout
  }
})

import { defineStore } from 'pinia'
import { ref } from 'vue'
import { loginAPI, getCurrentUserAPI } from '@/api/auth'
import { getMenusAPI, getPermissionsAPI } from '@/api/rbac'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(null)
  const menus = ref([])
  const permissions = ref([])
  
  // 登录
  const login = async (loginData) => {
    try {
      const data = await loginAPI(loginData)
      token.value = data.token
      userInfo.value = data.user
      localStorage.setItem('token', data.token)
      
      // 登录成功后加载菜单和权限
      await loadMenusAndPermissions()
      
      ElMessage.success('登录成功')
      return data
    } catch (error) {
      console.error('登录失败:', error)
      throw error
    }
  }
  
  // 加载菜单和权限
  const loadMenusAndPermissions = async () => {
    try {
      const [menusData, permsData] = await Promise.all([
        getMenusAPI(),
        getPermissionsAPI()
      ])
      menus.value = menusData
      permissions.value = permsData
    } catch (error) {
      console.error('加载菜单权限失败:', error)
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
  
  // 检查是否有权限
  const hasPermission = (permissionCode) => {
    return permissions.value.some(p => p.permissionCode === permissionCode)
  }
  
  // 退出登录
  const logout = () => {
    token.value = ''
    userInfo.value = null
    menus.value = []
    permissions.value = []
    localStorage.removeItem('token')
    ElMessage.success('已退出登录')
  }
  
  return {
    token,
    user: userInfo,
    userInfo,
    menus,
    permissions,
    login,
    getUserInfo,
    loadMenusAndPermissions,
    hasPermission,
    logout
  }
})

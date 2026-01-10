import request from '@/utils/request'

// 用户注册
export const registerAPI = (data) => {
  return request({
    url: '/v1/auth/register',
    method: 'POST',
    data
  })
}

// 用户登录
export const loginAPI = (data) => {
  return request({
    url: '/v1/auth/login',
    method: 'POST',
    data
  })
}

// 获取当前用户信息
export const getCurrentUserAPI = () => {
  return request({
    url: '/v1/auth/me',
    method: 'GET'
  })
}

// 获取用户资料
export const getUserProfileAPI = () => {
  return request({
    url: '/users/me',
    method: 'GET'
  })
}

// 更新用户资料
export const updateUserProfileAPI = (data) => {
  return request({
    url: '/users/me',
    method: 'PUT',
    data
  })
}

/**
 * 本地存储工具函数
 */

const PREFIX = 'fitpulse_'

/**
 * 设置 localStorage
 * @param {string} key - 键
 * @param {any} value - 值
 */
export const setLocal = (key, value) => {
  try {
    localStorage.setItem(PREFIX + key, JSON.stringify(value))
  } catch (error) {
    console.error('setLocal error:', error)
  }
}

/**
 * 获取 localStorage
 * @param {string} key - 键
 */
export const getLocal = (key) => {
  try {
    const value = localStorage.getItem(PREFIX + key)
    return value ? JSON.parse(value) : null
  } catch (error) {
    console.error('getLocal error:', error)
    return null
  }
}

/**
 * 移除 localStorage
 * @param {string} key - 键
 */
export const removeLocal = (key) => {
  try {
    localStorage.removeItem(PREFIX + key)
  } catch (error) {
    console.error('removeLocal error:', error)
  }
}

/**
 * 清空 localStorage
 */
export const clearLocal = () => {
  try {
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith(PREFIX)) {
        localStorage.removeItem(key)
      }
    })
  } catch (error) {
    console.error('clearLocal error:', error)
  }
}

/**
 * 设置 sessionStorage
 * @param {string} key - 键
 * @param {any} value - 值
 */
export const setSession = (key, value) => {
  try {
    sessionStorage.setItem(PREFIX + key, JSON.stringify(value))
  } catch (error) {
    console.error('setSession error:', error)
  }
}

/**
 * 获取 sessionStorage
 * @param {string} key - 键
 */
export const getSession = (key) => {
  try {
    const value = sessionStorage.getItem(PREFIX + key)
    return value ? JSON.parse(value) : null
  } catch (error) {
    console.error('getSession error:', error)
    return null
  }
}

/**
 * 移除 sessionStorage
 * @param {string} key - 键
 */
export const removeSession = (key) => {
  try {
    sessionStorage.removeItem(PREFIX + key)
  } catch (error) {
    console.error('removeSession error:', error)
  }
}

/**
 * 清空 sessionStorage
 */
export const clearSession = () => {
  try {
    Object.keys(sessionStorage).forEach(key => {
      if (key.startsWith(PREFIX)) {
        sessionStorage.removeItem(key)
      }
    })
  } catch (error) {
    console.error('clearSession error:', error)
  }
}

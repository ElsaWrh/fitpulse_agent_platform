/**
 * 格式化工具函数
 */
import dayjs from 'dayjs'

/**
 * 格式化日期时间
 * @param {string|Date} date - 日期
 * @param {string} format - 格式化模板
 */
export const formatDateTime = (date, format = 'YYYY-MM-DD HH:mm:ss') => {
  if (!date) return ''
  return dayjs(date).format(format)
}

/**
 * 格式化日期
 * @param {string|Date} date - 日期
 */
export const formatDate = (date) => {
  return formatDateTime(date, 'YYYY-MM-DD')
}

/**
 * 格式化时间
 * @param {string|Date} date - 日期
 */
export const formatTime = (date) => {
  return formatDateTime(date, 'HH:mm:ss')
}

/**
 * 计算 BMI
 * @param {number} weight - 体重(kg)
 * @param {number} height - 身高(cm)
 */
export const calculateBMI = (weight, height) => {
  if (!weight || !height) return 0
  const heightInMeters = height / 100
  return (weight / (heightInMeters * heightInMeters)).toFixed(1)
}

/**
 * 获取 BMI 状态
 * @param {number} bmi - BMI 值
 */
export const getBMIStatus = (bmi) => {
  if (bmi < 18.5) return '偏瘦'
  if (bmi < 24) return '正常'
  if (bmi < 28) return '偏胖'
  return '肥胖'
}

/**
 * 格式化文件大小
 * @param {number} bytes - 字节数
 */
export const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return (bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i]
}

/**
 * 格式化数字(千分位)
 * @param {number} num - 数字
 */
export const formatNumber = (num) => {
  if (!num) return '0'
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

/**
 * 表单验证工具函数
 */

/**
 * 验证邮箱
 * @param {string} email - 邮箱地址
 */
export const isEmail = (email) => {
  const reg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  return reg.test(email)
}

/**
 * 验证手机号
 * @param {string} phone - 手机号
 */
export const isPhone = (phone) => {
  const reg = /^1[3-9]\d{9}$/
  return reg.test(phone)
}

/**
 * 验证密码强度(8-20位,包含大小写字母、数字、特殊字符)
 * @param {string} password - 密码
 */
export const isStrongPassword = (password) => {
  const reg = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$/
  return reg.test(password)
}

/**
 * 验证 URL
 * @param {string} url - URL 地址
 */
export const isURL = (url) => {
  const reg = /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$/
  return reg.test(url)
}

/**
 * 验证身份证号
 * @param {string} idCard - 身份证号
 */
export const isIdCard = (idCard) => {
  const reg = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/
  return reg.test(idCard)
}

/**
 * 验证整数
 * @param {string|number} num - 数字
 */
export const isInteger = (num) => {
  const reg = /^-?\d+$/
  return reg.test(num)
}

/**
 * 验证正整数
 * @param {string|number} num - 数字
 */
export const isPositiveInteger = (num) => {
  const reg = /^\d+$/
  return reg.test(num)
}

/**
 * 验证浮点数
 * @param {string|number} num - 数字
 */
export const isFloat = (num) => {
  const reg = /^-?\d+(\.\d+)?$/
  return reg.test(num)
}

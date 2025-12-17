import request from '@/utils/request'

/**
 * 上传饮食图片并识别
 */
export function uploadDietImage(formData) {
  return request({
    url: '/diet/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

/**
 * 添加饮食记录
 */
export function addDietLog(data) {
  return request({
    url: '/diet',
    method: 'post',
    data
  })
}

/**
 * 获取饮食记录列表
 */
export function getDietLogs(params) {
  return request({
    url: '/diet',
    method: 'get',
    params
  })
}

/**
 * 获取今日饮食记录
 */
export function getTodayDietLogs() {
  return request({
    url: '/diet/today',
    method: 'get'
  })
}

/**
 * 删除饮食记录
 */
export function deleteDietLog(id) {
  return request({
    url: `/diet/${id}`,
    method: 'delete'
  })
}

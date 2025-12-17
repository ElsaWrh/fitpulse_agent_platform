import request from '@/utils/request'

/**
 * 获取知识库分类列表
 */
export function getKBCategories() {
  return request({
    url: '/kb/categories',
    method: 'get'
  })
}

/**
 * 获取知识条目列表
 * @param {Object} params - 查询参数
 * @param {string} params.categoryId - 分类ID
 * @param {string} params.keyword - 搜索关键词
 */
export function getKBArticles(params) {
  return request({
    url: '/kb/articles',
    method: 'get',
    params
  })
}

/**
 * 创建知识条目
 * @param {Object} data - 条目数据
 */
export function createKBArticle(data) {
  return request({
    url: '/kb/articles',
    method: 'post',
    data
  })
}

/**
 * 更新知识条目
 * @param {string|number} id - 条目ID
 * @param {Object} data - 更新数据
 */
export function updateKBArticle(id, data) {
  return request({
    url: `/kb/articles/${id}`,
    method: 'put',
    data
  })
}

/**
 * 删除知识条目
 * @param {string|number} id - 条目ID
 */
export function deleteKBArticle(id) {
  return request({
    url: `/kb/articles/${id}`,
    method: 'delete'
  })
}

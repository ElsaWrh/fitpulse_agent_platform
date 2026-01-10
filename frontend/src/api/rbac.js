import request from '@/utils/request'

// 获取用户菜单列表
export const getMenusAPI = () => {
  return request({
    url: '/rbac/menus',
    method: 'GET'
  })
}

// 获取用户权限列表
export const getPermissionsAPI = () => {
  return request({
    url: '/rbac/permissions',
    method: 'GET'
  })
}

// 测试管理员操作（需要ROLE_ADMIN角色）
export const testAdminAPI = () => {
  return request({
    url: '/rbac/admin/test',
    method: 'POST'
  })
}

// 测试删除用户（需要user:delete权限）
export const testDeleteUserAPI = () => {
  return request({
    url: '/rbac/admin/delete-user',
    method: 'DELETE'
  })
}

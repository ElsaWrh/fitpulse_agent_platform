package com.example.backend.service;

import com.example.backend.vo.MenuVO;
import com.example.backend.vo.PermissionVO;

import java.util.List;

/**
 * RBAC权限服务接口
 */
public interface RbacService {

    /**
     * 获取用户的菜单列表（树形结构）
     */
    List<MenuVO> getUserMenus(Long userId);

    /**
     * 获取用户的权限列表
     */
    List<PermissionVO> getUserPermissions(Long userId);

    /**
     * 检查用户是否有指定权限
     */
    boolean hasPermission(Long userId, String permissionCode);

    /**
     * 检查用户是否有指定角色
     */
    boolean hasRole(Long userId, String roleCode);
}

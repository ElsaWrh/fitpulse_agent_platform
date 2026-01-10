package com.example.backend.service.impl;

import com.example.backend.entity.Menu;
import com.example.backend.entity.Permission;
import com.example.backend.entity.Role;
import com.example.backend.mapper.MenuMapper;
import com.example.backend.mapper.PermissionMapper;
import com.example.backend.mapper.RoleMapper;
import com.example.backend.service.RbacService;
import com.example.backend.vo.MenuVO;
import com.example.backend.vo.PermissionVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * RBAC权限服务实现
 */
@Service
@RequiredArgsConstructor
public class RbacServiceImpl implements RbacService {

    private final MenuMapper menuMapper;
    private final PermissionMapper permissionMapper;
    private final RoleMapper roleMapper;

    @Override
    public List<MenuVO> getUserMenus(Long userId) {
        // 查询用户的所有菜单
        List<Menu> menus = menuMapper.selectMenusByUserId(userId);

        // 转换为VO并构建树形结构
        List<MenuVO> menuVOs = menus.stream()
                .map(this::convertToMenuVO)
                .collect(Collectors.toList());

        return buildMenuTree(menuVOs);
    }

    @Override
    public List<PermissionVO> getUserPermissions(Long userId) {
        List<Permission> permissions = permissionMapper.selectPermissionsByUserId(userId);
        return permissions.stream()
                .map(this::convertToPermissionVO)
                .collect(Collectors.toList());
    }

    @Override
    public boolean hasPermission(Long userId, String permissionCode) {
        List<Permission> permissions = permissionMapper.selectPermissionsByUserId(userId);
        return permissions.stream()
                .anyMatch(p -> p.getPermissionCode().equals(permissionCode));
    }

    @Override
    public boolean hasRole(Long userId, String roleCode) {
        List<Role> roles = roleMapper.selectRolesByUserId(userId);
        return roles.stream()
                .anyMatch(r -> r.getRoleCode().equals(roleCode));
    }

    /**
     * 构建菜单树
     */
    private List<MenuVO> buildMenuTree(List<MenuVO> allMenus) {
        List<MenuVO> rootMenus = new ArrayList<>();

        for (MenuVO menu : allMenus) {
            if (menu.getParentId() == 0) {
                // 根菜单
                rootMenus.add(menu);
                // 递归设置子菜单
                menu.setChildren(getChildren(menu.getId(), allMenus));
            }
        }

        return rootMenus;
    }

    /**
     * 获取子菜单
     */
    private List<MenuVO> getChildren(Long parentId, List<MenuVO> allMenus) {
        List<MenuVO> children = new ArrayList<>();

        for (MenuVO menu : allMenus) {
            if (menu.getParentId().equals(parentId)) {
                children.add(menu);
                // 递归设置子菜单
                menu.setChildren(getChildren(menu.getId(), allMenus));
            }
        }

        return children.isEmpty() ? null : children;
    }

    /**
     * 转换Menu到MenuVO
     */
    private MenuVO convertToMenuVO(Menu menu) {
        MenuVO vo = new MenuVO();
        BeanUtils.copyProperties(menu, vo);
        return vo;
    }

    /**
     * 转换Permission到PermissionVO
     */
    private PermissionVO convertToPermissionVO(Permission permission) {
        PermissionVO vo = new PermissionVO();
        BeanUtils.copyProperties(permission, vo);
        return vo;
    }
}

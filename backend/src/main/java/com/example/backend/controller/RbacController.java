package com.example.backend.controller;

import com.example.backend.annotation.RequiresPermission;
import com.example.backend.annotation.RequiresRole;
import com.example.backend.common.Result;
import com.example.backend.service.RbacService;
import com.example.backend.utils.UserContext;
import com.example.backend.vo.MenuVO;
import com.example.backend.vo.PermissionVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * RBAC权限控制器
 */
@RestController
@RequestMapping("/rbac")
@RequiredArgsConstructor
public class RbacController {

    private final RbacService rbacService;

    /**
     * 获取当前用户的菜单列表
     */
    @GetMapping("/menus")
    public Result<List<MenuVO>> getMenus() {
        Long userId = UserContext.getUserId();
        List<MenuVO> menus = rbacService.getUserMenus(userId);
        return Result.success(menus);
    }

    /**
     * 获取当前用户的权限列表
     */
    @GetMapping("/permissions")
    public Result<List<PermissionVO>> getPermissions() {
        Long userId = UserContext.getUserId();
        List<PermissionVO> permissions = rbacService.getUserPermissions(userId);
        return Result.success(permissions);
    }

    /**
     * 测试管理员专用接口
     * 普通用户访问会返回403
     */
    @PostMapping("/admin/test")
    @RequiresRole("ROLE_ADMIN")
    public Result<String> adminTest() {
        return Result.success("管理员操作成功");
    }

    /**
     * 测试删除用户权限
     * 需要user:delete权限
     */
    @DeleteMapping("/admin/delete-user")
    @RequiresPermission("user:delete")
    public Result<String> deleteUser() {
        return Result.success("删除用户成功（模拟操作）");
    }
}

package com.example.backend.interceptor;

import com.example.backend.annotation.RequiresPermission;
import com.example.backend.annotation.RequiresRole;
import com.example.backend.exception.BusinessException;
import com.example.backend.service.RbacService;
import com.example.backend.utils.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 权限验证拦截器
 */
@Component
@RequiredArgsConstructor
public class PermissionInterceptor implements HandlerInterceptor {

    private final RbacService rbacService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        HandlerMethod handlerMethod = (HandlerMethod) handler;
        Long userId = UserContext.getUserId();

        // 检查方法上的@RequiresRole注解
        RequiresRole requiresRole = handlerMethod.getMethodAnnotation(RequiresRole.class);
        if (requiresRole == null) {
            // 如果方法上没有，检查类上的
            requiresRole = handlerMethod.getBeanType().getAnnotation(RequiresRole.class);
        }
        if (requiresRole != null) {
            String roleCode = requiresRole.value();
            if (!rbacService.hasRole(userId, roleCode)) {
                throw new BusinessException(4030, "权限不足：需要角色 " + roleCode);
            }
        }

        // 检查方法上的@RequiresPermission注解
        RequiresPermission requiresPermission = handlerMethod.getMethodAnnotation(RequiresPermission.class);
        if (requiresPermission == null) {
            // 如果方法上没有，检查类上的
            requiresPermission = handlerMethod.getBeanType().getAnnotation(RequiresPermission.class);
        }
        if (requiresPermission != null) {
            String permissionCode = requiresPermission.value();
            if (!rbacService.hasPermission(userId, permissionCode)) {
                throw new BusinessException(4030, "权限不足：需要权限 " + permissionCode);
            }
        }

        return true;
    }
}

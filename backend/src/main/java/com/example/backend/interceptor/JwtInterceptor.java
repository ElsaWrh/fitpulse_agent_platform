package com.example.backend.interceptor;

import com.example.backend.exception.BusinessException;
import com.example.backend.utils.JwtUtil;
import com.example.backend.utils.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * JWT 拦截器
 */
@Component
@RequiredArgsConstructor
public class JwtInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 获取 Token
        String token = request.getHeader("Authorization");
        if (token == null || !token.startsWith("Bearer ")) {
            throw new BusinessException(4010, "未登录或Token已失效");
        }

        token = token.substring(7);

        // 验证 Token
        if (!jwtUtil.validateToken(token)) {
            throw new BusinessException(4010, "Token无效或已过期");
        }

        // 获取用户ID并存入上下文
        Long userId = jwtUtil.getUserIdFromToken(token);
        UserContext.setUserId(userId);

        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler,
            Exception ex) {
        // 清除用户上下文
        UserContext.clear();
    }
}

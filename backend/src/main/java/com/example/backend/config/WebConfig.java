package com.example.backend.config;

import com.example.backend.interceptor.JwtInterceptor;
import com.example.backend.interceptor.PermissionInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC 配置
 */
@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

        private final JwtInterceptor jwtInterceptor;
        private final PermissionInterceptor permissionInterceptor;

        @Override
        public void addInterceptors(InterceptorRegistry registry) {
                // JWT 认证拦截器
                registry.addInterceptor(jwtInterceptor)
                                .addPathPatterns("/**")
                                .excludePathPatterns(
                                                "/v1/auth/register",
                                                "/v1/auth/login",
                                                "/auth/register",
                                                "/auth/login",
                                                "/health",
                                                "/v1/llm/models", // 允许获取模型列表
                                                "/v1/llm/providers", // 允许获取提供商列表
                                                "/llm/models",
                                                "/llm/providers",
                                                "/error");

                // 权限验证拦截器（在JWT之后执行）
                registry.addInterceptor(permissionInterceptor)
                                .addPathPatterns("/**")
                                .excludePathPatterns(
                                                "/v1/auth/register",
                                                "/v1/auth/login",
                                                "/auth/register",
                                                "/auth/login",
                                                "/health",
                                                "/v1/llm/models",
                                                "/v1/llm/providers",
                                                "/llm/models",
                                                "/llm/providers",
                                                "/error");
        }
}

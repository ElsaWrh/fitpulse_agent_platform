package com.example.backend.annotation;

import java.lang.annotation.*;

/**
 * 权限验证注解
 * 用于标注需要特定权限才能访问的接口
 */
@Target({ ElementType.METHOD, ElementType.TYPE })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequiresPermission {
    /**
     * 需要的权限代码
     */
    String value();
}

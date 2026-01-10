package com.example.backend.annotation;

import java.lang.annotation.*;

/**
 * 角色验证注解
 * 用于标注需要特定角色才能访问的接口
 */
@Target({ ElementType.METHOD, ElementType.TYPE })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequiresRole {
    /**
     * 需要的角色代码
     */
    String value();
}

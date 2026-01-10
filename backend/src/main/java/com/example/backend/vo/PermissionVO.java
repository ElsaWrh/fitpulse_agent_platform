package com.example.backend.vo;

import lombok.Data;

/**
 * 权限VO
 */
@Data
public class PermissionVO {
    private Long id;
    private String permissionName;
    private String permissionCode;
    private String resourceType;
    private String resourcePath;
    private String method;
    private String description;
}

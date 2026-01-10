package com.example.backend.vo;

import lombok.Data;

import java.util.List;

/**
 * 菜单VO
 */
@Data
public class MenuVO {
    private Long id;
    private Long parentId;
    private String menuName;
    private String menuCode;
    private String path;
    private String component;
    private String icon;
    private Integer sortOrder;
    private String menuType;
    private Boolean visible;
    private String permissionCode;
    private List<MenuVO> children;
}

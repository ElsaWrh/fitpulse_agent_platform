package com.example.backend.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 菜单实体类
 */
@Data
@TableName("menu")
public class Menu {

    @TableId(type = IdType.AUTO)
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

    private String status;

    private String permissionCode;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    // 子菜单列表（非数据库字段）
    @TableField(exist = false)
    private List<Menu> children;
}

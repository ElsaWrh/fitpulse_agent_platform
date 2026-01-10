package com.example.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.backend.entity.Menu;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 菜单Mapper接口
 */
@Mapper
public interface MenuMapper extends BaseMapper<Menu> {

    /**
     * 根据用户ID查询菜单列表
     */
    @Select("SELECT DISTINCT m.* FROM menu m " +
            "INNER JOIN role_menu rm ON m.id = rm.menu_id " +
            "INNER JOIN user_role ur ON rm.role_id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND m.status = 'ACTIVE' AND m.visible = 1 " +
            "ORDER BY m.sort_order ASC")
    List<Menu> selectMenusByUserId(Long userId);

    /**
     * 根据角色ID查询菜单列表
     */
    @Select("SELECT m.* FROM menu m " +
            "INNER JOIN role_menu rm ON m.id = rm.menu_id " +
            "WHERE rm.role_id = #{roleId} AND m.status = 'ACTIVE' AND m.visible = 1 " +
            "ORDER BY m.sort_order ASC")
    List<Menu> selectMenusByRoleId(Long roleId);
}

package com.example.backend.controller;

import com.example.backend.common.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 知识库控制器
 * TODO: 待完整实现
 */
@RestController
@RequestMapping("/kb")
@RequiredArgsConstructor
public class KnowledgeController {

    /**
     * 获取知识库分类列表
     * 暂时返回空列表,避免前端加载错误
     */
    @GetMapping("/categories")
    public Result<List<Map<String, Object>>> getCategories() {
        // TODO: 实现知识库分类查询
        List<Map<String, Object>> categories = new ArrayList<>();
        return Result.success(categories);
    }

    /**
     * 获取知识条目列表
     * 暂时返回空列表
     */
    @GetMapping("/articles")
    public Result<List<Map<String, Object>>> getArticles(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword) {
        // TODO: 实现知识条目查询
        List<Map<String, Object>> articles = new ArrayList<>();
        return Result.success(articles);
    }

    /**
     * 创建知识条目
     */
    @PostMapping("/articles")
    public Result<Map<String, Object>> createArticle(@RequestBody Map<String, Object> data) {
        // TODO: 实现知识条目创建
        return Result.error("知识库功能开发中");
    }

    /**
     * 更新知识条目
     */
    @PutMapping("/articles/{id}")
    public Result<Void> updateArticle(@PathVariable Long id, @RequestBody Map<String, Object> data) {
        // TODO: 实现知识条目更新
        return Result.error("知识库功能开发中");
    }

    /**
     * 删除知识条目
     */
    @DeleteMapping("/articles/{id}")
    public Result<Void> deleteArticle(@PathVariable Long id) {
        // TODO: 实现知识条目删除
        return Result.error("知识库功能开发中");
    }
}

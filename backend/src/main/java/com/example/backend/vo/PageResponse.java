package com.example.backend.vo;

import lombok.Data;

import java.util.List;

/**
 * 分页响应
 */
@Data
public class PageResponse<T> {

    private List<T> items;

    private Integer page;

    private Integer size;

    private Long total;

    public PageResponse(List<T> items, Integer page, Integer size, Long total) {
        this.items = items;
        this.page = page;
        this.size = size;
        this.total = total;
    }
}

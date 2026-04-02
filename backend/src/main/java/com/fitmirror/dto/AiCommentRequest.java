package com.fitmirror.dto;

import lombok.Data;

import java.util.List;

@Data
public class AiCommentRequest {
    private String clothType;   // 服装类型
    private String clothColor;  // 服装颜色
    private String productUrl;  // 商品链接（可选）
    private String userStyle;   // 用户风格偏好
    private String occasion;    // 场合
    private List<String> existingStyles;  // 现有服装风格
}

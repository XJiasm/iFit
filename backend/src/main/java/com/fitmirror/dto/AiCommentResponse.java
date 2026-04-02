package com.fitmirror.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiCommentResponse {
    private int score;              // 综合评分 0-100
    private String summary;         // 总结
    private ColorAnalysis color;    // 颜色分析
    private StyleAnalysis style;    // 风格分析
    private List<String> occasions; // 适用场合
    private List<String> suggestions; // 搭配建议
    private String conclusion;      // 购买建议

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ColorAnalysis {
        private int score;          // 颜色匹配分
        private String comment;     // 颜色点评
        private List<String> suitableSkinTones; // 适合的肤色
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StyleAnalysis {
        private int score;          // 风格契合分
        private String comment;     // 风格点评
        private List<String> tags;  // 风格标签
    }
}

package com.fitmirror.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "tryon_results")
public class TryOnResult {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long avatarId;

    @Column(nullable = false)
    private Long clothItemId;

    @Column(nullable = false, length = 500)
    private String resultUrl;

    // 编辑参数
    private Double offsetX = 0.0;
    private Double offsetY = 0.0;
    private Double scale = 1.0;
    private Double rotation = 0.0;
    private Double opacity = 1.0;

    // AI 点评
    private Integer aiScore;
    @Column(columnDefinition = "TEXT")
    private String aiComment;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

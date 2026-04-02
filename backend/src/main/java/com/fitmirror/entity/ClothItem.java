package com.fitmirror.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Table(name = "cloth_items")
public class ClothItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false, length = 20)
    private String type;  // top, pants, skirt, dress, jacket, shoes, bag, accessory

    @Column(nullable = false, length = 500)
    private String originalUrl;

    @Column(nullable = false, length = 500)
    private String croppedUrl;

    @Column(length = 500)
    private String productUrl;

    @Column(length = 50)
    private String sourcePlatform;

    @Column(length = 30)
    private String color;

    @Column(columnDefinition = "JSON")
    private String styleTags;  // JSON array

    @Column(length = 20)
    private String status = "wishlist";  // purchased, wishlist, discarded

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

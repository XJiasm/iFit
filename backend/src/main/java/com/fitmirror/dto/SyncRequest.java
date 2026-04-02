package com.fitmirror.dto;

import lombok.Data;
import java.util.List;

@Data
public class SyncRequest {
    private List<AvatarSync> avatars;
    private List<ClothSync> clothes;
    private List<TryOnSync> tryOns;

    @Data
    public static class AvatarSync {
        private String localId;
        private String name;
        private String photoUrl;
        private String thumbnailUrl;
        private Long createdAt;
    }

    @Data
    public static class ClothSync {
        private String localId;
        private String type;
        private String originalUrl;
        private String croppedUrl;
        private String productUrl;
        private String sourcePlatform;
        private String color;
        private List<String> styleTags;
        private String status;
        private Long createdAt;
    }

    @Data
    public static class TryOnSync {
        private String localId;
        private String avatarLocalId;
        private String clothLocalId;
        private String resultUrl;
        private Double offsetX;
        private Double offsetY;
        private Double scale;
        private Double rotation;
        private Double opacity;
        private Integer aiScore;
        private String aiComment;
        private Long createdAt;
    }
}

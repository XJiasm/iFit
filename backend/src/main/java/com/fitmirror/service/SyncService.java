package com.fitmirror.service;

import com.alibaba.fastjson.JSON;
import com.fitmirror.dto.SyncRequest;
import com.fitmirror.dto.SyncResponse;
import com.fitmirror.entity.Avatar;
import com.fitmirror.entity.ClothItem;
import com.fitmirror.entity.TryOnResult;
import com.fitmirror.repository.AvatarRepository;
import com.fitmirror.repository.ClothItemRepository;
import com.fitmirror.repository.TryOnResultRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SyncService {

    private final AvatarRepository avatarRepository;
    private final ClothItemRepository clothItemRepository;
    private final TryOnResultRepository tryOnResultRepository;

    public SyncResponse syncData(Long userId, SyncRequest request) {
        Map<String, Long> idMapping = new HashMap<>();
        int syncedAvatars = 0;
        int syncedClothes = 0;
        int syncedTryOns = 0;

        // 同步形象
        if (request.getAvatars() != null) {
            for (SyncRequest.AvatarSync avatarSync : request.getAvatars()) {
                Avatar avatar = new Avatar();
                avatar.setUserId(userId);
                avatar.setName(avatarSync.getName());
                avatar.setPhotoUrl(avatarSync.getPhotoUrl());
                avatar.setThumbnailUrl(avatarSync.getThumbnailUrl());
                avatar.setCreatedAt(toLocalDateTime(avatarSync.getCreatedAt()));

                avatar = avatarRepository.save(avatar);
                idMapping.put("avatar_" + avatarSync.getLocalId(), avatar.getId());
                syncedAvatars++;
            }
        }

        // 同步服装
        if (request.getClothes() != null) {
            for (SyncRequest.ClothSync clothSync : request.getClothes()) {
                ClothItem cloth = new ClothItem();
                cloth.setUserId(userId);
                cloth.setType(clothSync.getType());
                cloth.setOriginalUrl(clothSync.getOriginalUrl());
                cloth.setCroppedUrl(clothSync.getCroppedUrl());
                cloth.setProductUrl(clothSync.getProductUrl());
                cloth.setSourcePlatform(clothSync.getSourcePlatform());
                cloth.setColor(clothSync.getColor());
                cloth.setStyleTags(clothSync.getStyleTags() != null
                        ? JSON.toJSONString(clothSync.getStyleTags())
                        : null);
                cloth.setStatus(clothSync.getStatus() != null ? clothSync.getStatus() : "wishlist");
                cloth.setCreatedAt(toLocalDateTime(clothSync.getCreatedAt()));

                cloth = clothItemRepository.save(cloth);
                idMapping.put("cloth_" + clothSync.getLocalId(), cloth.getId());
                syncedClothes++;
            }
        }

        // 同步试穿记录
        if (request.getTryOns() != null) {
            for (SyncRequest.TryOnSync tryOnSync : request.getTryOns()) {
                TryOnResult tryOn = new TryOnResult();
                tryOn.setUserId(userId);

                // 映射本地ID到服务器ID
                String avatarKey = "avatar_" + tryOnSync.getAvatarLocalId();
                String clothKey = "cloth_" + tryOnSync.getClothLocalId();

                if (idMapping.containsKey(avatarKey)) {
                    tryOn.setAvatarId(idMapping.get(avatarKey));
                }
                if (idMapping.containsKey(clothKey)) {
                    tryOn.setClothItemId(idMapping.get(clothKey));
                }

                tryOn.setResultUrl(tryOnSync.getResultUrl());
                tryOn.setOffsetX(tryOnSync.getOffsetX());
                tryOn.setOffsetY(tryOnSync.getOffsetY());
                tryOn.setScale(tryOnSync.getScale());
                tryOn.setRotation(tryOnSync.getRotation());
                tryOn.setOpacity(tryOnSync.getOpacity());
                tryOn.setAiScore(tryOnSync.getAiScore());
                tryOn.setAiComment(tryOnSync.getAiComment());
                tryOn.setCreatedAt(toLocalDateTime(tryOnSync.getCreatedAt()));

                tryOn = tryOnResultRepository.save(tryOn);
                idMapping.put("tryon_" + tryOnSync.getLocalId(), tryOn.getId());
                syncedTryOns++;
            }
        }

        return SyncResponse.builder()
                .syncedAvatars(syncedAvatars)
                .syncedClothes(syncedClothes)
                .syncedTryOns(syncedTryOns)
                .idMapping(idMapping)
                .message(String.format("成功同步 %d 个形象、%d 件服装、%d 条试穿记录",
                        syncedAvatars, syncedClothes, syncedTryOns))
                .build();
    }

    private LocalDateTime toLocalDateTime(Long timestamp) {
        if (timestamp == null) return LocalDateTime.now();
        return LocalDateTime.ofInstant(Instant.ofEpochMilli(timestamp), ZoneId.systemDefault());
    }

    public Map<String, Object> downloadData(Long userId) {
        List<Avatar> avatars = avatarRepository.findByUserId(userId);
        List<ClothItem> clothes = clothItemRepository.findByUserId(userId);
        List<TryOnResult> tryOns = tryOnResultRepository.findByUserId(userId);

        return Map.of(
                "avatars", avatars,
                "clothes", clothes,
                "tryOns", tryOns
        );
    }
}

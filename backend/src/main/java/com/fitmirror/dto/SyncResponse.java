package com.fitmirror.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SyncResponse {
    private int syncedAvatars;
    private int syncedClothes;
    private int syncedTryOns;
    private Map<String, Long> idMapping; // localId -> serverId
    private String message;
}

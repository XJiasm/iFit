package com.fitmirror.controller;

import com.fitmirror.dto.ApiResponse;
import com.fitmirror.dto.SyncRequest;
import com.fitmirror.dto.SyncResponse;
import com.fitmirror.service.SyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/sync")
@RequiredArgsConstructor
public class SyncController {

    private final SyncService syncService;

    @PostMapping("/upload")
    public ApiResponse<SyncResponse> upload(
            @AuthenticationPrincipal Long userId,
            @RequestBody SyncRequest request) {
        try {
            SyncResponse response = syncService.syncData(userId, request);
            return ApiResponse.success(response.getMessage(), response);
        } catch (Exception e) {
            return ApiResponse.error("同步失败: " + e.getMessage());
        }
    }

    @GetMapping("/download")
    public ApiResponse<Map<String, Object>> download(@AuthenticationPrincipal Long userId) {
        try {
            Map<String, Object> data = syncService.downloadData(userId);
            return ApiResponse.success(data);
        } catch (Exception e) {
            return ApiResponse.error("获取数据失败: " + e.getMessage());
        }
    }
}

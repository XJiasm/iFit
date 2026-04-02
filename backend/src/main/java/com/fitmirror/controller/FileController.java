package com.fitmirror.controller;

import com.fitmirror.dto.ApiResponse;
import com.fitmirror.service.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final FileStorageService fileStorageService;

    @PostMapping("/upload")
    public ApiResponse<FileUploadResponse> uploadFile(
            @AuthenticationPrincipal Long userId,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "type", defaultValue = "general") String type) {

        try {
            String fileUrl = fileStorageService.storeFile(file, type, userId);
            String fileName = file.getOriginalFilename();
            long fileSize = file.getSize();

            return ApiResponse.success("上传成功", new FileUploadResponse(
                    fileUrl,
                    fileName,
                    fileSize
            ));
        } catch (Exception e) {
            return ApiResponse.error("上传失败: " + e.getMessage());
        }
    }

    @PostMapping("/upload/multiple")
    public ApiResponse<List<FileUploadResponse>> uploadMultipleFiles(
            @AuthenticationPrincipal Long userId,
            @RequestParam("files") MultipartFile[] files,
            @RequestParam(value = "type", defaultValue = "general") String type) {

        try {
            List<FileUploadResponse> responses = new ArrayList<>();
            for (MultipartFile file : files) {
                String fileUrl = fileStorageService.storeFile(file, type, userId);
                responses.add(new FileUploadResponse(
                        fileUrl,
                        file.getOriginalFilename(),
                        file.getSize()
                ));
            }
            return ApiResponse.success("上传成功", responses);
        } catch (Exception e) {
            return ApiResponse.error("上传失败: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete")
    public ApiResponse<Void> deleteFile(
            @AuthenticationPrincipal Long userId,
            @RequestParam("fileUrl") String fileUrl) {

        try {
            fileStorageService.deleteFile(fileUrl);
            return ApiResponse.success("删除成功", null);
        } catch (Exception e) {
            return ApiResponse.error("删除失败: " + e.getMessage());
        }
    }
}

record FileUploadResponse(String url, String fileName, long fileSize) {}

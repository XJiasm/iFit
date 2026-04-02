package com.fitmirror.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
public class FileStorageService {

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    @Value("${server.port:8080}")
    private String serverPort;

    public String storeFile(MultipartFile file, String type, Long userId) throws IOException {
        // 创建目录结构: uploads/{type}/{userId}/{date}/
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String dirPath = String.format("%s/%s/%d/%s", uploadDir, type, userId, date);

        Path uploadPath = Paths.get(dirPath);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // 生成唯一文件名
        String originalFileName = file.getOriginalFilename();
        String extension = "";
        if (originalFileName != null && originalFileName.contains(".")) {
            extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString() + extension;

        // 保存文件
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath);

        // 返回访问URL
        return String.format("/uploads/%s/%d/%s/%s", type, userId, date, fileName);
    }

    public void deleteFile(String fileUrl) throws IOException {
        if (fileUrl == null || !fileUrl.startsWith("/uploads/")) {
            throw new IllegalArgumentException("无效的文件URL");
        }

        Path filePath = Paths.get(uploadDir, fileUrl.substring("/uploads/".length()));
        if (Files.exists(filePath)) {
            Files.delete(filePath);
        }
    }

    public String getFullUrl(String relativeUrl) {
        if (relativeUrl == null) return null;
        if (relativeUrl.startsWith("http")) return relativeUrl;
        return "http://localhost:" + serverPort + relativeUrl;
    }
}

package com.fitmirror.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.File;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    @Override
    public void run(String... args) throws Exception {
        // 创建上传目录
        createUploadDirectories();

        log.info("===========================================");
        log.info("FitMirror Backend Started Successfully");
        log.info("API Base URL: http://localhost:8080/api");
        log.info("Health Check: http://localhost:8080/api/health");
        log.info("===========================================");
    }

    private void createUploadDirectories() {
        String[] dirs = {"uploads/avatars", "uploads/clothes", "uploads/tryons"};
        for (String dir : dirs) {
            File directory = new File(dir);
            if (!directory.exists()) {
                directory.mkdirs();
                log.info("Created directory: {}", dir);
            }
        }
    }
}

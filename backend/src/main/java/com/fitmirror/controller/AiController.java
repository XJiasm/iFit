package com.fitmirror.controller;

import com.fitmirror.dto.AiCommentRequest;
import com.fitmirror.dto.AiCommentResponse;
import com.fitmirror.dto.ApiResponse;
import com.fitmirror.service.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;

    @PostMapping("/comment")
    public ApiResponse<AiCommentResponse> getComment(@RequestBody AiCommentRequest request) {
        AiCommentResponse response = aiService.getComment(request);
        return ApiResponse.success(response);
    }

    @GetMapping("/providers")
    public ApiResponse<String[]> getProviders() {
        return ApiResponse.success(new String[]{"deepseek", "openai", "anthropic", "qwen"});
    }
}

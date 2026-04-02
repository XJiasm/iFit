package com.fitmirror.controller;

import com.fitmirror.dto.ApiResponse;
import com.fitmirror.entity.User;
import com.fitmirror.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/info")
    public ApiResponse<User> getUserInfo(@AuthenticationPrincipal Long userId) {
        User user = userService.getUserById(userId);
        user.setPassword(null); // 不返回密码
        return ApiResponse.success(user);
    }

    @PutMapping("/profile")
    public ApiResponse<User> updateProfile(
            @AuthenticationPrincipal Long userId,
            @RequestBody Map<String, String> request) {
        User user = userService.updateProfile(
                userId,
                request.get("nickname"),
                request.get("avatarUrl")
        );
        user.setPassword(null);
        return ApiResponse.success("更新成功", user);
    }
}

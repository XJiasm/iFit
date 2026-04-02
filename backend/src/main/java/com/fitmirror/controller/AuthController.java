package com.fitmirror.controller;

import com.fitmirror.dto.ApiResponse;
import com.fitmirror.dto.AuthRequest;
import com.fitmirror.dto.AuthResponse;
import com.fitmirror.dto.RegisterRequest;
import com.fitmirror.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @PostMapping("/register")
    public ApiResponse<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = userService.register(request);
            return ApiResponse.success("注册成功", response);
        } catch (Exception e) {
            return ApiResponse.error(e.getMessage());
        }
    }

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        try {
            AuthResponse response = userService.login(request);
            return ApiResponse.success("登录成功", response);
        } catch (Exception e) {
            return ApiResponse.error(e.getMessage());
        }
    }
}

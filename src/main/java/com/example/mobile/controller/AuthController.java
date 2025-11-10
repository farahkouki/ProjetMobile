package com.example.mobile.controller;



import com.example.mobile.dto.RequestOtpDTO;
import com.example.mobile.dto.VerifyOtpDTO;
import com.example.mobile.service.OtpService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final OtpService otpService;

    public AuthController(OtpService otpService) {
        this.otpService = otpService;
    }

    @PostMapping("/request-otp")
    public ResponseEntity<?> requestOtp(@Valid @RequestBody RequestOtpDTO body) {
        otpService.sendOtp(body.getEmail());
        return ResponseEntity.ok(Map.of("ok", true, "message", "OTP sent"));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@Valid @RequestBody VerifyOtpDTO body) {
        boolean ok = otpService.verifyOtp(body.getEmail(), body.getCode());
        if (!ok) {
            return ResponseEntity.badRequest().body(Map.of("ok", false, "error", "Invalid or expired code"));
        }
        return ResponseEntity.ok(Map.of("ok", true, "message", "Verified"));
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("ok", true);
    }
}

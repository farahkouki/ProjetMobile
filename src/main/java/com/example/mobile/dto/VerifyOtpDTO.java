package com.example.mobile.dto;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class VerifyOtpDTO {
    @NotBlank @Email
    private String email;

    @NotBlank
    @Size(min = 6, max = 6)
    @Pattern(regexp = "\\d{6}")
    private String code;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
}


package com.example.mobile.service;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpService {

    private final JavaMailSender mailSender;
    private final String from;
    private final Random random = new Random();

    // email -> entry
    private final Map<String, Entry> store = new ConcurrentHashMap<>();

    public OtpService(JavaMailSender mailSender, @Value("${app.mail.from}") String from) {
        this.mailSender = mailSender;
        this.from = from;
    }

    public void sendOtp(String email) {
        String normalized = email.toLowerCase();
        String code = generateCode();
        String hash = sha256(code);
        long expiresAt = System.currentTimeMillis() + 5 * 60_000; // 5 minutes

        store.put(normalized, new Entry(hash, expiresAt, 0));

        SimpleMailMessage msg = new SimpleMailMessage();
        msg.setFrom(from);
        msg.setTo(email);
        msg.setSubject("Your verification code");
        msg.setText("Your verification code is: " + code + "\nThis code expires in 5 minutes.");
        mailSender.send(msg);
    }

    public boolean verifyOtp(String email, String code) {
        String normalized = email.toLowerCase();
        Entry e = store.get(normalized);
        if (e == null) return false;
        if (System.currentTimeMillis() > e.expiresAt) {
            store.remove(normalized);
            return false;
        }
        e.attempts++;
        if (e.attempts > 5) {
            store.remove(normalized);
            return false;
        }
        boolean ok = e.hash.equals(sha256(code));
        if (ok) store.remove(normalized);
        return ok;
    }

    private String generateCode() {
        int n = 100000 + random.nextInt(900000); // 6 digits
        return Integer.toString(n);
    }

    private String sha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] out = md.digest(s.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : out) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception ex) { throw new RuntimeException(ex); }
    }

    private static class Entry {
        final String hash;
        final long expiresAt;
        int attempts;
        Entry(String hash, long expiresAt, int attempts) {
            this.hash = hash;
            this.expiresAt = expiresAt;
            this.attempts = attempts;
        }
    }
}

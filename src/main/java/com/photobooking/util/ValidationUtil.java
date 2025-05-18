package com.photobooking.util;

import java.util.regex.Pattern;

/**
 * Utility class for input validation in the Event Photography System
 */
public class ValidationUtil {
    // Regex patterns for validation
    private static final String USERNAME_REGEX = "^[a-zA-Z0-9_]{3,20}$";
    private static final String EMAIL_REGEX = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
    //private static final String PASSWORD_REGEX = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!])(?=\\S+$).{8,20}$";
    private static final String FULL_NAME_REGEX = "^[A-Za-z\\s'-]{2,50}$";
    private static final String PHONE_REGEX = "^\\+?[1-9]\\d{9,14}$";

    /**
     * Validate username
     * @param username Username to validate
     * @return true if username is valid, false otherwise
     */
    public static boolean isValidUsername(String username) {
        return username != null && Pattern.matches(USERNAME_REGEX, username);
    }

    /**
     * Validate email address
     * @param email Email to validate
     * @return true if email is valid, false otherwise
     */
    public static boolean isValidEmail(String email) {
        return email != null && Pattern.matches(EMAIL_REGEX, email);
    }

    /**
     * Validate password
     * @param password Password to validate
     * @return true if password is valid, false otherwise
     */
    public static boolean isValidPassword(String password) {
        return password != null;
    }

    /**
     * Validate full name
     * @param fullName Full name to validate
     * @return true if full name is valid, false otherwise
     */
    public static boolean isValidFullName(String fullName) {
        return fullName != null && Pattern.matches(FULL_NAME_REGEX, fullName);
    }

    /**
     * Validate phone number
     * @param phoneNumber Phone number to validate
     * @return true if phone number is valid, false otherwise
     */
    public static boolean isValidPhoneNumber(String phoneNumber) {
        return phoneNumber != null && Pattern.matches(PHONE_REGEX, phoneNumber);
    }

    /**
     * Check if a string is null or empty (whitespace-only)
     * @param str String to check
     * @return true if string is null or empty, false otherwise
     */
    public static boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    /**
     * Trim and clean input string
     * @param input Input string to clean
     * @return Trimmed and cleaned string, or empty string if input is null
     */
    public static String cleanInput(String input) {
        return input != null ? input.trim() : "";
    }

    /**
     * Sanitize user input to prevent XSS attacks
     * @param input Input string to sanitize
     * @return Sanitized string
     */
    public static String sanitizeInput(String input) {
        if (input == null) return null;

        return input.replaceAll("<", "&lt;")
                .replaceAll(">", "&gt;")
                .replaceAll("&", "&amp;")
                .replaceAll("\"", "&quot;")
                .replaceAll("'", "&#x27;");
    }

    /**
     * Validate age based on minimum age requirement
     * @param age Age to validate
     * @param minAge Minimum required age
     * @return true if age meets or exceeds minimum, false otherwise
     */
    public static boolean isValidAge(int age, int minAge) {
        return age >= minAge;
    }
}
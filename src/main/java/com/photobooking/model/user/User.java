package com.photobooking.model.user;

import java.io.Serializable;
import java.util.UUID;

/**
 * Base User class for the Event Photography System
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    // User types
    public enum UserType {
        CLIENT, PHOTOGRAPHER, ADMIN
    }

    // User attributes
    private String userId;
    private String username;
    private String password;
    private String email;
    private String fullName;
    private UserType userType;
    private boolean isActive;

    // Constructors
    public User() {
        this.userId = UUID.randomUUID().toString();
        this.isActive = true;
    }

    public User(String username, String password, String email, String fullName, UserType userType) {
        this.userId = UUID.randomUUID().toString();
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
        this.userType = userType;
        this.isActive = true;
    }

    // Getters and Setters
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    // Authentication method
    public boolean authenticate(String inputPassword) {
        return this.password.equals(inputPassword);
    }

    // Convert user to file string representation
    public String toFileString() {
        return String.join(",",
                userId,
                username,
                password,
                email,
                fullName,
                userType.name(),
                String.valueOf(isActive)
        );
    }

    // Create user from file string
    public static User fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length >= 7) {
            User user = new User();
            user.setUserId(parts[0]);
            user.setUsername(parts[1]);
            user.setPassword(parts[2]);
            user.setEmail(parts[3]);
            user.setFullName(parts[4]);
            user.setUserType(UserType.valueOf(parts[5]));
            user.setActive(Boolean.parseBoolean(parts[6]));
            return user;
        }
        return null;
    }

    @Override
    public String toString() {
        return "User{" +
                "userId='" + userId + '\'' +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", userType=" + userType +
                ", isActive=" + isActive +
                '}';
    }
}
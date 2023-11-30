package com.tibeb.userManagement.user.model;

import com.mongodb.lang.Nullable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
public class User {

    public enum Role {
        USER,
        CLIENT
    }
    @Id
    private String id;
    @Nullable
    private String firstName;
    @Nullable
    private String lastName;
    @Nullable
    private String userName;
    @Nullable
    private String phoneNumber;
    private String email;
    private String password;
    @Nullable
    private Role role;
    @Nullable
    private String profilePictureLink;
    @Nullable
    private String profileImageId;
    @Nullable
    private List<String> savedPaintingIdList = new ArrayList<>();
    @Nullable
    private List<String> boughtPaintingIdList = new ArrayList<>();
    @Nullable
    private List<String> likedPaintingIdList = new ArrayList<>();
    @Nullable
    private List<String> followingPaintersList = new ArrayList<>();

    public User(String email, String password, String id) {
        this.email = email;
        this.password = password;
        this.setId(id);
    }
}
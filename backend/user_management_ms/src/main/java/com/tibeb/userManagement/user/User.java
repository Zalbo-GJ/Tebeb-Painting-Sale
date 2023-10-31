package com.tibeb.userManagement.user;

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
    private String firstName;
    private String lastName;
    private String userName;
    private String phoneNumber;
    private String email;
    private String password;
    private Role role;
    private String profilePictureLink;
    private String profileImageId;
    private List<String> savedPaintingIdList = new ArrayList<>();
    private List<String> boughtPaintingIdList = new ArrayList<>();
    private List<String> likedPaintingIdList = new ArrayList<>();
    private List<String> followingPaintersList = new ArrayList<>();
}
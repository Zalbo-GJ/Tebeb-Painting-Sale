package com.tibeb.userManagement.client;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "clients")
public class Client {
    public enum Role {
        USER,
        CLIENT
    }
    public enum Region {
        ADDIS_ABABA,
        DIREDAWA,
        DESSIE
    }
    @Id
    private String id;
    private String firstName;
    private String lastName;
    private String artistName;
    private String phoneNumber;
    private String email;
    private String password;

    //take out region
    private Region region;
    private Role role;
    private int followers;
    private double rating;
    private int numberOfPeopleWhoHaveRated;
    private String description;
    private String profilePictureLink;
    private String backgroundPictureLink;
    private String profileImageId;
    private String backgroundImageId;
    private List<String> paintingIdList = new ArrayList<>();
    private List<String> savedPaintingIdList = new ArrayList<>();
    private List<String> boughtPaintingIdList = new ArrayList<>();
    private List<String> likedPaintingIdList = new ArrayList<>();
    private List<String> followingPaintersList = new ArrayList<>();
    public Client(String email, String password, String id) {
        this.email = email;
        this.password = password;
        this.setId(id);
    }
}
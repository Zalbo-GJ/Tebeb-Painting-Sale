package com.tibeb.painting;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Document("painting")
@Builder
public class Painting {

    public enum Genre {
        LANDSCAPE,
        PORTRAIT,
        ABSTRACT,
        STILL_LIFE,
        IMPRESSIONISM,
        REALISM,
        MODERN,
        CONTEMPORARY,
        SURREALISM
    }

    public enum Type {
        OIL,
        WATERCOLOR,
        ACRYLIC,
        PASTEL,
        CHARCOAL,
        INK,
        MIXED_MEDIA
    }

    @Id
    private String id;
    private String name;
    private String imageLink;
    private String imageId;
    private String clientId;
    private String artistName;
    private double width;
    private double length;
    private double price;
    private Genre genre;
    private Type type;
    private boolean sold;
    private LocalDateTime dateAdded;
    private String description;
    private int likes;
    List<String> listOfIdThatLikedThePainting = new ArrayList<>();
    //for frontpage
    private boolean likedByUser;
}
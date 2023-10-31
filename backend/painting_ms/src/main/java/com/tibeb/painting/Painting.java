package com.tibeb.painting;

import org.bson.types.Binary;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

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
    private String artist;
    private double width;
    private double height;
    private Genre genre;
    private Type type;
    private boolean sold;
    private LocalDateTime dateAdded;
    private String description;
    private int likes;
}
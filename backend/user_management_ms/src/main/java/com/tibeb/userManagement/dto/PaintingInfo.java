package com.tibeb.userManagement.dto;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PaintingInfo {
    private String name;
    private String email;
    private String role;
    private List<String> savedPaintingIdList;
    private List<String> boughtPaintingIdList;
}
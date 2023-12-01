package com.tibeb.userManagement.dto;

import lombok.*;
import org.springframework.http.HttpStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ErrorRes {
    HttpStatus httpStatus;
    String message;

}
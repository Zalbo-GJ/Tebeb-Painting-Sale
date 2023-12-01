package com.tibeb.userManagement.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginReq {
    private String email;
    private String password;
}

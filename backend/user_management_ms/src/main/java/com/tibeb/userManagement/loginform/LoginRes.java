package com.tibeb.userManagement.loginform;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRes {
    private String email;
    private String token;
}

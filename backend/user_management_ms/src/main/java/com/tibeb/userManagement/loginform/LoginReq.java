package com.tibeb.userManagement.loginform;

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

package com.tibeb.userManagement.loginform;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RegisterForm {
    private String firstName;
    private String lastName;
    private String email;
    private String password;
}

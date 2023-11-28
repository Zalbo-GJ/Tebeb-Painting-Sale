package com.tibeb.userManagement.user;

import com.tibeb.userManagement.user.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface UserRepository extends MongoRepository <User, String> {
    public Optional<User> findByEmail(String email);
    public Optional<User> findByPhoneNumber(String phoneNumber);
    public Optional<User> findByUserName(String userName);

//    public Optional<User> findByRole(String role);

}

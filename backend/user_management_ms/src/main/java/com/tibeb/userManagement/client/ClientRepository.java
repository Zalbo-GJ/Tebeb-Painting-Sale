package com.tibeb.userManagement.client;

import com.tibeb.userManagement.user.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface ClientRepository extends MongoRepository <Client, String> {
    public Optional<Client> findByEmail(String email);

    public Optional<Client> findByRegion(String region);
}
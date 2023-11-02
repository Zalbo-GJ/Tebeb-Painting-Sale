package com.tibeb.painting;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface PaintingRepository extends MongoRepository<Painting, String> {
    public Optional<Painting> findByName(String name);
    public Optional<List<Painting>> findByClientId(String clientId);
}

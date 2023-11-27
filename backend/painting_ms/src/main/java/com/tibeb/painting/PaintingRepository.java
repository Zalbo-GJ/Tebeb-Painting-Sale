package com.tibeb.painting;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface PaintingRepository extends MongoRepository<Painting, String> {
    public Optional<Painting> findByName(String name);
    public Optional<List<Painting>> findByClientId(String clientId);

    public Optional<List<Painting>> findByPriceLessThanEqual(double max);

    public Optional<List<Painting>> findByPriceGreaterThanEqual(double max);

    public Optional<List<Painting>> findByPriceBetween(double min, double max);

//    public Optional<List<Painting>> findBySellerRatingGreaterThanEqual(double rating);
}

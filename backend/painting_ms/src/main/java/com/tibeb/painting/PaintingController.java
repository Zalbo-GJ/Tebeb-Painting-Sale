package com.tibeb.painting;

import io.imagekit.sdk.exceptions.*;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;

@RestController
@RequestMapping("/api/paint")
@CrossOrigin(origins = "*")
public class PaintingController {

    @Autowired
    private PaintingService paintingService;

    //UPLOAD image of painting
    @PutMapping("/image/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Uploaded successfully"),
            @ApiResponse(responseCode = "400", description = "Painting is not found"),
            @ApiResponse(responseCode = "413", description = "File size too big - must be below 1Mb"),
            @ApiResponse(responseCode = "500", description = "Failed to upload image"),
            @ApiResponse(responseCode = "500", description = "Unknown Error")})
    public ResponseEntity<Map<String, Object>> addImage(@RequestParam("image") MultipartFile image, @PathVariable String id) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        Map<String, Object> response = new HashMap<>();
        String r =paintingService.addImage(id, image);

        switch (r) {
            case "not found" -> {
                response.put("message", "painting not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "painting" -> {
                response.put("message", "failed to upload!");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
            case "added" -> {
                response.put("message", "uploaded successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "file size" -> {
                response.put("message", "File size too big - must be below 1Mb");
                return new ResponseEntity<>(response, HttpStatus.PAYLOAD_TOO_LARGE);
            }
            default -> {
                response.put("message", "unknown error");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

    //POST new painting
    @PostMapping
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Painting added successfully"),
            @ApiResponse(responseCode = "400", description = "Title already exists")})
    public ResponseEntity<String> addPainting(@RequestBody Painting painting) throws IOException {

        String response = paintingService.addPainting(painting);

        if (response.equals("name")) {
            return new ResponseEntity<>("Title already exists", HttpStatus.BAD_REQUEST);
        }  else
            return new ResponseEntity<>("Painting added", HttpStatus.OK);
    }

    //GET all paintings
    @GetMapping
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved all paintings"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getAllPaintings() {
        return new ResponseEntity<>(paintingService.getAllPaintings(), HttpStatus.OK) ;
    }

    //GET all paintings with likes
    @GetMapping("/get/{userId}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved paintings with likes"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getAllPaintingsWithLikes(@PathVariable String userId) {
        return new ResponseEntity<>(paintingService.getAllPaintingsWithLikes(userId), HttpStatus.OK) ;
    }

    //GET all paintings with likes
    @GetMapping("/liked-paintings/{userId}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved liked paintings"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getPaintingsWithLikesOnly(@PathVariable String userId) {
        return new ResponseEntity<>(paintingService.getPaintingsWithLikesOnly(userId), HttpStatus.OK) ;
    }

    //GET painting by ID
    @GetMapping("/id/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved painting by ID"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<Optional<Painting>> getPaintingById(@PathVariable String id) {
        Optional<Painting> result = paintingService.getPaintingById(id);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET painting by name
    @GetMapping("/name/{name}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved painting by name"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getPaintingByName(@PathVariable String name) {
        List<Painting> result = paintingService.getPaintingByName(name);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET painting by clientId
    @GetMapping("/clientId/{clientId}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved painting by clientId"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getPaintingByClientId(@PathVariable String clientId) {
        List<Painting> result = paintingService.getPaintingByClientId(clientId);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET painting by genre
    @GetMapping("/genre/{genre}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved painting by genre"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getPaintingByGenre(@PathVariable String genre) {
        List<Painting> result = paintingService.getPaintingByGenre(genre);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET by price
    @GetMapping("/price")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved paintings by price"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> getPaintingsByPrice(
            @RequestParam(required = false, defaultValue = "0") int min,
            @RequestParam(required = false, defaultValue = "0") int max
    ) {
        List<Painting> paintings = paintingService.getPaintingByPrice(min, max);

        if (paintings.isEmpty()) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.ok(paintings);
        }
    }

    //UPDATE painting by id
    @PutMapping("/update/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Updated painting successfully"),
            @ApiResponse(responseCode = "400", description = "Title already exists"),
            @ApiResponse(responseCode = "404", description = "Painting not found"),
            @ApiResponse(responseCode = "400", description = "ClientId does not exist"),
            @ApiResponse(responseCode = "400", description = "Genre does not exist")})
    public ResponseEntity<Map<String, Object>> updatePainting(@RequestBody Painting painting, @PathVariable String id) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.updatePainting(id, painting);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);

        } else if (Objects.equals(status, "name")){
            response.put("message","Title already exists");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        } else if (Objects.equals(status, "clientId")){
            response.put("message","ClientId does not exist");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        }
        else if (Objects.equals(status, "genre")){
            response.put("message", "Genre does not exist");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        } else{
            response.put("message", "Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }
    }

    //when painting is sold
    @PutMapping("/sold/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Updated painting as sold"),
            @ApiResponse(responseCode = "400", description = "Painting already sold"),
            @ApiResponse(responseCode = "404", description = "Painting not found")})
    public ResponseEntity<Map<String, Object>> soldPainting(@PathVariable String id) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.soldPainting(id);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } else if (Objects.equals(status, "already sold")) {
            response.put("message","Painting already sold you dumb asses!");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        } else{
            response.put("message","Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }
    }

    //update seller rating
    @PutMapping("/update-rating/{clientId}/{rating}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Updated seller rating successfully"),
            @ApiResponse(responseCode = "404", description = "Painting not found")})
    public ResponseEntity<Map<String, Object>> updateSellerRating(@PathVariable String clientId, @PathVariable int rating){
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.updateSellerRating(clientId,rating);

        if (Objects.equals(status, "not found")) {
            response.put("message", "Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } else{
            response.put("message","Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }
    }

    //DELETE painting by id
    @DeleteMapping("/delete/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Painting deleted"),
            @ApiResponse(responseCode = "404", description = "Painting not found"),
            @ApiResponse(responseCode = "200", description = "Painting deleted - profile picture not found"),
            @ApiResponse(responseCode = "500", description = "Unknown error")})
    public ResponseEntity<String> deletePainting(@PathVariable String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        String status = paintingService.deletePainting(id);
        switch (status) {
            case "not found" -> {
                return new ResponseEntity<>("Painting not found!", HttpStatus.NOT_FOUND);
            }
            case "deleted" -> {
                return new ResponseEntity<>("Painting deleted!", HttpStatus.OK);
            }
            case "empty" -> {
                return new ResponseEntity<>("painting deleted - profile picture not found!", HttpStatus.OK);
            }
        }
        return new ResponseEntity<>("Unknown error!", HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //add a like
    @PutMapping("/like/add/{id}/{userId}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Like added successfully"),
            @ApiResponse(responseCode = "404", description = "Painting not found"),
            @ApiResponse(responseCode = "400", description = "The painting is already liked by this user")})
    public ResponseEntity<Map<String, Object>> likeAdd(@PathVariable String id, @PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.likeAdd(id, userId);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);

        } else if (Objects.equals(status, "already liked")){
            response.put("message","The painting is already liked by this user! you are bad at coding!!");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        }
        else{
            response.put("message","Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }

    }

    //sub a like
    @PutMapping("/like/sub/{id}/{userId}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Like subtracted successfully"),
            @ApiResponse(responseCode = "404", description = "Painting not found"),
            @ApiResponse(responseCode = "400", description = "The painting already has zero likes"),
            @ApiResponse(responseCode = "400", description = "The user didn't like the painting in the first place")})
    public ResponseEntity<Map<String, Object>> likeSubtract(@PathVariable String id, @PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.likeSubtract(id, userId);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);

        } else if (Objects.equals(status, "zero")) {
            response.put("message","the painting already has zero likes, can't be negative!");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        } else if (Objects.equals(status, "not liked")) {
            response.put("message","the user didn't like the painting in the first place! you are a shitty coder!!");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

        }
        else{
            response.put("message","Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }

    }


    //FRONT PAGE RECOMMENDATION
    @GetMapping("/front")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Retrieved front page recommendations"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<List<Painting>>> forYouPage() {
        List<List<Painting>> recommendation = new ArrayList<>();

        recommendation.add(paintingService.latestPaintings());
        recommendation.add(paintingService.mostLikedPaintings());

        return new ResponseEntity<>(recommendation, HttpStatus.OK) ;
    }

    //Filter
    @GetMapping("/filter")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Filtered paintings"),
            @ApiResponse(responseCode = "204", description = "No content")})
    public ResponseEntity<List<Painting>> filter(
            @RequestParam (value = "minPrice", defaultValue = "0") int minPrice,
            @RequestParam (value = "maxPrice", defaultValue = "0") int maxPrice,
            @RequestParam (value = "minSellerRating", defaultValue = "0") int minSellerRating,
            @RequestParam (value = "type", required = false) List<String> type,
            @RequestParam (value = "genre", required = false) List<String> genre) {

        List<Painting> filtered = paintingService.filter(minPrice, maxPrice, minSellerRating, type, genre);
        if (filtered.isEmpty())
            return new ResponseEntity<>(new ArrayList<>(), HttpStatus.OK);
        return new ResponseEntity<>(filtered, HttpStatus.OK) ;
    }
}
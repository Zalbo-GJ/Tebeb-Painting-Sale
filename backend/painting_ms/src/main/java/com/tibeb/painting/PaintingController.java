package com.tibeb.painting;

import io.imagekit.sdk.exceptions.*;
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
public class PaintingController {

    @Autowired
    private PaintingService paintingService;

    //UPLOAD image of painting
    @PutMapping("/image/{id}")
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
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            default -> {
                response.put("message", "unknown error");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

    //POST new painting
    @PostMapping
    public ResponseEntity<String> addPainting(@RequestBody Painting painting) throws IOException {

        String response = paintingService.addPainting(painting);

        if (response.equals("name")) {
            return new ResponseEntity<>("Title already exists", HttpStatus.OK);
        }  else
            return new ResponseEntity<>("Painting added", HttpStatus.OK);
    }

    //GET all paintings
    @GetMapping
    public ResponseEntity<List<Painting>> getAllPaintings() {
        return new ResponseEntity<>(paintingService.getAllPaintings(), HttpStatus.OK) ;
    }

    //GET all paintings trial
    @GetMapping("/trial")
    public ResponseEntity<List<Painting>> getAllPaintingsTrial(String userId) {
        return new ResponseEntity<>(paintingService.getAllPaintings(), HttpStatus.OK) ;
    }

    //GET painting by ID
    @GetMapping("/id/{id}")
    public ResponseEntity<Optional<Painting>> getPaintingById(@PathVariable String id) {
        Optional<Painting> result = paintingService.getPaintingById(id);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET painting by name
    @GetMapping("/name/{name}")
    public ResponseEntity<List<Painting>> getPaintingByName(@PathVariable String name) {
        List<Painting> result = paintingService.getPaintingByName(name);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET painting by clientId
    @GetMapping("/clientId/{clientId}")
    public ResponseEntity<List<Painting>> getPaintingByClientId(@PathVariable String clientId) {
        List<Painting> result = paintingService.getPaintingByClientId(clientId);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //GET painting by genre
    @GetMapping("/genre/{genre}")
    public ResponseEntity<List<Painting>> getPaintingByGenre(@PathVariable String genre) {
        List<Painting> result = paintingService.getPaintingByGenre(genre);
        if (result.isEmpty())
            return new ResponseEntity<>(result, HttpStatus.OK);
        return new ResponseEntity<>(result, HttpStatus.OK) ;
    }

    //UPDATE painting by id
    @PutMapping("/update/{id}")
    public ResponseEntity<Map<String, Object>> updatePainting(@RequestBody Painting painting, @PathVariable String id) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.updatePainting(id, painting);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

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
    public ResponseEntity<Map<String, Object>> soldPainting(@PathVariable String id) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.soldPainting(id);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        } else if (Objects.equals(status, "already sold")) {
            response.put("message","Painting already sold you dumb asses!");
            return new ResponseEntity<>(response, HttpStatus.OK);

        } else{
            response.put("message","Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }
    }

    //DELETE painting by id
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deletePainting(@PathVariable String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        String status = paintingService.deletePainting(id);
        switch (status) {
            case "not found" -> {
                return new ResponseEntity<>("Painting not found!", HttpStatus.OK);
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
    public ResponseEntity<Map<String, Object>> likeAdd(@PathVariable String id, @PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.likeAdd(id, userId);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);

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
    public ResponseEntity<Map<String, Object>> likeSubtract(@PathVariable String id, @PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();

        String status = paintingService.likeSubtract(id, userId);

        if (Objects.equals(status, "not found")){
            response.put("message","Painting not found!");
            return new ResponseEntity<>(response, HttpStatus.OK);

        } else if (Objects.equals(status, "zero")) {
            response.put("message","the painting already has zero likes, can't be negative!");
            return new ResponseEntity<>(response, HttpStatus.OK);

        } else if (Objects.equals(status, "not liked")) {
            response.put("message","the user didn't like the painting in the first place! you are a shitty coder!!");
            return new ResponseEntity<>(response, HttpStatus.OK);

        }
        else{
            response.put("message","Updated successfully!");
            return new ResponseEntity<>(response, HttpStatus.OK);
        }

    }


    //FRONT PAGE RECOMMENDATION
    @GetMapping("/front")
    public ResponseEntity<List<List<Painting>>> forYouPage() {
        List<List<Painting>> recommendation = new ArrayList<>();

        recommendation.add(paintingService.latestPaintings());
        recommendation.add(paintingService.mostLikedPaintings());

        return new ResponseEntity<>(recommendation, HttpStatus.OK) ;
    }

    //Filter
    @GetMapping("/filter")
    public ResponseEntity<List<Painting>> filter(
            @RequestParam (value = "minPrice", defaultValue = "0") String minPrice,
            @RequestParam (value = "maxPrice", defaultValue = "0") String maxPrice,
            @RequestParam (value = "minSellerRating", defaultValue = "0") String minSellerRating,
            @RequestParam (value = "type", defaultValue = "0") String type,
            @RequestParam (value = "genre", defaultValue = "0") String genre) {


return null;
    }

}
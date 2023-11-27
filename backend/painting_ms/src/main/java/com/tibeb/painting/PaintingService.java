package com.tibeb.painting;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;

import io.imagekit.sdk.exceptions.*;
import io.imagekit.sdk.models.FileCreateRequest;
import io.imagekit.sdk.models.results.Result;
import io.imagekit.sdk.ImageKit;
import io.imagekit.sdk.config.Configuration;

@Service
public class PaintingService {
    @Autowired
    private PaintingRepository paintingRepository;
    @Autowired
    private MongoTemplate mongoTemplate;

    //Setting keys and endpoint for the painting image api
    @Value("${PublicKey}")
    private String publicKey;
    @Value("${PrivateKey}")
    private String privateKey;
    @Value("${UrlEndpoint}")
    private String urlEndpoint;

    public PaintingService() {}

    //Add image
    public String addImage(String id, MultipartFile file) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        //IMAGE upload configuration
        ImageKit imageKit = ImageKit.getInstance();
        Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
        imageKit.setConfig(config);

        // Upload the original image
        FileCreateRequest fileCreateRequest = new FileCreateRequest(file.getBytes(), id + ".jpg");

        Result result = ImageKit.getInstance().upload(fileCreateRequest);

        // Save the image URL and file ID to the painting model
        Painting painting = paintingRepository.findById(id).orElse(null);
        if (painting != null) {
            painting.setImageLink(result.getUrl());
            painting.setImageId(result.getFileId());
            paintingRepository.save(painting);
            return "added";
        }
        return "not found";
    }

    //POST new painting
    public String addPainting(Painting painting) throws IOException {
        painting.setImageLink(null);
        //check if name already exists
        Optional<Painting> optionalPainting = paintingRepository.findByName(painting.getName());

        if (optionalPainting.isEmpty()) {

            //attributes that can not be changed
            painting.setId(null);
            painting.setImageLink(null);
            painting.setImageId(null);
            painting.setSold(false);
            painting.setDateAdded(LocalDateTime.now());
            painting.setLikes(0);
            painting.setListOfIdThatLikedThePainting(new ArrayList<>());
            painting.setLikedByUser(false);

            paintingRepository.save(painting);
            return "added";
        }
        else {
            return "name";
        }
    }


    //SEARCH AND FILTER

    //GET all paintings
    public List<Painting> getAllPaintings() {
        return paintingRepository.findAll();
    }

    //GET all paintings with likes
    public List<Painting> getAllPaintingsWithLikes(String userId) {
        return this.getListWithLikes(paintingRepository.findAll(), userId);
    }

    //GET paintings with likes only
    public List<Painting> getPaintingsWithLikesOnly(String userId) {
        List<Painting> paintingList = this.getListWithLikes(paintingRepository.findAll(), userId);
        List<Painting> paintingsWhichAreLiked = new ArrayList<>();

        for (Painting painting : paintingList){
            if (painting.getListOfIdThatLikedThePainting().contains(userId))
                paintingsWhichAreLiked.add(painting);
        }
        return paintingsWhichAreLiked;
    }

    //GET  painting by ID
    public Optional<Painting> getPaintingById(String id, String userId) {
        Optional<Painting> paintingOptional = paintingRepository.findById(id);
        return paintingOptional.map(painting -> {
            if (painting.getListOfIdThatLikedThePainting().contains(userId)) {
                painting.setLikedByUser(true);
            }
            return painting;
        });
    }

    //search by partial name of the title
    public List<Painting> getPaintingByName(String partialString, String userId) {
        Query query = new Query();
        Pattern pattern = Pattern.compile(".*" + partialString + ".*", Pattern.CASE_INSENSITIVE);
        query.addCriteria(Criteria.where("name").regex(pattern));

        List<Painting> paintings = this.getListWithLikes(mongoTemplate.find(query, Painting.class), userId);

        return paintings;
    }

    //search by clientId
    public List<Painting> getPaintingByClientId(String partialString, String userId) {
        Optional<List<Painting>> optionalPaintingList = paintingRepository.findByClientId(partialString);

        if (optionalPaintingList.isEmpty())
            return null;

        return this.getListWithLikes(optionalPaintingList.get(), userId);
    }

    //search by partial name of the genre
    public List<Painting> getPaintingByGenre(String partialString, String userId) {
        partialString = partialString.toUpperCase();
        Query query = new Query();
        query.addCriteria(Criteria.where("genre").regex(".*" + partialString + ".*"));
        return this.getListWithLikes(mongoTemplate.find(query, Painting.class), userId);
    }
    
    //Price filter
    public List<Painting> getPaintingByPrice(double min, double max, String userId) {
        Optional<List<Painting>> paintings;

        if (min == 0 && max == 0) {
            paintings = Optional.of(paintingRepository.findAll());
        } else if (min == 0) {
            paintings = paintingRepository.findByPriceLessThanEqual(max);
        } else if (max == 0) {
            paintings = paintingRepository.findByPriceGreaterThanEqual(min);
        } else {
            paintings = paintingRepository.findByPriceBetween(min, max);
        }

        if (paintings.isEmpty())
            return null;

        return this.getListWithLikes(paintings.get(), userId);
    }

//    //Seller rating filter
//    public Optional<List<Painting>> getPaintingBySellerRating(double rating) {
//        return paintingRepository.findBySellerRatingGreaterThanEqual(rating);
//    }

    //search by partial name of the type
    public List<Painting> getPaintingByType(String partialString) {
        Query query = new Query();
        query.addCriteria(Criteria.where("type").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
    }

    //SEARCH AND FILTER END

    //UPDATE painting using id
    public String updatePainting(String id, Painting painting) {
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        Painting backUp = optionalPainting.get(); // saving a backup
        paintingRepository.deleteById(id);

        Optional<Painting> nameCheck = paintingRepository.findByName(painting.getName());
        if(nameCheck.isEmpty()){

            // attributes that can not be changed
            painting.setId(backUp.getId());
            painting.setImageLink(backUp.getImageLink());
            painting.setImageId(backUp.getImageId());
            painting.setSold(backUp.isSold());
            painting.setDateAdded(backUp.getDateAdded());
            painting.setLikes(backUp.getLikes());
            painting.setListOfIdThatLikedThePainting(backUp.listOfIdThatLikedThePainting);
            painting.setLikedByUser(backUp.isLikedByUser());

            paintingRepository.save(painting); // updated
            return "updated";
        }
        else {
            paintingRepository.save(backUp); // saving old painting
            return "name";
        }
    }

    //when painting is sold
    public String soldPainting(String id) {

        //Check if the painting exists
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        //saving a backup
        Painting painting = optionalPainting.get();

        //checking if it is already sold
        if (painting.isSold())
            return "already sold";

        painting.setSold(true);

        //delete old painting
        paintingRepository.deleteById(id);

        //save updated painting
        paintingRepository.save(painting);
        return "Updated Successfully!";
    }

    //DELETE painting by id
    public String deletePainting(String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if(optionalPainting.isPresent()){
            //IMAGE upload configuration
            ImageKit imageKit = ImageKit.getInstance();
            Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
            imageKit.setConfig(config);

            //DELETE image from db
            try{
                imageKit.deleteFile(optionalPainting.get().getImageId());
            } catch (BadRequestException e) {
                //DELETE the painting from db
                paintingRepository.deleteById(id);
                return "empty";
            }

            //DELETE the painting from db
            paintingRepository.deleteById(id);

            return "deleted";
        }else {
            return "not found";
        }
    }

    //add a like
    public String likeAdd(String id, String userId) {

        //Check if the painting exists
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        //saving a backup
        Painting painting = optionalPainting.get();
        painting.setLikes((painting.getLikes()) + 1);

        if (painting.listOfIdThatLikedThePainting.contains(userId))
            return "already liked";

        painting.listOfIdThatLikedThePainting.add(userId);

        //delete old painting
        paintingRepository.deleteById(id);

        //save updated painting
        paintingRepository.save(painting);
        return "Updated Successfully!";
    }

    //subtract a like
    public String likeSubtract(String id, String userId) {

        //Check if the painting exists
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        //saving a backup
        Painting painting = optionalPainting.get();

        if (painting.getLikes() == 0)
            return "zero";

        painting.setLikes((painting.getLikes()) - 1);

        if (!painting.listOfIdThatLikedThePainting.contains(userId))
            return "not liked";

        painting.listOfIdThatLikedThePainting.remove(userId);

        //delete old painting
        paintingRepository.deleteById(id);

        //save updated painting
        paintingRepository.save(painting);
        return "Updated Successfully!";
    }

    //FRONT PAGE RECOMMENDATION

    //latest paintings
    public List<Painting> latestPaintings() {
        //Getting 10 of the newest paintings
        PageRequest pageRequest = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "dateAdded"));
        return paintingRepository.findAll(pageRequest).getContent();
    }

    //most liked
    public List<Painting> mostLikedPaintings() {
        //Getting 10 of the most liked paintings
        PageRequest pageRequest = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "likes"));
        return paintingRepository.findAll(pageRequest).getContent();
    }

    //high rating
    public List<Painting> highRatings() {
        //Getting the 10 highest rated paintings
        PageRequest pageRequest = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "rating"));
        return paintingRepository.findAll(pageRequest).getContent();
    }

    // take this to user ms
//    //popular painters
//    public List<Painting> popularPainters() {
//        //Getting 10 of the popular painters
//        PageRequest pageRequest = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "dateAdded"));
//        return paintingRepository.findAll(pageRequest).getContent();
//    }


    //Useful methods to avoid redundancy
    public List<Painting> getListWithLikes(List<Painting> paintingList, String userId) {
        if (paintingList.isEmpty())
            return null;

        for (Painting painting : paintingList){
            if (painting.getListOfIdThatLikedThePainting().contains(userId))
                painting.setLikedByUser(true);
        }
        return paintingList;
    }
}

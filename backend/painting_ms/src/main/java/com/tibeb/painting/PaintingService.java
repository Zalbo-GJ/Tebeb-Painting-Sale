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
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

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
            paintingRepository.save(painting);
            return "added";
        }
        else {
            return "name";
        }
    }

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
    public Optional<Painting> getPaintingById(String id) {
        return paintingRepository.findById(id);
    }

    //search by partial name of the title
    public List<Painting> getPaintingByName(String partialString) {
        Query query = new Query();
        Pattern pattern = Pattern.compile(".*" + partialString + ".*", Pattern.CASE_INSENSITIVE);
        query.addCriteria(Criteria.where("name").regex(pattern));
        return mongoTemplate.find(query, Painting.class);
    }

    //search by clientId
    public List<Painting> getPaintingByClientId(String partialString) {
        Optional<List<Painting>> optionalPaintingList = paintingRepository.findByClientId(partialString);

        return optionalPaintingList.orElse(new ArrayList<>());

//        Query query = new Query();
//        query.addCriteria(Criteria.where("clientId").regex(".*" + partialString + ".*"));
//        return mongoTemplate.find(query, Painting.class);
    }

    //search by partial name of the genre
    public List<Painting> getPaintingByGenre(String partialString) {
        partialString = partialString.toUpperCase();

        if (partialString.equals("0"))
            return this.getAllPaintings();

        Query query = new Query();
        query.addCriteria(Criteria.where("genre").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
    }

    //search by partial name of the type
    public List<Painting> getPaintingByType(String partialString) {
        Query query = new Query();

        if (partialString.equals("0")){
            return paintingRepository.findAll();
        }


        query.addCriteria(Criteria.where("type").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
    }

    //Price filter
    public List<Painting> getPaintingByPrice(int min, int max) {
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

        return paintings.orElse(new ArrayList<>());

    }

    //Seller rating filter
    public List<Painting> getPaintingBySellerRating(int rating) {
        Optional<List<Painting>> paintings;

        if (rating == 0)
            return this.getAllPaintings();

        paintings = paintingRepository.findBySellerRating(rating);

        return paintings.orElse(new ArrayList<>());
    }

    //UPDATE painting using id
    public String updatePainting(String id, Painting painting) {
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        Painting backUp = optionalPainting.get(); // saving a backup
        paintingRepository.deleteById(id);
        Optional<Painting> nameCheck = paintingRepository.findByName(painting.getName());
        if(nameCheck.isEmpty()){
            // attributes that are only allowed to be changed
            backUp.setName(painting.getName());
            backUp.setClientId(painting.getClientId());
            backUp.setArtistName(painting.getArtistName());
            backUp.setWidth(painting.getWidth());
            backUp.setLength(painting.getLength());
            backUp.setGenre(painting.getGenre());
            backUp.setType(painting.getType());
            backUp.setDescription(painting.getDescription());

            paintingRepository.save(backUp); // updated
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

    //update seller rating (to be used by the user management ms)
    public String updateSellerRating(String clientId, int rating) {
        String response = "";
        List<Painting> paintingList = this.getPaintingByClientId(clientId);
        if (paintingList.isEmpty())
            return null;

        for(Painting painting : paintingList){
            painting.setSellerRating(rating);
            response = this.updatePainting(painting.getId(),painting);
        }
        return response;
    }

    //DELETE movie by id
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

    //Useful methods to avoid redundancy
    public List<Painting> getListWithLikes(List<Painting> paintingList, String userId) {
        if (paintingList.isEmpty())
            return new ArrayList<>();

        for (Painting painting : paintingList){
            if (painting.getListOfIdThatLikedThePainting().contains(userId))
                painting.setLikedByUser(true);
        }
        return paintingList;
    }

    // take this to user ms
//    //popular painters
//    public List<Painting> popularPainters() {
//        //Getting 10 of the popular painters
//        PageRequest pageRequest = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "dateAdded"));
//        return paintingRepository.findAll(pageRequest).getContent();
//    }

    //Filter
    public List<Painting> filter (int minPrice, int maxPrice, int minSellerRating, List<String> type, List<String> genre){

        List<Painting> priceFiltered = new ArrayList<>();
        List<Painting> ratingFiltered = new ArrayList<>();
        List<Painting> typeFiltered = new ArrayList<>();
        List<Painting> genreFiltered = new ArrayList<>();

        //price filter
        List<Painting> priceFilter = this.getPaintingByPrice(minPrice, maxPrice);
        if (priceFilter.isEmpty())
            return new ArrayList<>();

        priceFiltered.addAll(priceFilter);


        //seller rating filter
        List<Painting> sellerRatingFilter = this.getPaintingBySellerRating(minSellerRating);
        if (sellerRatingFilter.isEmpty())
            return new ArrayList<>();

        ratingFiltered.addAll(sellerRatingFilter);


        //Type filter
        List<Painting> typeFilter = new ArrayList<>();

        if (!(type == null)){
            for (String type1 : type){
                typeFilter.addAll(this.getPaintingByType(type1));
            }
            if (typeFilter.isEmpty())
                return new ArrayList<>();
            typeFiltered.addAll(typeFilter);
        } else {
            typeFiltered.addAll(this.getAllPaintings());
        }

        //Genre filter
        List<Painting> genreFilter = new ArrayList<>();

        if (!(genre == null)){
            for (String genre1 : genre){
                genreFilter.addAll(this.getPaintingByGenre(genre1));
            }
            if (genreFilter.isEmpty())
                return new ArrayList<>();
            genreFiltered.addAll(genreFilter);
        } else {
            genreFiltered.addAll(this.getAllPaintings());
        }

        //Filter all by painting id
        List<Painting> filtered = filterByPaintingId(priceFiltered, ratingFiltered, typeFiltered, genreFiltered);

        //later return with likes
        return filtered;

    }

    //filter by id
    private List<Painting> filterByPaintingId(List<Painting> list1, List<Painting> list2, List<Painting> list3, List<Painting> list4) {
        Set<String> ids1 = list1.stream().map(Painting::getId).collect(Collectors.toSet());
        Set<String> ids2 = list2.stream().map(Painting::getId).collect(Collectors.toSet());
        Set<String> ids3 = list3.stream().map(Painting::getId).collect(Collectors.toSet());
        Set<String> ids4 = list4.stream().map(Painting::getId).collect(Collectors.toSet());

        ids1.retainAll(ids2);
        ids1.retainAll(ids3);
        ids1.retainAll(ids4);

        List<Painting> filtered = new ArrayList<>();
        for (Painting painting : list1) {
            if (ids1.contains(painting.getId())) {
                filtered.add(painting);
            }
        }
        return filtered;
    }
}

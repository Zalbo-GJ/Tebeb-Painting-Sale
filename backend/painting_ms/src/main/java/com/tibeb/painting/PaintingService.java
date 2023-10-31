package com.tibeb.painting;

import io.imagekit.sdk.exceptions.*;
import io.imagekit.sdk.models.FileCreateRequest;
import io.imagekit.sdk.models.results.Result;
import org.bson.BsonBinarySubType;
import org.bson.types.Binary;
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

import io.imagekit.sdk.ImageKit;
import io.imagekit.sdk.config.Configuration;
import io.imagekit.sdk.utils.Utils;

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

    //UPDATE add image of painting
    public String addImage(String id, MultipartFile file) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        //IMAGE upload configuration
        ImageKit imageKit = ImageKit.getInstance();
        Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
        imageKit.setConfig(config);

        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        //upload the byte[] of the multipart file and set the name to the painting id for later retrieval
        FileCreateRequest fileCreateRequest =new FileCreateRequest(file.getBytes(),  id + ".jpg");
        Result result=ImageKit.getInstance().upload(fileCreateRequest);

        //retrieve the painting
        Painting painting = optionalPainting.get();

        //save the image url to the painting model
        painting.setImageLink(result.getUrl());

        //save the file id for deletion
        painting.setImageId(result.getFileId());

        //DELETE old and save the updated painting model
        paintingRepository.deleteById(id);
        paintingRepository.save(painting);
        return "added";
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
        List<Painting> paintingList = paintingRepository.findAll();
        if (paintingList.isEmpty())
            return null;
        return paintingList;
    }

    //GET  painting by ID
    public Optional<Painting> getPaintingById(String id) {
        return paintingRepository.findById(id);
    }

    //search by partial name of the title
    public List<Painting> getPaintingByName(String partialString) {
        Query query = new Query();
        query.addCriteria(Criteria.where("name").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
    }

    //search by partial name of the artist
    public List<Painting> getPaintingByArtist(String partialString) {
        Query query = new Query();
        query.addCriteria(Criteria.where("artist").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
    }

    //search by partial name of the genre
    public List<Painting> getPaintingByGenre(String partialString) {
        Query query = new Query();
        query.addCriteria(Criteria.where("genre").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
    }

    //search by partial name of the type
    public List<Painting> getPaintingByType(String partialString) {
        Query query = new Query();
        query.addCriteria(Criteria.where("type").regex(".*" + partialString + ".*"));
        return mongoTemplate.find(query, Painting.class);
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
            backUp.setArtist(painting.getArtist());
            backUp.setWidth(painting.getWidth());
            backUp.setHeight(painting.getHeight());
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
        painting.setSold(true);

        //delete old painting
        paintingRepository.deleteById(id);

        //save updated painting
        paintingRepository.save(painting);
        return "Updated Successfully!";
    }

    //DELETE movie by id
    public String deletePainting(String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if(optionalPainting.isPresent()){
            //IMAGE upload configuration
            ImageKit imageKit = ImageKit.getInstance();
            Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
            imageKit.setConfig(config);

            //DELETE the painting from db
            paintingRepository.deleteById(id);

            //DELETE image from db
            try{
                imageKit.deleteFile(optionalPainting.get().getImageId());
            } catch (BadRequestException e) {
                return "empty";
            }

            return "deleted";
        }else {
            return "not found";
        }
    }

    //add a like
    public String likeAdd(String id) {

        //Check if the painting exists
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        //saving a backup
        Painting painting = optionalPainting.get();
        painting.setLikes((painting.getLikes()) + 1);

        //delete old painting
        paintingRepository.deleteById(id);

        //save updated painting
        paintingRepository.save(painting);
        return "Updated Successfully!";
    }

    //subtract a like
    public String likeSubtract(String id) {

        //Check if the painting exists
        Optional<Painting> optionalPainting = paintingRepository.findById(id);
        if (optionalPainting.isEmpty())
            return "not found";

        //saving a backup
        Painting painting = optionalPainting.get();
        painting.setLikes((painting.getLikes()) - 1);

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

    // take this to user ms
//    //popular painters
//    public List<Painting> popularPainters() {
//        //Getting 10 of the popular painters
//        PageRequest pageRequest = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "dateAdded"));
//        return paintingRepository.findAll(pageRequest).getContent();
//    }

}

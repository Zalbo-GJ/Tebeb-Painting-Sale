package com.tibeb.userManagement.client;

import com.tibeb.userManagement.auth.JwtUtil;
import com.tibeb.userManagement.dto.LoginReq;
import com.tibeb.userManagement.dto.RegisterForm;
import com.tibeb.userManagement.dto.PaintingInfo;
import com.tibeb.userManagement.user.model.User;
import io.imagekit.sdk.ImageKit;
import io.imagekit.sdk.config.Configuration;
import io.imagekit.sdk.exceptions.*;
import io.imagekit.sdk.models.FileCreateRequest;
import io.imagekit.sdk.models.results.Result;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Service
public class ClientService {

    @Autowired
    private ClientRepository clientRepository;
    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Value("${app.secretKey}")
    private String SECRET_KEY;
    @Value("${paintingURL}")
    private String paintingURL;

    //Setting keys and endpoint for the image api
    @Value("${PublicKey}")
    private String publicKey;
    @Value("${PrivateKey}")
    private String privateKey;
    @Value("${UrlEndpoint}")
    private String urlEndpoint;

    //Get id from token
    public String getIdFromToken (String authorizationHeader){
        String bearerToken = authorizationHeader.substring(7);
        return jwtUtil.getUserId(bearerToken);
    }

    //GET painting information from the painting MS
    public PaintingInfo paintingInfo (String paintingId) {
        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            paintingInfoResponseEntity = restTemplate
                    .getForEntity( urlEndpoint + "/api/paint/id/" + paintingId, PaintingInfo.class);
        } catch (HttpStatusCodeException e) {
            return null;
        }
        return paintingInfoResponseEntity.getBody();
    }

    //update seller rating
    public String updateSellerRating(String clientId, int rating) {
        String updateRatingUrl = urlEndpoint + "/update-rating/" + clientId + "/" + rating;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        RestTemplate restTemplate = new RestTemplate();

        ResponseEntity<String> response = restTemplate.exchange(
                updateRatingUrl,
                HttpMethod.PUT,
                entity,
                String.class
        );

        if (response.getStatusCode() == HttpStatus.OK) {
            return "updated";
        } else if (response.getStatusCode() == HttpStatus.NOT_FOUND) {
            return "not found";
        } else {
            return "internal server error";
        }
    }

    //GET list of painting using the client ID information from the painting MS
    public List<PaintingInfo> listOfPaintingByClientId (String clientId) {
        ResponseEntity<PaintingInfo[]> paintingInfoResponseEntity;

        try {
            paintingInfoResponseEntity = restTemplate
                    .getForEntity(urlEndpoint + "/api/paint/clientId/" + clientId, PaintingInfo[].class);

            if (paintingInfoResponseEntity.getStatusCode().is2xxSuccessful()) {
                PaintingInfo[] paintingInfos = paintingInfoResponseEntity.getBody();
                return Optional.ofNullable(paintingInfos)
                        .map(Arrays::asList)
                        .orElse(Collections.emptyList());
            } else {
                return Collections.emptyList();
            }
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    //UPDATE add profile picture for client
    public String addProfilePicture(String id, MultipartFile file) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        //IMAGE upload configuration
        ImageKit imageKit = ImageKit.getInstance();
        Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
        imageKit.setConfig(config);

        Optional<Client> optionalClient = clientRepository.findById(id);
        if (optionalClient.isEmpty())
            return "not found";

        //upload the byte[] of the multipart file and set the name to the client id for later retrieval
        FileCreateRequest fileCreateRequest =new FileCreateRequest(file.getBytes(),  id + ".jpg");
        Result result=ImageKit.getInstance().upload(fileCreateRequest);

        //retrieve the client
        Client client = optionalClient.get();

        //save the image url to the client model
        client.setProfilePictureLink(result.getUrl());

        //save the file id for deletion
        client.setProfileImageId(result.getFileId());

        //DELETE old and save the updated client model
        clientRepository.deleteById(id);
        clientRepository.save(client);
        return "added";
    }

    //UPDATE add background picture for client
    public String addBackgroundPicture(String id, MultipartFile file) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        //IMAGE upload configuration
        ImageKit imageKit = ImageKit.getInstance();
        Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
        imageKit.setConfig(config);

        Optional<Client> optionalClient = clientRepository.findById(id);
        if (optionalClient.isEmpty())
            return "not found";

        //upload the byte[] of the multipart file and set the name to the client id for later retrieval
        FileCreateRequest fileCreateRequest =new FileCreateRequest(file.getBytes(),  id + ".jpg");
        Result result=ImageKit.getInstance().upload(fileCreateRequest);

        //retrieve the client
        Client client = optionalClient.get();

        //save the image url to the client model
        client.setBackgroundPictureLink(result.getUrl());

        //save the file id for deletion
        client.setBackgroundImageId(result.getFileId());

        //DELETE old and save the updated client model
        clientRepository.deleteById(id);
        clientRepository.save(client);
        return "added";
    }

    //CREATE client
    public String createClient(RegisterForm registerForm) {

        Client client = new Client();
        client.setFirstName(registerForm.getFirstName());
        client.setLastName(registerForm.getLastName());
        client.setEmail(registerForm.getEmail());
        client.setPassword(registerForm.getPassword());

        //attributed that cannot be set by the client
        client.setId(null);
        client.setRole(Client.Role.CLIENT);
        client.setFollowers(0);
        client.setRating(0);
        client.setNumberOfPeopleWhoHaveRated(0);
        client.setProfilePictureLink(null);
        client.setBackgroundPictureLink(null);
        client.setProfileImageId(null);
        client.setBackgroundImageId(null);
        client.setPaintingIdList(null);

        if (clientRepository.findByEmail(client.getEmail()).isPresent())
            return "email";

        // Hash the password before storing it
        String hashedPassword = passwordEncoder.encode(client.getPassword());
        client.setPassword(hashedPassword);

        //save the new painting
        clientRepository.save(client);
        return "added";
    }

    //Login
    public String login(LoginReq loginReq){
        Client client = getClientByEmail(loginReq.getEmail());
        if(client!= null){
            if(BCrypt.checkpw(loginReq.getPassword(), client.getPassword())){
                // Create claims for the token
                Claims claims = Jwts.claims().setSubject(client.getEmail());
                claims.put("client", client);

                // Generate the token
                String token = Jwts.builder()
                        .setClaims(claims)
                        .signWith(Keys.hmacShaKeyFor(SECRET_KEY.getBytes()), SignatureAlgorithm.HS256)
                        .compact();

                return token;
            }
            else{
                return  "password";
            }
        }
        else {
            return "client";
        }
    }

    //GET all clients
    public List<Client> getClients() {
        List<Client> clients = clientRepository.findAll();

        for (Client client : clients) {
            // Null out the password for each client
            client.setPassword(null);
        }

        return clients;
    }

    //GET client by ID
    public Client getClientById(String id) {
        Client client = clientRepository.findById(id).orElse(null);

        // Null out the password if the client is found
        if (client != null) {
            client.setPassword(null);
        }

        return client;
    }

    //GET client by email
    public Client getClientByEmail(String email) {
        Client client = clientRepository.findByEmail(email).orElse(null);

        // Null out the password if the client is found
        if (client != null) {
            client.setPassword(null);
        }

        return client;
    }

    //UPDATE name and email
    public String updateClient(String id, Client client) {

        //Check if client exists
        Client clientTempo = this.getClientById(id);
        if (clientTempo == null)
            return "client";

        //temporarily delete the client for checking purpose
        clientRepository.deleteById(id);

        //check if the changed email already exists
        Optional<Client> emailChecker;
        emailChecker = clientRepository.findByEmail(client.getEmail());
        if (emailChecker.isPresent()) {
            clientRepository.save(clientTempo);
            return "email";
        }

        //check if the changed phone already exists
        Optional<Client> phoneChecker;
        phoneChecker = clientRepository.findByEmail(client.getEmail());
        if (phoneChecker.isPresent()) {
            clientRepository.save(clientTempo);
            return "phone";
        }

        //These attributes cannot be updated here
        client.setId(id);
        client.setRole(Client.Role.CLIENT);
        client.setFollowers(clientTempo.getFollowers());
        client.setRating(clientTempo.getRating());
        client.setNumberOfPeopleWhoHaveRated(clientTempo.getNumberOfPeopleWhoHaveRated());
        client.setProfilePictureLink(client.getProfilePictureLink());
        client.setBackgroundPictureLink(clientTempo.getBackgroundPictureLink());
        client.setProfileImageId(clientTempo.getProfileImageId());
        client.setBackgroundImageId(clientTempo.getBackgroundImageId());
        client.setPaintingIdList(clientTempo.getPaintingIdList());

        //save the updated client
        clientRepository.save(client);
        return "updated";
    }

    //ADD painting to the bought painting list
    public String addPaintingToBoughtPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //delete user to update and upload the savedPainting
        clientRepository.deleteById(id);

        //add new painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(clientTempo.getSavedPaintingIdList());
        savedPaintings.add(paintingId);
        clientTempo.setSavedPaintingIdList(savedPaintings);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            restTemplate.put(paintingURL + "/api/paint/sold/" + paintingId, null);
        } catch (HttpClientErrorException e){
            return "painting";
        }

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //ADD painting to the painting list
    public String addPaintingToPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if client exists
        if (clientTempo == null)
            return "client";

        //delete client to update and upload the savedPainting
        clientRepository.deleteById(id);

        //add new painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(clientTempo.getPaintingIdList());
        savedPaintings.add(paintingId);
        clientTempo.setPaintingIdList(savedPaintings);

        //save updated client
        clientRepository.save(clientTempo);
        return "updated";
    }

    //REMOVE painting from painting list
    public String removePaintingFromPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if client exists
        if (clientTempo == null)
            return "client";

        List<String> savedPaintings = new ArrayList<>(clientTempo.getPaintingIdList());

        //check if the id is in the list
        if (!savedPaintings.equals(paintingId))
            return "no such painting";

        //remove painting from the painting id list
        savedPaintings.remove(paintingId);
        clientTempo.setPaintingIdList(savedPaintings);

        //save updated client
        clientRepository.deleteById(id);
        clientRepository.save(clientTempo);
        return "updated";
    }

    //ADD painting to the saved painting list
    public String addPaintingToSavedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //delete user to update and upload the savedPainting
        clientRepository.deleteById(id);

        //add new painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(clientTempo.getSavedPaintingIdList());
        savedPaintings.add(paintingId);
        clientTempo.setSavedPaintingIdList(savedPaintings);

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //REMOVE painting from the saved painting list
    public String removePaintingFromSavedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //delete user to update and upload the savedPainting
        clientRepository.deleteById(id);

        //remove painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(clientTempo.getSavedPaintingIdList());
        savedPaintings.remove(paintingId);
        clientTempo.setSavedPaintingIdList(savedPaintings);

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //ADD painting to the liked painting list
    public String addPaintingToLikedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //add new painting to the saved painting id list
        List<String> likedPaintings = new ArrayList<>(clientTempo.getLikedPaintingIdList());

        //check if it is already liked
        if (likedPaintings.contains(paintingId))
            return "already liked";

        likedPaintings.add(paintingId);
        clientTempo.setLikedPaintingIdList(likedPaintings);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            restTemplate.put(paintingURL + "/api/paint/like/add/" + paintingId, null);
        } catch (HttpClientErrorException e){
            return "painting";
        }

        //delete user to update and upload
        clientRepository.deleteById(id);

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //REMOVE painting to the liked painting list
    public String removePaintingFromLikedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //add new painting to the saved painting id list
        List<String> likedPaintings = new ArrayList<>(clientTempo.getLikedPaintingIdList());

        //check if it is already liked
        if (!likedPaintings.contains(paintingId))
            return "does not exist";

        likedPaintings.remove(paintingId);
        clientTempo.setLikedPaintingIdList(likedPaintings);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            restTemplate.put( paintingURL + "/api/paint/like/sub/" + paintingId, null);
        } catch (HttpClientErrorException e){
            return "painting";
        }

        //delete user to update and upload
        clientRepository.deleteById(id);

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //ADD followed painters to the following painters list
    public String addToFollowingPaintersList(String id, String clientId) {

        //Check client from client controller
        Client client = this.getClientById(clientId);
        if (client == null)
            return "client";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //add follower to the following painters id list
        List<String> followingPaintersList = new ArrayList<>(clientTempo.getFollowingPaintersList());

        //check if it is already followed
        if (followingPaintersList.contains(clientId))
            return "already followed";

        followingPaintersList.add(clientId);
        clientTempo.setFollowingPaintersList(followingPaintersList);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        //delete user to update and upload
        clientRepository.deleteById(id);

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //REMOVE followed painters to the following painters list
    public String removeFromFollowingPaintersList(String id, String clientId) {

        //Check client from client controller
        Client client = this.getClientById(clientId);
        if (client == null)
            return "client";

        Client clientTempo = this.getClientById(id);

        //Check if user exists
        if (clientTempo == null)
            return "user";

        //add follower to the following painters id list
        List<String> followingPaintersList = new ArrayList<>(clientTempo.getFollowingPaintersList());

        //check if it is already followed
        if (!followingPaintersList.contains(clientId))
            return "not followed";

        followingPaintersList.remove(clientId);
        clientTempo.setFollowingPaintersList(followingPaintersList);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        //delete user to update and upload
        clientRepository.deleteById(id);

        //save updated user
        clientRepository.save(clientTempo);
        return "updated";
    }

    //ADD follower
    public String addFollower(String id) {

        Client clientTempo = this.getClientById(id);

        //Check if client exists
        if (clientTempo == null)
            return "client";

        //add follower
        clientTempo.setFollowers(clientTempo.getFollowers() + 1);

        //check if user exists

            //write code...


        //delete client to update and upload the savedPainting
        clientRepository.deleteById(id);

        //save updated client
        clientRepository.save(clientTempo);
        return "updated";
    }

    //REMOVE follower
    public String removeFollower(String id) {

        Client clientTempo = this.getClientById(id);

        //Check if client exists
        if (clientTempo == null)
            return "client";

        //check if follower is 0
        if (clientTempo.getFollowers() == 0)
            return "zero";

        //add follower
        clientTempo.setFollowers(clientTempo.getFollowers() - 1);


        //delete client to update and upload the savedPainting
        clientRepository.deleteById(id);

        //save updated client
        clientRepository.save(clientTempo);
        return "updated";
    }

    //DELETE client
    public int deleteClient(String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        Optional<Client> optionalClient = clientRepository.findById(id);
        if(optionalClient.isPresent()){
            //IMAGE upload configuration
            ImageKit imageKit = ImageKit.getInstance();
            Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
            imageKit.setConfig(config);

            //DELETE image from db - both profile picture and background picture
            imageKit.deleteFile(optionalClient.get().getProfileImageId());
            imageKit.deleteFile(optionalClient.get().getBackgroundImageId());

            //DELETE the painting from db
            clientRepository.deleteById(id);

            return 1;
        }else {
            return 0;
        }
    }

    //Rating
    public String updateAverageRating(int rating, String id) {
        // Ensure the rating is within the valid range (1 to 5)
        if (rating < 1 || rating > 5)
            return "Invalid rating";

        Optional<Client> optionalClient = clientRepository.findById(id);
        if (optionalClient.isEmpty())
            return "client";

        Client client = optionalClient.get();

        client.setNumberOfPeopleWhoHaveRated(client.getNumberOfPeopleWhoHaveRated() + 1);

        double averageRating = ( ( client.getRating() * ( client.getNumberOfPeopleWhoHaveRated() - 1 ) ) + rating ) / (client.getNumberOfPeopleWhoHaveRated());

        client.setRating(averageRating);

        //update seller rating in all the sellers paintings BEGIN
        String response = this.updateSellerRating(id, rating);

        if (response.equals("internal server error")){
            return "internal server error";
        } else if (response.equals("not found"))
            return "no paintings found";

        clientRepository.deleteById(id);
        clientRepository.save(client);

        return "rating";
    }
}

package com.tibeb.userManagement.user;

import com.tibeb.userManagement.user.model.LoginForm;
import com.tibeb.userManagement.user.model.PaintingInfo;
import com.tibeb.userManagement.user.model.RegisterForm;
import com.tibeb.userManagement.client.Client;
import com.tibeb.userManagement.client.ClientController;
import com.tibeb.userManagement.user.auth.JwtUtil;
import com.tibeb.userManagement.user.model.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.apache.tomcat.util.http.fileupload.impl.FileSizeLimitExceededException;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import io.imagekit.sdk.exceptions.*;
import io.imagekit.sdk.models.FileCreateRequest;
import io.imagekit.sdk.models.results.Result;
import io.imagekit.sdk.ImageKit;
import io.imagekit.sdk.config.Configuration;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private ClientController clientController;
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;
    @Autowired
    private JwtUtil jwtUtil;

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

    //GET painting information from the painting MS
    public PaintingInfo paintingInfo (String paintingId) {
        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            paintingInfoResponseEntity = restTemplate
                    .getForEntity(paintingURL + "/api/paint/id/" + paintingId, PaintingInfo.class);
        } catch (HttpStatusCodeException e) {
            return null;
        }
        return paintingInfoResponseEntity.getBody();
    }

    //UPDATE add profile picture for client
    public String addProfilePicture(String id, MultipartFile file) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {

        //IMAGE upload configuration
        ImageKit imageKit = ImageKit.getInstance();
        Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
        imageKit.setConfig(config);

        Optional<User> optionalUser = userRepository.findById(id);
        if (optionalUser.isEmpty())
            return "not found";

        Result result;

        try {
            //upload the byte[] of the multipart file and set the name to the user id for later retrieval
            FileCreateRequest fileCreateRequest =new FileCreateRequest(file.getBytes(),  id + ".jpg");
            result=ImageKit.getInstance().upload(fileCreateRequest);
        } catch (FileSizeLimitExceededException e) {
            return "size";
        }

        //retrieve the user
        User user = optionalUser.get();

        //save the image url to the user model
        user.setProfilePictureLink(result.getUrl());

        //save the file id for deletion
        user.setProfileImageId(result.getFileId());

        //DELETE old and save the updated user model
        userRepository.deleteById(id);
        userRepository.save(user);
        return "added";
    }

    //CREATE user
    public String createUser(RegisterForm registerForm) {

        User user = new User();
        user.setEmail(registerForm.getEmail());
        user.setPassword(registerForm.getPassword());


        //attributed that cannot be set by the user
        user.setId(null);
        user.setRole(User.Role.USER);
        user.setProfilePictureLink(null);
        user.setProfileImageId(null);
        user.setSavedPaintingIdList(null);
        user.setBoughtPaintingIdList(null);
        user.setLikedPaintingIdList(null);
        user.setFollowingPaintersList(null);

        if (userRepository.findByEmail(user.getEmail()).isPresent())
            return "email";

        if (userRepository.findByPhoneNumber(user.getPhoneNumber()).isPresent())
            return "phone";

        if (userRepository.findByUserName(user.getUserName()).isPresent())
            return "username";

        // Hash the password before storing it
        String hashedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(hashedPassword);

        //save the new painting
        userRepository.save(user);

        // Generate JWT Token for the newly registered user
        String token = jwtUtil.createToken(user);

        return "created";
    }

//    //Phone number checker method
//    public static boolean isValidPhoneNumber(String phoneNumber) {
//        // Check if the phone number starts with a '+'
//        if (!phoneNumber.startsWith("+")) {
//            return false;
//        }
//
//        // Check the length of the phone number
//        if (phoneNumber.length() < 12 || phoneNumber.length() > 15) {
//            return false;
//        }
//
//        // Check the country code
//        String countryCode = phoneNumber.substring(1, 4);
//        if (!countryCode.equals("251")) {
//            return false;
//        }
//
//        // Additional checks can be added here if needed
//
//        // If all checks pass, the phone number is valid
//        return true;
//    }

//    //Email checker method
//    public static boolean isValidEmail(String email) {
//        // Regular expression pattern for email validation
//        String emailPattern = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
//
//        // Create a Pattern object with the email pattern
//        Pattern pattern = Pattern.compile(emailPattern);
//
//        // Check if the email matches the pattern
//        return pattern.matcher(email).matches();
//    }

    //Login
    public String login(LoginForm loginForm){
        User user = getUserByEmail(loginForm.getEmail());
        if(user!= null){
            if(BCrypt.checkpw(loginForm.getPassword(), user.getPassword())){
                // Create claims for the token
                Claims claims = Jwts.claims().setSubject(user.getEmail());
                claims.put("user", user);

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
            return "user";
        }
    }

    //GET all users
    public List<User> getUsers() {
        List<User> users = userRepository.findAll();

        for (User user : users) {
            // Null out the password for each user
            user.setPassword(null);
        }

        return users;
    }

    //GET user by ID
    public User getUserById(String id) {
        User user = userRepository.findById(id).orElse(null);

        // Null out the password if the user is found
        if (user != null) {
            user.setPassword(null);
        }

        return user;
    }

    //GET user by email
    public User getUserByEmail(String email) {
        User user = userRepository.findByEmail(email).orElse(null);

        // Null out the password if the user is found
        if (user != null) {
            user.setPassword(null);
        }

        return user;
    }

    //UPDATE name and email
    public String updateUser(String id, User user) {

        //Check if user exists
        User userTempo = this.getUserById(id);
        if (userTempo == null)
            return "user";

//        //validate email structure
//        boolean email = isValidEmail(user.getEmail());
//        if (!email)
//            return "invalid email";

//        //validate phone number structure
//        boolean phone = isValidPhoneNumber(user.getPhoneNumber());
//        if (!phone)
//            return "invalid phone";

        //temporarily delete the user for checking purpose
        userRepository.deleteById(id);

        //check if the changed email already exists
        Optional<User> checker;
        checker = userRepository.findByEmail(user.getEmail());
        if (checker.isPresent()) {
            userRepository.save(userTempo);
            return "email";
        }

        //check if the changed phone already exists
        Optional<User> phoneChecker;
        phoneChecker = userRepository.findByEmail(user.getEmail());
        if (phoneChecker.isPresent()) {
            userRepository.save(userTempo);
            return "phone";
        }

        //These attributes cannot be updated here
        user.setId(id);
        user.setRole(User.Role.USER);
        user.setProfilePictureLink(userTempo.getProfilePictureLink());
        user.setProfileImageId(userTempo.getProfileImageId());
        user.setSavedPaintingIdList(userTempo.getSavedPaintingIdList());
        user.setBoughtPaintingIdList(userTempo.getBoughtPaintingIdList());
        user.setLikedPaintingIdList(userTempo.getLikedPaintingIdList());
        user.setFollowingPaintersList(userTempo.getFollowingPaintersList());

        //save the updated user
        userRepository.save(user);
        return "updated";
    }

    //ADD painting to the bought painting list
    public String addPaintingToBoughtPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //delete user to update and upload the savedPainting
        userRepository.deleteById(id);

        //add new painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(userTempo.getSavedPaintingIdList());
        savedPaintings.add(paintingId);
        userTempo.setSavedPaintingIdList(savedPaintings);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            restTemplate.put(paintingURL + "/api/paint/sold/" + paintingId, null);
        } catch (HttpClientErrorException e){
            return "painting";
        }

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //ADD painting to the saved painting list
    public String addPaintingToSavedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //delete user to update and upload the savedPainting
        userRepository.deleteById(id);

        //add new painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(userTempo.getSavedPaintingIdList());
        savedPaintings.add(paintingId);
        userTempo.setSavedPaintingIdList(savedPaintings);

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //REMOVE painting from the saved painting list
    public String removePaintingFromSavedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //delete user to update and upload the savedPainting
        userRepository.deleteById(id);

        //remove painting to the saved painting id list
        List<String> savedPaintings = new ArrayList<>(userTempo.getSavedPaintingIdList());
        savedPaintings.remove(paintingId);
        userTempo.setSavedPaintingIdList(savedPaintings);

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //ADD painting to the liked painting list
    public String addPaintingToLikedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //add new painting to the saved painting id list
        List<String> likedPaintings = new ArrayList<>(userTempo.getLikedPaintingIdList());

        //check if it is already liked
        if (likedPaintings.contains(paintingId))
            return "already liked";

        likedPaintings.add(paintingId);
        userTempo.setLikedPaintingIdList(likedPaintings);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            restTemplate.put(paintingURL + "/api/paint/like/add/" + paintingId, null);
        } catch (HttpClientErrorException e){
            return "painting";
        }

        //delete user to update and upload
        userRepository.deleteById(id);

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //REMOVE painting to the liked painting list
    public String removePaintingFromLikedPaintingList(String id, String paintingId) {

        //Check painting from the painting MS
        PaintingInfo paintingInfo = this.paintingInfo(paintingId);
        if (paintingInfo == null)
            return "painting";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //add new painting to the saved painting id list
        List<String> likedPaintings = new ArrayList<>(userTempo.getLikedPaintingIdList());

        //check if it is already liked
        if (!likedPaintings.contains(paintingId))
            return "does not exist";

        likedPaintings.remove(paintingId);
        userTempo.setLikedPaintingIdList(likedPaintings);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        try {
            restTemplate.put( paintingURL + "/api/paint/like/sub/" + paintingId, null);
        } catch (HttpClientErrorException e){
            return "painting";
        }

        //delete user to update and upload
        userRepository.deleteById(id);

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //ADD followed painters to the following painters list
    public String addToFollowingPaintersList(String id, String clientId) {

        //Check client from client controller
        Client client = clientController.getClientById(clientId).getBody();
        if (client == null)
            return "client";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //add follower to the following painters id list
        List<String> followingPaintersList = new ArrayList<>(userTempo.getFollowingPaintersList());

        //check if it is already followed
        if (followingPaintersList.contains(clientId))
            return "already followed";

        followingPaintersList.add(clientId);
        userTempo.setFollowingPaintersList(followingPaintersList);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        //delete user to update and upload
        userRepository.deleteById(id);

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //REMOVE followed painters to the following painters list
    public String removeFromFollowingPaintersList(String id, String clientId) {

        //Check client from client controller
        Client client = clientController.getClientById(clientId).getBody();
        if (client == null)
            return "client";

        User userTempo = this.getUserById(id);

        //Check if user exists
        if (userTempo == null)
            return "user";

        //add follower to the following painters id list
        List<String> followingPaintersList = new ArrayList<>(userTempo.getFollowingPaintersList());

        //check if it is already followed
        if (!followingPaintersList.contains(clientId))
            return "not followed";

        followingPaintersList.remove(clientId);
        userTempo.setFollowingPaintersList(followingPaintersList);

        ResponseEntity<PaintingInfo> paintingInfoResponseEntity;

        //delete user to update and upload
        userRepository.deleteById(id);

        //save updated user
        userRepository.save(userTempo);
        return "updated";
    }

    //DELETE user
    public String deleteUser(String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        Optional<User> optionalUser = userRepository.findById(id);
        
        //IMAGE upload configuration
        ImageKit imageKit = ImageKit.getInstance();
        Configuration config = new Configuration(publicKey, privateKey, urlEndpoint);
        imageKit.setConfig(config);

        if(optionalUser.isPresent()){


            //DELETE image from db
            try{
                imageKit.deleteFile(optionalUser.get().getProfileImageId());
            } catch (BadRequestException e) {
                //DELETE the user from db
                userRepository.deleteById(id);
                return "empty";
            }

            //DELETE the user from db
            userRepository.deleteById(id);
            return "deleted";
        }else {
            return "not found";
        }
    }
}
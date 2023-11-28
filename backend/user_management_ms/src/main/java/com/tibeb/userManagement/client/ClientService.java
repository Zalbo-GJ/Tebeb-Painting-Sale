package com.tibeb.userManagement.client;

import com.tibeb.userManagement.user.model.LoginForm;
import com.tibeb.userManagement.user.model.PaintingInfo;
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
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import java.util.regex.Pattern;

@Service
public class ClientService {

    @Autowired
    private ClientRepository clientRepository;
    @Autowired
    private RestTemplate restTemplate;

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
                    .getForEntity( urlEndpoint + "/api/paint/id/" + paintingId, PaintingInfo.class);
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
    public String createClient(Client client) {

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


        //editing the attributes
        client.setFirstName(client.getFirstName().toLowerCase());
        client.setLastName(client.getLastName().toLowerCase());
        client.setArtistName(client.getArtistName().toLowerCase());
        client.setEmail(client.getEmail().toLowerCase());

//        //checks if phone is valid using a method
//        boolean phone = isValidPhoneNumber(client.getPhoneNumber());
//        if (!phone)
//            return "phoneCheck";

        //checks if email is valid using a method
        boolean emailCheck = isValidEmail(client.getEmail());
        if (!emailCheck)
            return "emailCheck";

        if (clientRepository.findByEmail(client.getEmail()).isPresent())
            return "email";

        // hashing the password and saving it
        String hashedPassword = BCrypt.hashpw(client.getPassword(), BCrypt.gensalt());
        client.setPassword(hashedPassword);

        //save the new painting
        clientRepository.save(client);
        return "added";
    }

    //Phone number checker method
    public static boolean isValidPhoneNumber(String phoneNumber) {
        // Check if the phone number starts with a '+'
        if (!phoneNumber.startsWith("+")) {
            return false;
        }

        // Check the length of the phone number
        if (phoneNumber.length() < 12 || phoneNumber.length() > 15) {
            return false;
        }

        // Check the country code
        String countryCode = phoneNumber.substring(1, 4);
        if (!countryCode.equals("251")) {
            return false;
        }

        // Additional checks can be added here if needed

        // If all checks pass, the phone number is valid
        return true;
    }

    //Email checker method
    public static boolean isValidEmail(String email) {
        // Regular expression pattern for email validation
        String emailPattern = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";

        // Create a Pattern object with the email pattern
        Pattern pattern = Pattern.compile(emailPattern);

        // Check if the email matches the pattern
        return pattern.matcher(email).matches();
    }

    //Login
    public String login(LoginForm loginForm){
        Client client = getClientByEmail(loginForm.getEmail());
        if(client!= null){
            if(BCrypt.checkpw(loginForm.getPassword(), client.getPassword())){
                // Create claims for the token
                Claims claims = Jwts.claims().setSubject(client.getEmail());
                claims.put("clientId", client.getId());
                claims.put("email", client.getEmail());

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

    // GET clients by region
    public List<Client> getClientsByRegion(String region) {
        Optional<List<Client>> optionalClients = clientRepository.findByRegion(region);

        if (optionalClients.isPresent()) {
            List<Client> clients = optionalClients.get();

            for (Client client : clients) {
                // Null out the password for each client
                client.setPassword(null);
            }

            return clients;
        } else {
            // Return an empty list if no clients are found for the specified region
            return Collections.emptyList();
        }
    }

    //UPDATE name and email
    public String updateClient(String id, Client client) {

        //Check if client exists
        Client clientTempo = this.getClientById(id);
        if (clientTempo == null)
            return "client";

        //validate email structure
        boolean email = isValidEmail(client.getEmail());
        if (!email)
            return "invalid email";

//        //validate phone number structure
//        boolean phone = isValidPhoneNumber(client.getPhoneNumber());
//        if (!phone)
//            return "invalid phone";

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

        clientRepository.deleteById(id);
        clientRepository.save(client);

        return "rating";
    }
}

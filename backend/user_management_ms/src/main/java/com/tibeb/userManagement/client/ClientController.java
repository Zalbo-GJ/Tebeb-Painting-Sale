package com.tibeb.userManagement.client;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.tibeb.userManagement.LoginForm;
import com.tibeb.userManagement.user.User;
import io.imagekit.sdk.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/clients")
public class ClientController {

    @Autowired
    private ClientService clientService;

    //Login
    @PostMapping(value = "/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody LoginForm loginForm){
        Map<String, Object> response = new HashMap<>();
        switch (clientService.login(loginForm)) {
            case "user" -> {
                response.put("message", "user not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "password" -> {
                response.put("message", "password incorrect");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
        }
        String token = clientService.login(loginForm);
        response.put("token",token);
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //GOOGLE signup
    @PostMapping(value = "/register/{id_token}")
    public ResponseEntity<Map<String, Object>> register(@PathVariable String id_token){
        Map<String, Object> response = new HashMap<>();
        // Verify the ID token with Google
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                .setAudience(Collections.singletonList("159479957223-qka39ssrtraeilbuhv0a5r07sn43oemq.apps.googleusercontent.com"))
                .build();
        GoogleIdToken idToken;
        try {
            idToken = verifier.verify(id_token);
        } catch (GeneralSecurityException | IOException e) {
            response.put("message","invalid token");
            // Handle the exception
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }

        if (idToken == null) {
            response.put("message","invalid token");
            // Invalid ID token
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }

        // Get the client's email from the ID token
        String email = idToken.getPayload().getEmail();
        System.out.println(email);
        Client client = clientService.getClientByEmail(email);
        if(client != null){
            response.put("message","client found");
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
        Client client1 = null;
        client1.setEmail(email);
        client1.setRole(Client.Role.CLIENT);
        clientService.createClient(client1);

        response.put("email",email);
        response.put("role",client.getRole());
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //GOOGLE login
    @PostMapping(value = "/login-with-google/{id_token}")
    public ResponseEntity<Map<String, Object>> login(@PathVariable String id_token){
        Map<String, Object> response = new HashMap<>();
        // Verify the ID token with Google
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                .setAudience(Collections.singletonList("159479957223-qka39ssrtraeilbuhv0a5r07sn43oemq.apps.googleusercontent.com"))
                .build();
        GoogleIdToken idToken;
        try {
            idToken = verifier.verify(id_token);
        } catch (GeneralSecurityException | IOException e) {
            response.put("message","invalid token");
            // Handle the exception
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }

        if (idToken == null) {
            response.put("message","invalid token");
            // Invalid ID token
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }

        // Get the client's email from the ID token
        String email = idToken.getPayload().getEmail();
        System.out.println(email);
        Client client = clientService.getClientByEmail(email);
        if(client == null){
            response.put("message","client not found");
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
        response.put("email",email);
        response.put("role",client.getRole());
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //UPLOAD profile picture of client
    @PutMapping("/profile_picture/{id}")
    public ResponseEntity<Map<String, Object>> addProfilePicture(@RequestParam("image") MultipartFile image, @PathVariable String id) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        Map<String, Object> response = new HashMap<>();
        String r =clientService.addProfilePicture(id, image);

        switch (r) {
            case "not found" -> {
                response.put("message", "client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "client" -> {
                response.put("message", "failed to upload!");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
            case "added" -> {
                response.put("message", "uploaded successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            default -> {
                response.put("message", "unknown error");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

    //UPLOAD profile picture of client
    @PutMapping("/background_picture/{id}")
    public ResponseEntity<Map<String, Object>> addBackgroundPicture(@RequestParam("image") MultipartFile image, @PathVariable String id) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        Map<String, Object> response = new HashMap<>();
        String r =clientService.addBackgroundPicture(id, image);

        switch (r) {
            case "not found" -> {
                response.put("message", "client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "client" -> {
                response.put("message", "failed to upload!");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
            case "added" -> {
                response.put("message", "uploaded successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            default -> {
                response.put("message", "unknown error");
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

    //CREATE client
    @PostMapping
    public ResponseEntity<Map<String, Object>> createClient(@RequestBody Client client) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.createClient(client);
        switch (status) {
            case "name" -> {
                response.put("message","name");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "email" -> {
                response.put("message","email");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "phoneCheck" -> {
                response.put("message","invalid phone number : rewrite as +251xxxxxxxxx");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "emailCheck" -> {
                response.put("message","invalid email");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "added" -> {
                response.put("message","created");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message","Unknown error, BUG");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //GET all clients
    @GetMapping
    public ResponseEntity<List<Client>> getClients() {
        return new ResponseEntity<>(clientService.getClients(),HttpStatus.OK);
    }

    //GET client by ID
    @GetMapping("/{id}")
    public ResponseEntity<Client> getClientById(@PathVariable String id){
        return new ResponseEntity<>(clientService.getClientById(id),HttpStatus.OK);
    }

    //GET user by email
    @GetMapping("/email/{email}")
    public ResponseEntity<Client> getClientByEmail(@PathVariable String email){
        return new ResponseEntity<>(clientService.getClientByEmail(email),HttpStatus.OK);
    }

    //GET user by region
    @GetMapping("/region/{region}")
    public ResponseEntity<Client> getClientByRegion(@PathVariable String region){
        return new ResponseEntity<>(clientService.getClientByRegion(region),HttpStatus.OK);
    }

    //UPDATE name and email
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateClient(@PathVariable String id, @RequestBody Client client) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.updateClient(id, client);

        switch (status) {
            case "client" ->{
                response.put("message","Client not found");
                return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
            }
            case "email" ->{
                response.put("message","matching email found");
                return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
            }
            case "invalid email" ->{
                response.put("message","invalid email");
                return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
            }
            case "invalid phone" ->{
                response.put("message","invalid phone");
                return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
            }
            case "updated" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message","Unknown error");
        return new ResponseEntity<>(response,HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD painting to the painting list
    @PutMapping("/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingToPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.addPaintingToPaintingList(id, paintingid);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message","Unknown error");
        return new ResponseEntity<>(response ,HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD painting to the sold painting list
    @PutMapping("/sold/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingSoldToPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.addPaintingToPaintingList(id, paintingid);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" ->{
                response.put("message", "updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
            case "painting" ->{
                response.put("message", "Painting MS is not responding");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //REMOVE painting from the painting list
    @PutMapping("/remove/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> removePaintingFromSavedPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.removePaintingFromPaintingList(id, paintingid);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD follower
    @PutMapping("/follower/add/{clientId}")
    public ResponseEntity<Map<String, Object>> addFollower(@PathVariable String clientId) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.addFollower(clientId);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" ->{
                response.put("message", "updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //REMOVE follower
    @PutMapping("/follower/sub/{clientId}")
    public ResponseEntity<Map<String, Object>> removeFollower(@PathVariable String clientId) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.removeFollower(clientId);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" ->{
                response.put("message", "updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //DELETE client
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteClient(@PathVariable String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        int status = clientService.deleteClient(id);
        if (status == 0)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        else
            return new ResponseEntity<>("Deleted",HttpStatus.OK);
    }

    //Rating
    @PutMapping("/rating/{id}/{rating}")
    public ResponseEntity<Map<String, Object>> updateAverageRating(@PathVariable String id, @PathVariable int rating) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.updateAverageRating(rating, id);

        switch (status) {
            case "Invalid rating" ->{
                response.put("message", "Invalid rating! ( not integer or is not in between 1 - 4 )");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "rating" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message","Unknown error");
        return new ResponseEntity<>(response ,HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
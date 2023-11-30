package com.tibeb.userManagement.client;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.tibeb.userManagement.auth.JwtUtil;
import com.tibeb.userManagement.loginform.ErrorRes;
import com.tibeb.userManagement.loginform.LoginReq;
import com.tibeb.userManagement.loginform.LoginRes;
import com.tibeb.userManagement.loginform.RegisterForm;
import com.tibeb.userManagement.user.CustomUserDetailsService;
import com.tibeb.userManagement.user.model.User;
import io.imagekit.sdk.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
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
    @Autowired
    @Qualifier("customClientAuthenticationManager")
    private AuthenticationManager authenticationManager;
    @Autowired
    private CustomUserDetailsService customUserDetailsService;
    @Autowired
    private JwtUtil jwtUtil;

    @ResponseBody
    @GetMapping("/login")
    public ResponseEntity login(@RequestBody LoginReq loginReq)  {

        try {
            Authentication authentication =
                    authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(loginReq.getEmail(), loginReq.getPassword()));
            String email = authentication.getName();

            // get the user to extract the id
            Client client1 = clientService.getClientByEmail(email);

            Client client = new Client(email,"",client1.getId());
            String token = jwtUtil.createToken(client);
            LoginRes loginRes = new LoginRes(email,token);

            return ResponseEntity.ok(loginRes);

        }catch (BadCredentialsException e){
            ErrorRes errorResponse = new ErrorRes(HttpStatus.BAD_REQUEST,"Invalid username or password");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }catch (Exception e){
            ErrorRes errorResponse = new ErrorRes(HttpStatus.BAD_REQUEST, e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    //GOOGLE signup
    @PostMapping(value = "/register-with-google/{id_token}")
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
            return new ResponseEntity<>(response,HttpStatus.OK);
        }

        if (idToken == null) {
            response.put("message","invalid token");
            // Invalid ID token
            return new ResponseEntity<>(response,HttpStatus.OK);
        }

        // Get the client's email from the ID token
        String email = idToken.getPayload().getEmail();
        System.out.println(email);
        Client client = clientService.getClientByEmail(email);
        if(client != null){
            response.put("message","client found");
            return new ResponseEntity<>(response,HttpStatus.OK);
        }
        RegisterForm client1 = null;
        client1.setEmail(email);
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
            return new ResponseEntity<>(response,HttpStatus.OK);
        }

        if (idToken == null) {
            response.put("message","invalid token");
            // Invalid ID token
            return new ResponseEntity<>(response,HttpStatus.OK);
        }

        // Get the client's email from the ID token
        String email = idToken.getPayload().getEmail();
        System.out.println(email);
        Client client = clientService.getClientByEmail(email);
        if(client == null){
            response.put("message","client not found");
            return new ResponseEntity<>(response,HttpStatus.OK);
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
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "client" -> {
                response.put("message", "failed to upload!");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "added" -> {
                response.put("message", "uploaded successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            default -> {
                response.put("message", "unknown error");
                return new ResponseEntity<>(response, HttpStatus.OK);
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
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "client" -> {
                response.put("message", "failed to upload!");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "added" -> {
                response.put("message", "uploaded successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            default -> {
                response.put("message", "unknown error");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
    }

    //CREATE client
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> createClient(@RequestBody RegisterForm registerForm) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.createClient(registerForm);
        switch (status) {
            case "name" -> {
                response.put("message","name");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "email" -> {
                response.put("message","email");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "added" -> {
                response.put("message","created");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message","Unknown error, BUG");
        return new ResponseEntity<>(response, HttpStatus.OK);
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
    public ResponseEntity<List<Client>> getClientByRegion(@PathVariable String region){
        return new ResponseEntity<>(clientService.getClientsByRegion(region),HttpStatus.OK);
    }

    //UPDATE name and email
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateClient(@PathVariable String id, @RequestBody Client client) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.updateClient(id, client);

        switch (status) {
            case "client" ->{
                response.put("message","Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "email" ->{
                response.put("message","matching email found");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
            case "invalid email" ->{
                response.put("message","invalid email");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
            case "invalid phone" ->{
                response.put("message","invalid phone");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
            case "updated" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message","Unknown error");
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //ADD painting to the painting list
    @PutMapping("/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingToPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.addPaintingToPaintingList(id, paintingid);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message","Unknown error");
        return new ResponseEntity<>(response ,HttpStatus.OK);
    }

    //ADD painting to the sold painting list
    @PutMapping("/sold/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingSoldToPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.addPaintingToPaintingList(id, paintingid);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
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
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //REMOVE painting from the painting list
    @PutMapping("/remove/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> removePaintingFromSavedPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.removePaintingFromPaintingList(id, paintingid);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //ADD follower
    @PutMapping("/follower/add/{clientId}")
    public ResponseEntity<Map<String, Object>> addFollower(@PathVariable String clientId) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.addFollower(clientId);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" ->{
                response.put("message", "updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //REMOVE follower
    @PutMapping("/follower/sub/{clientId}")
    public ResponseEntity<Map<String, Object>> removeFollower(@PathVariable String clientId) {
        Map<String, Object> response = new HashMap<>();

        String status = clientService.removeFollower(clientId);

        switch (status) {
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "zero" ->{
                response.put("message", "It is already zero, you can't code!");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" ->{
                response.put("message", "updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response,HttpStatus.OK);
    }

    //DELETE client
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteClient(@PathVariable String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        int status = clientService.deleteClient(id);
        if (status == 0)
            return new ResponseEntity<>(HttpStatus.OK);
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
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "client" ->{
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "rating" ->{
                response.put("message","updated");
                return new ResponseEntity<>(response,HttpStatus.OK);
            }
        }
        response.put("message","Unknown error");
        return new ResponseEntity<>(response ,HttpStatus.OK);
    }
}
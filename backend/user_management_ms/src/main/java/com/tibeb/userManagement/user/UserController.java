package com.tibeb.userManagement.user;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.tibeb.userManagement.loginform.RegisterForm;
import com.tibeb.userManagement.loginform.ErrorRes;
import com.tibeb.userManagement.loginform.LoginReq;
import com.tibeb.userManagement.loginform.LoginRes;
import com.tibeb.userManagement.auth.JwtUtil;
import com.tibeb.userManagement.user.model.User;
import io.imagekit.sdk.exceptions.*;
import io.jsonwebtoken.Claims;
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
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private CustomUserDetailsService userDetailsService;
    @Autowired
    @Qualifier("customUserAuthenticationManager")
    private AuthenticationManager authenticationManager;
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
            User user1 = userService.getUserByEmail(email);

            User user = new User(email,"",user1.getId());
            String token = jwtUtil.createToken(user);
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
    @PostMapping(value = "/register/{id_token}")
    public ResponseEntity<Map<String, Object>> register(@PathVariable String name, @PathVariable String id_token) {
        Map<String, Object> response = new HashMap<>();
        // Verify the ID token with Google
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                .setAudience(Collections.singletonList("159479957223-qka39ssrtraeilbuhv0a5r07sn43oemq.apps.googleusercontent.com"))
                .build();
        GoogleIdToken idToken;
        try {
            idToken = verifier.verify(id_token);
        } catch (GeneralSecurityException | IOException e) {
            response.put("message", "invalid token");
            // Handle the exception
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }

        if (idToken == null) {
            response.put("message", "invalid token");
            // Invalid ID token
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }

        // Get the user's email from the ID token
        String email = idToken.getPayload().getEmail();
        System.out.println(email);
        User user = userService.getUserByEmail(email);
        if (user != null) {
            response.put("message", "user found");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }
        RegisterForm user1 = null;
        user1.setEmail(email);
        user1.setPassword("");
        userService.createUser(user1);

        response.put("email", email);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    //GOOGLE login
    @PostMapping(value = "/login-with-google/{id_token}")
    public ResponseEntity<Map<String, Object>> loginWithGoogle(@PathVariable String id_token) {
        Map<String, Object> response = new HashMap<>();
        // Verify the ID token with Google
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                .setAudience(Collections.singletonList("159479957223-qka39ssrtraeilbuhv0a5r07sn43oemq.apps.googleusercontent.com"))
                .build();
        GoogleIdToken idToken;
        try {
            idToken = verifier.verify(id_token);
        } catch (GeneralSecurityException | IOException e) {
            response.put("message", "invalid token");
            // Handle the exception
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }

        if (idToken == null) {
            response.put("message", "invalid token");
            // Invalid ID token
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }

        // Get the user's email from the ID token
        String email = idToken.getPayload().getEmail();
        System.out.println(email);
        User user = userService.getUserByEmail(email);
        if (user == null) {
            response.put("message", "user not found");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }
        response.put("email", email);
        response.put("role", user.getRole());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    //UPLOAD profile picture of user
    @PutMapping("/profile_picture/{id}")
    public ResponseEntity<Map<String, Object>> addProfilePicture(@RequestParam("image") MultipartFile image, @PathVariable String id) throws IOException, ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        Map<String, Object> response = new HashMap<>();
        String r = userService.addProfilePicture(id, image);

        switch (r) {
            case "not found" -> {
                response.put("message", "user not found");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "size" -> {
                response.put("message", "photo size is too big!");
                return new ResponseEntity<>(response, HttpStatus.OK);
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

    //CREATE user
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> createUser(@RequestBody RegisterForm registerForm) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.createUser(registerForm);
        switch (status) {
            case "name" -> {
                response.put("message", "name");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "email" -> {
                response.put("message", "email");
                return new ResponseEntity<>(response, HttpStatus.CONFLICT);
            }
            case "created" -> {
                response.put("message", registerForm.getEmail()+" created!");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "unknown error!");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //GET all users
    @GetMapping
    public ResponseEntity<List<User>> getUsers() {
        return new ResponseEntity<>(userService.getUsers(), HttpStatus.OK);
    }

    @GetMapping("id")
    public ResponseEntity<User> getUserById(@RequestHeader("Authorization") String authorizationHeader) {
        String id = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")){
            id = userService.getIdFromToken(authorizationHeader);
            return new ResponseEntity<>(userService.getUserById(id), HttpStatus.OK);
        } else {
            // Handle the case where the Authorization header doesn't contain a Bearer token
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }

    //GET user by email
    @GetMapping("/email/{email}")
    public ResponseEntity<User> getUserByEmail(@PathVariable String email) {
        return new ResponseEntity<>(userService.getUserByEmail(email), HttpStatus.OK);
    }

    //UPDATE name and email
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(@PathVariable String id, @RequestBody User user) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.updateUser(id, user);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
            }
            case "email" -> {
                response.put("message", "matching email found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "invalid email" -> {
                response.put("message", "invalid email");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "invalid phone" -> {
                response.put("message", "invalid phone");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD painting to the bought painting list
    @PutMapping("/bought/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingToBoughtPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.addPaintingToBoughtPaintingList(id, paintingid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD painting to the saved painting list
    @PutMapping("/saved/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingToSavedPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.addPaintingToSavedPaintingList(id, paintingid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //REMOVE painting from the saved painting list
    @PutMapping("/remove/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> removePaintingFromSavedPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.removePaintingFromSavedPaintingList(id, paintingid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD painting to the liked painting list
    @PutMapping("/like/add/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> addPaintingToLikedPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.addPaintingToLikedPaintingList(id, paintingid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "already liked" -> {
                response.put("message", "already liked");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //REMOVE painting to the liked painting list
    @PutMapping("/like/remove/{id}/{paintingid}")
    public ResponseEntity<Map<String, Object>> removePaintingFromLikedPaintingList(@PathVariable String id, @PathVariable String paintingid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.removePaintingFromLikedPaintingList(id, paintingid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "does not exist" -> {
                response.put("message", "this was not liked in the first place you dumb ass");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //ADD followed painters to the following painters list
    @PutMapping("/following/add/{id}/{clientid}")
    public ResponseEntity<Map<String, Object>> addToFollowingPaintersList(@PathVariable String id, @PathVariable String clientid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.addToFollowingPaintersList(id, clientid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "client" -> {
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "already followed" -> {
                response.put("message", "already followed - your front end is shit");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //REMOVE followed painters to the following painters list
    @PutMapping("/following/sub/{id}/{clientid}")
    public ResponseEntity<Map<String, Object>> removeFromFollowingPaintersList(@PathVariable String id, @PathVariable String clientid) {
        Map<String, Object> response = new HashMap<>();

        String status = userService.removeFromFollowingPaintersList(id, clientid);

        switch (status) {
            case "user" -> {
                response.put("message", "User not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "client" -> {
                response.put("message", "Client not found");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            case "not followed" -> {
                response.put("message", "not followed in the first place - you can't code!");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            case "updated" -> {
                response.put("message", "updated");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        }
        response.put("message", "Unknown error");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //DELETE user
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable String id) throws ForbiddenException, TooManyRequestsException, InternalServerException, UnauthorizedException, BadRequestException, UnknownException {
        String status = userService.deleteUser(id);
        switch (status) {
            case "not found" -> {
                return new ResponseEntity<>("User not found!", HttpStatus.OK);
            }
            case "deleted" -> {
                return new ResponseEntity<>("User deleted!", HttpStatus.OK);
            }
            case "empty" -> {
                return new ResponseEntity<>("User deleted - profile picture not found!", HttpStatus.OK);
            }
        }
        return new ResponseEntity<>("Unknown error!", HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
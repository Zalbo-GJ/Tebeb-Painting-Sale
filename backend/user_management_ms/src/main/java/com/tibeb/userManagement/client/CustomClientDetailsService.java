package com.tibeb.userManagement.client;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomClientDetailsService implements UserDetailsService {

    private final ClientRepository clientRepository;

    @Autowired
    public CustomClientDetailsService(ClientRepository clientRepository) {
        this.clientRepository = clientRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Client client = clientRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Client not found with email: " + email));

        return org.springframework.security.core.userdetails.User.builder()
                .username(client.getEmail()) // Use email as username in UserDetails
                .password(client.getPassword())
                .roles(client.getRole().toString()) // Assuming role is a string representation
                // Add more attributes if needed (e.g., authorities, account status)
                .build();
    }
}

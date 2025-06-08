package rhythmics.rhythmics_music_studio_booking_website_backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.UserDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.UserRegisterRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.UserUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.EntityToDtoMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.UserRepository;
import rhythmics.rhythmics_music_studio_booking_website_backend.security.BCrypt;

import java.util.List;
import java.util.Objects;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ValidationService validationService;

    @Transactional
    public UserDataResponse register(UserRegisterRequest request) {
        validationService.validate(request);

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email is already in use");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPassword(BCrypt.hashpw(request.getPassword(), BCrypt.gensalt()));

        userRepository.save(user);

        return EntityToDtoMapper.toUserDataResponse(user);
    }

    public UserDataResponse get(User user) {
        return EntityToDtoMapper.toUserDataResponse(user);
    }

    @Transactional
    public UserDataResponse update(User user, UserUpdateRequest request) {
        validationService.validate(request);

        if (Objects.nonNull(request.getFirstName())) {
            user.setFirstName(request.getFirstName());
        }

        if (Objects.nonNull(request.getLastName())) {
            user.setLastName(request.getLastName());
        }

        userRepository.save(user);

        return EntityToDtoMapper.toUserDataResponse(user);
    }

    @Transactional
    public void delete(long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        userRepository.delete(user);
    }

    @Transactional
    public List<UserDataResponse> getAll() {
        List<User> users = userRepository.findAll();
        return users.stream()
                .map(EntityToDtoMapper::toUserDataResponse)
                .toList();
    }

}

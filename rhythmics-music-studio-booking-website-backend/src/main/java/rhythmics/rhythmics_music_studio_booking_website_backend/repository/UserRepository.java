package rhythmics.rhythmics_music_studio_booking_website_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    boolean existsByEmail(String email);

    Optional<User> findFirstByEmail(String email);

    Optional<User> findFirstByToken(String token);

    Optional<User> findFirstByOtp(String otp);

    Optional<User> findFirstByResetToken(String resetToken);
}
